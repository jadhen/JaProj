using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Media;
using System.Xml.Serialization;
using JA_proj.NativeCodeBridge;
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

            var figure = new VerterxFigure("#FFEA2E2E")
            {
                Name = "Squere",
                Vertices = new[] {new Vertex(10, 10), new Vertex(400, 200), new Vertex(200, 500)}
            };

            var figure2 = new Circle("#FFEA2E2E")
            {
                Name = "Circle", 
                Center = new Vertex(10, 16), 
                Radius = 40
            };

            var figureFile = new DrawingConfiguration();
            figureFile.Height = 600;
            figureFile.Width = 600;
            figureFile.Figures = new Figure[] {figure, figure2};
            var xmlSerializer = new XmlSerializer(typeof (DrawingConfiguration));
            using (var streamWriter = new StreamWriter("test.xml"))
            {
                xmlSerializer.Serialize(streamWriter, figureFile);
            }
        }

        [Test]
        public void Deserialize()
        {
            var xmlSerializer = new XmlSerializer(typeof(DrawingConfiguration));
            using (var streamWriter = new StreamReader("test.xml"))
            {
                var figure = xmlSerializer.Deserialize(streamWriter) as DrawingConfiguration;
            }
        }



        [Test]
        public void TestColor()
        {
            var color = Color.FromArgb(0xFF, 0xAA, 0xCC, 0xBB);
            var intColor = ColorUtility.ColorToInt(color);
            Assert.That(intColor, Is.EqualTo(0xFFAACCBB));
        }


    }
}
