namespace JA_proj.ViewModel
{
    public interface IFigureLoader
    {
        Figure[] LoadFromFile(string filePath);
    }
}