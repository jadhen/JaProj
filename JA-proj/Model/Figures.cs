using System;
using System.Runtime.InteropServices;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Xml.Serialization;

namespace JA_proj.ViewModel
{
    public class DrawingConfiguration
        
    {
        public int Width { get; set; }
        public int Height { get; set; }
        [XmlArrayItem("VertexFigure", typeof(VerterxFigure))]
        [XmlArrayItem("Circle", typeof(Circle))]
        public Figure[] Figures{ get; set; }
    }

    public abstract class Figure
    {
        protected Figure()
        {
        }

        protected Figure(string name, string color)
        {
            Color = new FigureColor() { HexColor = color };
            Name = name;
        }

        public abstract int[] Draw(IFigureDrawer drawer);
        public string Name { get; set; }
        public FigureColor Color { get; set; }
    }

    public interface IFigureDrawer
    {
        int[] DrawVerticesFigure(Vertex[] vertices, Color color);
        int[] DrawCircle(Vertex center, int radius, Color color);
        int[] GetEmptyBitmap();
    }

    public class VerterxFigure : Figure
    {
        public VerterxFigure()
        {
        }

        public VerterxFigure(string color) : this("Custom vertex figure", color)
        {
            
        }

        public VerterxFigure(string name, string color) : base(name, color)
        {
            
        }

        public Vertex[] Vertices{ get; set; }
        public override int[] Draw(IFigureDrawer drawer)
        {
            return drawer.DrawVerticesFigure(Vertices, Color.Color);       
        }
    }

    public class FigureColor
    {
        public FigureColor()
        {
        }

        [XmlIgnore]
        public Color Color
        {
            get
            {
                try
                {
                    return (Color)ColorConverter.ConvertFromString(HexColor);
                }
                catch (Exception e)
                {
                   return  Color.FromRgb(255,255,255);
                }
            }
        }

       
        [XmlText]
        public string HexColor { get; set; }
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct Vertex
    {

        public Vertex(int x, int y) : this()
        {
            X = x;
            Y = y;
        }

        [XmlAttribute]
        public int X { get; set; }
        [XmlAttribute]
        public int Y { get; set; }
    }

    public class Circle : Figure 
    {
        public Circle()
        {
            
        }

        public Circle(string color) : base("Circle", color)
        {
            
        }

        public  Circle(string name, string color) : base(name, color)
        {
        }

        public Vertex Center { get; set; }
        public int Radius { get; set; }
        public override int[] Draw(IFigureDrawer drawer)
        {
            return drawer.DrawCircle(Center, Radius, Color.Color);
        }
    }
}