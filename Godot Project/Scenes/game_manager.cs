using System.IO;
using Godot;

public partial class game_manager : Node
{
	private readonly string LEVEL_LINKS_PATH = @"Scenes/level_links.dat";
	private readonly string GAME_SAVE_PATH   = @"Scenes/save.dat";
	
	private LevelTree _levelTree;
	private bool _bossOneDefeated = false;
	private bool _bossTwoDefeated = false;
	
	// Reference to current level root node.
	private Node current_level;
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		_levelTree = new LinkedLevelTree(LEVEL_LINKS_PATH);
		current_level = GetNode<Control>("Main Menu");
	}

	public void start_game()
	{
		LoadLevel(_levelTree.RootScenePath);
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
		current_level.Connect("level_reset_requested", Callable.From(ReloadCurrentLevel));
		current_level.Connect("next_level_requested", Callable.From(LoadNextLevel));
	}

	/// <summary>
	/// Remove the current level from the scene tree and then reload it from file.
	/// Useful for player death.
	/// </summary>
	public void ReloadCurrentLevel()
	{
		GD.Print("death received");
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
}
