
using System;
using System.CodeDom;
using System.ComponentModel;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using JA_proj.Annotations;
using JA_proj.NativeCodeBridge;
using Color = System.Windows.Media.Color;
using Image = System.Windows.Controls.Image;
using PixelFormat = System.Drawing.Imaging.PixelFormat;

namespace JA_proj.ViewModel
{
    public class FigureDrawer :IFigureDrawer
    {
        private readonly IDrawingLibrary drawer;
        private int bitmapWidth = 600;
        private int bitmapHeight = 600;

        public FigureDrawer(IDrawingLibrary drawer)
        {
            this.drawer = drawer;
        }

        public FigureDrawer(IDrawingLibrary drawingLibrary, int width, int height) : this(drawingLibrary)
        {
            bitmapWidth = width;
            bitmapHeight = height;
        }


        

        public int[] DrawVerticesFigure(Vertex[] vertices, Color color)
        {
            int[] bitmapArray = GetEmptyBitmap();
            drawer.CallDrawFigure(bitmapArray, bitmapHeight, bitmapWidth, color , vertices);
            return bitmapArray;

        }

        public int[] DrawCircle(Vertex center, int radius, Color color)
        {
            int[] bitmapArray = GetEmptyBitmap();
            drawer.CallDrawCircle(bitmapArray, bitmapHeight, bitmapWidth, color, center, radius);
            return bitmapArray;
        }

        public int[] GetEmptyBitmap()
        {
            return new int[bitmapWidth * bitmapHeight];
        }
    }
}