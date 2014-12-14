using System.Windows.Media;
using JA_proj.ViewModel;

namespace JA_proj.NativeCodeBridge
{
    public interface IDrawingLibrary
    {
        void CallDrawFigure(int[] bitmapArray, int rowCount, int columCount, Color color, Vertex[] vertexArray);
        void CallDrawCircle(int[] bitmapArray, int bitmapHeight, int bitmapWidth, Color blue, Vertex center, int radius);
    }
}