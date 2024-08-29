using System.IO;

public interface LevelTree
{
    string RootScenePath { get; }
    string CurrentScenePath { get; }
    
    string TraverseUp();
    string TraverseToChild(int childIndex);
    void Serialise(StreamWriter outputStream);
}