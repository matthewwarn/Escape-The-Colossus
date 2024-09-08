using System;
using System.Collections.Generic;
using System.IO;


public class LinkedLevelTree : LevelTree
{
    // Used for formatting in Serialise() and Deserialize()
    private const char LEAF_MARKER = '|';
    private const char PATH_END_MARKER = ';';
    
    /// <summary>
    /// Tree node which holds the path to a level's scene file.
    /// </summary>
    /// <param name="path">Path to scene</param>
    /// <param name="parent">Used internally to link child nodes to parents.</param>
    class PathNode(string path, PathNode? parent = null)
    {
        public string ScenePath { get; } = path;
        public PathNode? Parent { get; } = parent;
        public List<PathNode> Children { get; } = new List<PathNode>(3);

        public void AddChild(PathNode childNode)
        {
            Children.Add(childNode);
        }
    }
    
    // Store scene nodes privately and expose paths through read-only properties.
    private readonly PathNode _rootScene;
    public string RootScenePath => _rootScene.ScenePath;

    private PathNode _currentScene;
    public string CurrentScenePath => _currentScene.ScenePath;

    private Dictionary<string, PathNode> _levelLookupTable;

    /// <summary>
    /// Instantiate a level tree using existing config file.
    /// </summary>
    /// <param name="filePath">Path to config file</param>
    public LinkedLevelTree(string filePath)
    {
        _levelLookupTable = new Dictionary<string, PathNode>();
        using (StreamReader reader = new StreamReader(filePath))
        {
            _rootScene = Deserialize(reader);
        }

        _currentScene = _rootScene;
    }

    public string JumpToLevel(string path)
    {
        if (_levelLookupTable.TryGetValue(path, out PathNode requestedLevel))
        {
            _currentScene = requestedLevel;
            return CurrentScenePath;
        }
        throw new KeyNotFoundException("Requested level " + path + " does not exist in level tree.");
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
            throw new IndexOutOfRangeException("Child " + childIndex + " of \'" + CurrentScenePath + "\' either does not exist or is incorrectly linked.");
        // Switch to requested child node.
        _currentScene = _currentScene.Children[childIndex];
        return CurrentScenePath;
    }

    /// <summary>
    /// Saves the configuration of this tree to a file.
    /// Each nodes path is saved and terminated with PATH_END_MARKER
    /// Each leaf node is terminated with LEAF_MARKER
    /// For example:
    /// root;One;OneA;|OneB;||Two;TwoA;|||
    /// </summary>
    /// <param name="outputStream">Output file stream.</param>
    public void Serialise(StreamWriter outputStream)
    {
        Serialise(_rootScene, outputStream);
    }
    
    private void Serialise(PathNode root, StreamWriter outputStream)
    {
        outputStream.Write(root.ScenePath + PATH_END_MARKER);
        foreach (PathNode child in root.Children)
        {
            Serialise(child, outputStream);
        }
        outputStream.Write(LEAF_MARKER + "");
    }

    /// <summary>
    /// Load a saved tree configuration from file.
    /// Expects the formatting from LinkedLevelTree.Serialise()
    /// Ie: root;One;OneA;|OneB;||Two;TwoA;|||
    /// </summary>
    /// <param name="inputStream">Input file stream.</param>
    /// <param name="parent">Parameter used by recursive calls to add child nodes.</param>
    /// <returns>Root node of resulting tree.</returns>
    private PathNode Deserialize(StreamReader inputStream, PathNode? parent = null)
    {
        int val = inputStream.Read();
        // Have we found either the end of the file or the end of a leaf node?
        if (val == -1 || val == LEAF_MARKER)
            return null;
        
        string path = "";
        
        // Keep reading characters until we have the entire path for this node.
        while (val != PATH_END_MARKER)
        {
            path += (char)val;
            val = inputStream.Read();
        }

        // Create a node from this path and recursively add its children.
        PathNode newNode = new PathNode(path, parent);
        _levelLookupTable.Add(newNode.ScenePath, newNode);
        while (true)
        {
            PathNode child = Deserialize(inputStream, newNode);
            // null is returned whenever the end of a leaf it encountered.
            if (child == null)
                break;
            newNode.AddChild(child);
        }

        return newNode;
    }
}