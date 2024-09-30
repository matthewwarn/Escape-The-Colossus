using System.IO;

public interface LevelTree
{
	/// <summary>
	/// Path to the first level of the game. Relative to project root dir.
	/// </summary>
	string RootScenePath { get; }
	
	/// <summary>
	/// Path to the currently selected level. Relative to project root dir.
	/// </summary>
	string CurrentScenePath { get; }
	
	/// <summary>
	/// Go to the current level's parent level.
	/// This should be the previous level in-game.
	/// </summary>
	/// <returns>Path to parent level.</returns>
	string TraverseUp();
	
	/// <summary>
	/// Jump to one of the curren level's children.
	/// In most cases there is only one child (next level) at index zero.
	/// </summary>
	/// <param name="childIndex">Index of child.</param>
	/// <returns>Path to child.</returns>
	string TraverseToChild(int childIndex);
	
	/// <summary>
	/// Jump to a level using it's path.
	/// Ensures that links to other levels are present when loading from saved level path.
	/// </summary>
	/// <param name="path">Path to level relative to project root.</param>
	/// <returns>Level Path</returns>
	string JumpToLevel(string path);
	
	/// <summary>
	/// Return to first level.
	/// </summary>
	void Reset();
	
	/// <summary>
	/// Are we at the first level?
	/// </summary>
	/// <returns>True if we are at the first level, false otherwise.</returns>
	bool IsAtRoot();
}
