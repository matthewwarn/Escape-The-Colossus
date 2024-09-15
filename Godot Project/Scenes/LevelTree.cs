using System.IO;

public interface LevelTree
{
    string RootScenePath { get; }
    string CurrentScenePath { get; }
    
    string TraverseUp();
    string TraverseToChild(int childIndex);
    string JumpToLevel(string path);
    void Reset();
    void Serialise(StreamWriter outputStream);
}
