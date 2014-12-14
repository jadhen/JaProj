
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


        private BitmapSource ConvertToImage(int[] bitmapArray)
        {
            var bytes = GetByteArrayFromIntArray(bitmapArray);
            var format = PixelFormats.Pbgra32;
            var stride = bitmapWidth * format.BitsPerPixel / 8;
            return BitmapSource.Create(bitmapWidth, bitmapHeight, 96, 96, format, null, bytes, stride);
        }
     

        private int[] GetBitmapArray()
        {
            return  new int[bitmapWidth * bitmapHeight];
        }

        public static byte[] GetByteArrayFromIntArray(int[] intArray)
        {

            byte[] data = new byte[intArray.Length * 4];

            for (int i = 0; i < intArray.Length; i++)

                Array.Copy(BitConverter.GetBytes(intArray[i]), 0, data, i * 4, 4);

            return data;

        }

        public BitmapSource DrawVerticesFigure(Vertex[] vertices, Color color)
        {
            int[] bitmapArray = GetBitmapArray();
            drawer.CallDrawFigure(bitmapArray, bitmapHeight, bitmapWidth, color , vertices);
            var bitmap = ConvertToImage(bitmapArray);

            return bitmap;
        }

        public BitmapSource DrawCircle(Vertex center, int radius, Color color)
        {
            int[] bitmapArray = GetBitmapArray();
            drawer.CallDrawCircle(bitmapArray, bitmapHeight, bitmapWidth, color, center, radius);
            var bitmap = ConvertToImage(bitmapArray);

            return bitmap;
        }
    }
}