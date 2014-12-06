using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using JA_proj.ViewModel;
using NUnit.Framework;

namespace JA_proj.Test
{
    [TestFixture]
    public class VerticeTests
    {
        [Test]
        public void CreateXML()
        {

            var figure = new Figure("0xFFAABB");
            figure.Name = "Squere";
            figure.Vertices = new[] {new Vertex(10, 10), new Vertex(10, 15), new Vertex(14, 30)};
            
            var figure2 = new Figure("0xAABBCC");
            figure2.Name = "Circle";
            figure2.Vertices = new[] {new Vertex(10, 10), new Vertex(10, 15), new Vertex(14, 30)};
            
            var figureFile = new FigureFile();
            figureFile.Figures = new[] {figure, figure2};
            var xmlSerializer = new XmlSerializer(typeof (FigureFile));
            using (var streamWriter = new StreamWriter("test.xml"))
            {
                xmlSerializer.Serialize(streamWriter, figureFile);
            }
        }
    }
}
