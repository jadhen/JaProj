using System;
using System.Windows.Media;
using System.Xml.Serialization;

namespace JA_proj.ViewModel
{
    public class FigureFile
    {
        public Figure[] Figures{ get; set; }
    }
    public class Figure
    {
        public Figure()
        {
        }

        public Figure(string color) : this("Custom Figure", color)
        {
            
        }

        public Figure(string name, string color)
        {
            Color = new FigureColor() {HexColor = color};
            Name = name;
        }
        public string Name { get; set; }
        public FigureColor Color { get; set; }
        
        public Vertex[] Vertices{ get; set; }
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

    public class Vertex
    {
        public Vertex()
        {
        }

        public Vertex(int x, int y)
        {
            X = x;
            Y = y;
        }

        [XmlAttribute]
        public int X { get; set; }
        [XmlAttribute]
        public int Y { get; set; }
    }
}