namespace JA_proj.ViewModel
{
    public interface IFigureLoader
    {
        DrawingConfiguration LoadFromFile(string filePath);
    }
}