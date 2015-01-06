using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Media;
using JA_proj.ViewModel;

namespace JA_proj.NativeCodeBridge
{
    public unsafe class CppAccesorLibrary : IDrawingLibrary
    {

        [DllImport("CppLib.dll", CallingConvention = CallingConvention.Cdecl)]
        private static extern void DrawFigure(int[] bitmapArray, int rowCount, int columnCount, uint color, Vertex[] vertexArray, int length);

        [DllImport("CppLib.dll", CallingConvention = CallingConvention.Cdecl)]
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

    public static class ColorUtility
    {
        public static uint ColorToInt(Color color)
        {
            uint myColor = (uint) (color.A << 24);
            myColor |= (uint) color.R << 16;
            myColor |= (uint) color.G << 8;
            myColor |= (uint) color.B;
            return myColor;
        }
    }
}
