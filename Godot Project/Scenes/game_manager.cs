using System.IO;
using EscapeTheColossus.Scenes;
using Godot;

public partial class game_manager : Node
{
	private readonly string LEVEL_LINKS_PATH = @"Scenes/level_links.dat";
	private readonly string GAME_SAVE_PATH   = @"Scenes/save.dat";
	private readonly string MAIN_MENU = @"Scenes/Menus/main_menu.tscn";
	
	private LevelTree _levelTree;
	private bool _bossOneDefeated = false;
	private bool _bossTwoDefeated = false;
	
	// Reference to current level root node.
	private Node current_level;
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		// _levelTree = new LinkedLevelTree(LEVEL_LINKS_PATH);
		_levelTree = new GraphLevelTree(LEVEL_LINKS_PATH);
		current_level = GetNode<Control>("Main Menu");
	}

	/// <summary>
	/// Start the game from the root level ignoring existing saves.
	/// </summary>
	public void start_game()
	{
		_levelTree.Reset();
		LoadLevel(_levelTree.CurrentScenePath);
	}

	/// <summary>
	/// Load previous game state, then start game.
	/// </summary>
	public void ResumeGame()
	{
		ReadSave();
		LoadLevel(_levelTree.CurrentScenePath);
	}

	public void OpenMainMenu()
	{
		SaveGame();
		LoadLevel(MAIN_MENU);
	}

	/// <summary>
	/// Write the current game state data out to a file.
	/// </summary>
	public void SaveGame()
	{
		if (File.Exists(GAME_SAVE_PATH))
			File.Delete(GAME_SAVE_PATH);
		
		// Using statement is important because it closes the streamwrite in the case of exceptons.
		using (StreamWriter saveFile = new StreamWriter(GAME_SAVE_PATH))
		{
			saveFile.WriteLine(_levelTree.CurrentScenePath);
			saveFile.WriteLine(_bossOneDefeated);
			saveFile.WriteLine(_bossTwoDefeated);
		}
	}

	public void ReadSave()
	{
		if (!File.Exists(GAME_SAVE_PATH))
		{
			GD.Print("Save data not found, falling back to default values.");
			return;
		}

		using (StreamReader saveFile = new StreamReader(GAME_SAVE_PATH))
		{
			_levelTree.JumpToLevel(saveFile.ReadLine());
			_bossOneDefeated = saveFile.ReadLine() == "True";
			_bossTwoDefeated = saveFile.ReadLine() == "True";
		}	
	}

	/// <summary>
	/// Removes the current scene from the tree and loads in the scene from the given path.
	/// Save to call any time; Calls to a deferred method.
	/// </summary>
	/// <param name="level_path">Path to new scene.</param>
	public void LoadLevel(string level_path)
	{
		CallDeferred(MethodName.DeferredLoadLevel, level_path);
		SaveGame();
	}

	public void DeferredLoadLevel(string path)
	{
		// Remove the current scene
		current_level.Free();

		// Load in the next scene
		var nextScene = GD.Load<PackedScene>(path);
		current_level = nextScene.Instantiate();
		
		// Add to tree
		GetTree().Root.AddChild(current_level);
		GetTree().CurrentScene = current_level;
		
		// Connect Signals
		if (path == MAIN_MENU)
		{
			current_level.Connect("game_start_requested", Callable.From(start_game));
			current_level.Connect("game_resume_requested", Callable.From(ResumeGame));
		}
		else
		{
			current_level.Connect("level_reset_requested", Callable.From(ReloadCurrentLevel));
			current_level.Connect("next_level_requested", Callable.From(LoadNextLevel));
			if (!_levelTree.IsAtRoot())
				current_level.Connect("previous_level_requested", Callable.From(LoadPreviousLevel));
			current_level.Connect("main_menu_requested", Callable.From(OpenMainMenu));
		}
		
	}

	/// <summary>
	/// Remove the current level from the scene tree and then reload it from file.
	/// Useful for player death.
	/// </summary>
	public void ReloadCurrentLevel()
	{
		GD.Print("reloading");
		LoadLevel(_levelTree.CurrentScenePath);
	}

	/// <summary>
	/// Looks for the next level in the level_paths array.
	/// If a level is found then it will be loaded.
	/// Otherwise an error message will be printed and no action taken.
	/// </summary>
	public void LoadNextLevel()
	{
		LoadLevel(_levelTree.TraverseToChild(0));
	}

	public void LoadPreviousLevel()
	{
		LoadLevel(_levelTree.TraverseUp());
		CallDeferred(MethodName.JumpPlayerToEnd);
	}

	private void JumpPlayerToEnd()
	{
		current_level.Call("_jump_to_end");
	}
}
