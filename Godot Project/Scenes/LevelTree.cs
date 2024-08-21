using System;
using System.Collections.Generic;

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
    /// If this is the root node then the scene will not change.
    /// </summary>
    /// <returns>Newly selected scene path.</returns>
    public string TraverseUp()
    {
        if (_currentScene.Parent != null)
            _currentScene = _currentScene.Parent;
        else
            Console.WriteLine("No parent exists.");
        return CurrentScenePath;
    }

    /// <summary>
    /// Switch the current scene to a child of the current scene.
    /// Throws IndexOutOfBoundsException if requested child does not exist.
    /// </summary>
    /// <param name="childIndex">Index of child scene.</param>
    /// <returns>Path to newly selected scene.</returns>
    public string TraverseToChild(int childIndex)
    {
        // Check requested child exists.
        if (_currentScene.Children.Count < childIndex - 1)
            throw new IndexOutOfRangeException();
        // Switch to requested child node.
        _currentScene = _currentScene.Children[childIndex];
        return CurrentScenePath;
    }
}

internal class PathNode(string path, PathNode parent)
{
    public string ScenePath { get; } = path;
    public PathNode Parent { get; } = parent;
    public List<PathNode> Children { get; set; }
}