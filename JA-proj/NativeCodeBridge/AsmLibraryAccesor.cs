using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Media;
using JA_proj.ViewModel;

namespace JA_proj.NativeCodeBridge
{
    public unsafe class AsmLibraryAccesor : IDrawingLibrary
    {

        [DllImport("AsmLib.dll", CallingConvention = CallingConvention.StdCall)]
        private static extern void DrawFigure(int[] bitmapArray, int rowCount, int columnCount, uint color, Vertex[] vertexArray, int length);

        [DllImport("AsmLib.dll", CallingConvention = CallingConvention.StdCall)]
        private static extern void DrawCircle(int[] bitmapArray, int rowCount, int columnCount, uint color, Vertex center, int radius);


        public void CallDrawFigure(int[] bitmapArray, int rowCount, int columCount, Color color, Vertex[] vertexArray)
        {
            var intColor = ColorUtility.ColorToInt(color);
            DrawFigure(bitmapArray, rowCount, columCount, intColor, vertexArray, vertexArray.Length);
        }

        public void CallDrawCircle(int[] bitmapArray, int bitmapHeight, int bitmapWidth, Color color, Vertex center, int radius)
        {
            var intColor = ColorUtility.ColorToInt(color);
            DrawCircle(bitmapArray, bitmapHeight, bitmapWidth, intColor, center, radius);
        }
    }

}
