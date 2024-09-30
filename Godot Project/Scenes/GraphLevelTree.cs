using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using Godot;

namespace EscapeTheColossus.Scenes;

public class GraphLevelTree : LevelTree
{
    // Used for formatting in Deserialize()
	private const char PATH_END_MARKER = '|';						// Marks the end of a path in a line.
	private const string LEVEL_ROOT_DIR = "res://Scenes/Levels/";	// Levels in level_links.dat are given relative to this dir.
	
	/// <summary>
	/// Tree node which holds the path to a level's scene file.
	/// </summary>
	/// <param name="path">Path to scene</param>
	/// <param name="parent">Used internally to link child nodes to parents.</param>
	class PathNode(string path)
	{
		public string ScenePath { get; } = path;
		public PathNode Parent { get; set; }
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

	// Stores references to all levels nodes by their paths.
	private Dictionary<string, PathNode> _levelLookupTable;
	
	/// <summary>
	/// Instantiate a level tree using existing config file.
	/// </summary>
	/// <param name="filePath">Path to config file</param>
	public GraphLevelTree(string filePath)
	{
		_levelLookupTable = new Dictionary<string, PathNode>();
		_rootScene = Deserialize(filePath);

		_currentScene = _rootScene;
	}

	public string JumpToLevel(string path)
	{
		GD.Print(path);
		if (_levelLookupTable.TryGetValue(path, out PathNode requestedLevel))
		{
			_currentScene = requestedLevel;
			return CurrentScenePath;
		}
		throw new KeyNotFoundException("Requested level " + path + " does not exist in level tree.");
	}
	
	public void Reset()
	{
		_currentScene = _rootScene;
	}

	public bool IsAtRoot()
	{
		return CurrentScenePath.Equals(RootScenePath);
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
	/// Take the links as written in the given file and load them as a graph.
	/// </summary>
	/// <param name="filePath">File containing level links.</param>
	/// <returns>Node of first level in game.</returns>
	/// <exception cref="KeyNotFoundException">Child node specified in links file does not exist. Probably a typo.</exception>
	private PathNode Deserialize(string filePath)
	{
		// Read all lines in the level links file
		List<string[]> splitLines = new List<string[]>();
		using (StreamReader reader = new StreamReader(filePath))
		{
			string line = reader.ReadLine();
			while (line != null)
			{
				GD.Print(line);
				string[] linePaths = line.Split(PATH_END_MARKER);
				splitLines.Add(linePaths);
				line = reader.ReadLine();
			}
		}
		GD.Print("Lines done!");

		// Prepend root directory to all level paths
		foreach (string[] line in splitLines)
		{
			for (int pathIndex = 0; pathIndex < line.Length; pathIndex++)
			{
				line[pathIndex] = LEVEL_ROOT_DIR + line[pathIndex];
			}
		}

		// Create unlinked nodes from the file lines
		_levelLookupTable = new Dictionary<string, PathNode>(20);
		foreach (string[] line in splitLines)
		{
			string path = line[0];
			PathNode node = new PathNode(path);
			_levelLookupTable.Add(path, node);
		}
		GD.Print("Unlinked nodes done");

		// Link nodes to their children
		foreach (string[] line in splitLines)
		{
			if (_levelLookupTable.TryGetValue(line[0], out PathNode node))
			{
				for (int i = 1; i < line.Length; i++)
				{
					if (_levelLookupTable.TryGetValue(line[i], out PathNode childNode))
					{
						if (i == 1)
							node.Parent = childNode;
						else
							node.AddChild(childNode);
					}
					else
						throw new KeyNotFoundException("Child node " + line[i] + "does not exist in levels!");
				}
			}
		}
		GD.Print("Linking complete");

		// Get and return the first level.
		if (_levelLookupTable.TryGetValue(splitLines[0][0], out PathNode rootNode))
			return rootNode;
		throw new Exception("Root node not found.");
	}
}