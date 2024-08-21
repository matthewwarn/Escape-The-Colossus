namespace EscapeTheColossus.Scenes;

public class LevelTree
{
    // Store scene nodes privately and expose paths through read-only properties.
    private readonly PathNode _rootScene;
    public string RootScenePath
    {
        get { return _rootScene.ScenePath; }
    }
    
    private PathNode _currentScene;
    public string CurrentScenePath
    {
        get { return _currentScene.ScenePath; }
    }

    /// <summary>
    /// Move to the current level's parent level if a parent level exists.
    /// </summary>
    /// <returns>True if there was a parent to move to. False otherwise.</returns>
    public bool TraverseUp()
    {
        if (_currentScene.Parent == null)
            return false;
        _currentScene = _currentScene.Parent;
        return true;
    }

    /// <summary>
    /// Moves to current scene's left child if left child exists.
    /// </summary>
    /// <returns>True if moved, false otherwise.</returns>
    public bool TraverseLeft()
    {
        // ?? operator returns the left argument is not null, otherwise returns the right argument.
        _currentScene = (_currentScene.LeftChild ?? _currentScene);
        return _currentScene.LeftChild != null;
    }

    public bool TraverseRight()
    {
        _currentScene = (_currentScene.RightChild ?? _currentScene);
        return _currentScene.LeftChild != null;
    }
}

internal class PathNode(string path, PathNode parent)
{
    public string ScenePath { get; } = path;
    public PathNode Parent { get; } = parent;
    public PathNode LeftChild { get; set; } = null;
    public PathNode RightChild { get; set; } = null;
}