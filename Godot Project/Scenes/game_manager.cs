using Godot;

public partial class game_manager : Node
{
    // Put paths to all the game levels here.
    // Currently they are loaded one after another when level transitions are reached.
    // I will be implementing a tree system to allow levels with multiple exits.
    private string[] level_paths = {"res://Scenes/Levels/level_one.tscn"};
    
    // Keeps track of which level should currently be loaded.
    private int current_level_index = 0;
    
    // Reference to current level root node.
    private Node current_level;
	
    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        current_level = GetNode<Control>("Main Menu");
    }

    public void start_game()
    {
        LoadLevel(level_paths[0]);
    }

    /// <summary>
    /// Removes the current scene from the tree and loads in the scene from the given path.
    /// Save to call any time; Calls to a deferred method.
    /// </summary>
    /// <param name="level_path">Path to new scene.</param>
    public void LoadLevel(string level_path)
    {
        CallDeferred(MethodName.DeferredLoadLevel, level_path);
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
        LoadLevel(level_paths[current_level_index]);
    }

    /// <summary>
    /// Looks for the next level in the level_paths array.
    /// If a level is found then it will be loaded.
    /// Otherwise an error message will be printed and no action taken.
    /// </summary>
    public void LoadNextLevel()
    {
        current_level_index++;
        if (current_level_index > level_paths.Length - 1)
        {
            current_level_index--;
            GD.Print("No further levels to load. Add next level to level_paths in GameManager.");
            return;
        }
        LoadLevel(level_paths[current_level_index]);
    }
}