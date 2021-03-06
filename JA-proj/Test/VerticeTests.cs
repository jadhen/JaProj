﻿using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Media;
using System.Xml.Serialization;
using JA_proj.Model;
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

            var figure3 = new VerterxFigure("#FFAABE2E")
            {
                Name = "Squere",
                Vertices = new[] { new Vertex(100, 10), new Vertex(800, 200), new Vertex(450, 500) }
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
            figureFile.Figures = new Figure[] {figure, figure2, figure3};
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

        [Test]
        public void TestAssemblerPolygon()
        {
            int height = 10;
            int width = 10;
            var drawer = DrawingLibraryFactory.GetFigureDrawer(AlgorithmsImplementation.ASM, width, height);
            var figure = new VerterxFigure("#FFEA2E2E")
            {
                Name = "Squere",
                Vertices = new[] { new Vertex(1, 2), new Vertex(4, 4), new Vertex(3, 6) }
            };
            var imageArray = figure.Draw(drawer);

            var output = ImageUtility.ConvertToImage(imageArray, width, height);
            ImageUtility.SaveBitmap(output, "TestOut.png");
        }      
        
        [Test]
        public void TestAssemblerComplexPolygon()
        {
            int height = 600;
            int width = 600;
            var drawer = DrawingLibraryFactory.GetFigureDrawer(AlgorithmsImplementation.ASM, width, height);
            var figure = new VerterxFigure("#FFEA2E2E")
            {
                Name = "Squere",
                Vertices = new[] { new Vertex(100, 300), new Vertex(300, 250), new Vertex(500, 300), new Vertex(500, 100), new Vertex(300, 200), new Vertex(100, 100) }
            };
            var imageArray = figure.Draw(drawer);

            var output = ImageUtility.ConvertToImage(imageArray, width, height);
            ImageUtility.SaveBitmap(output, "TestOut2.png");
        }

        [Test]
        public void TestAssemblerCircle()
        {
            int height = 10;
            int width = 10;
            var drawer = DrawingLibraryFactory.GetFigureDrawer(AlgorithmsImplementation.ASM, width, height);
            var figure = new Circle("Cicrle","#FFEA2E2E")
            {
                Center = new Vertex(2,5),
                Radius = 4
            };
            var imageArray = figure.Draw(drawer);

            var output = ImageUtility.ConvertToImage(imageArray, width, height);
            ImageUtility.SaveBitmap(output, "TestOut3.png");
        }

        [Test]
        public void TestAssemblerBigCircle()
        {
            int height = 600;
            int width = 400;
            var drawer = DrawingLibraryFactory.GetFigureDrawer(AlgorithmsImplementation.ASM, width, height);
            var figure = new Circle("Cicrle", "#FFEA2E2E")
            {
                Center = new Vertex(200, 200),
                Radius = 100
            };
            var imageArray = figure.Draw(drawer);

            var output = ImageUtility.ConvertToImage(imageArray, width, height);
            ImageUtility.SaveBitmap(output, "TestOut4.png");
        }
        [Test]
        public void TestAssemblerCrown()
        {
            int height = 600;
            int width = 600;
            var drawer = DrawingLibraryFactory.GetFigureDrawer(AlgorithmsImplementation.ASM, width, height);
            var figure = new VerterxFigure("#FFEA2E2E")
            {
                Name = "Squere",
                Vertices = new[] { new Vertex(200, 300), new Vertex(250, 250), new Vertex(300, 300), new Vertex(300, 100), new Vertex(100, 100), new Vertex(100, 300), new Vertex(150, 250) }
            };
            var imageArray = figure.Draw(drawer);

            var output = ImageUtility.ConvertToImage(imageArray, width, height);
            ImageUtility.SaveBitmap(output, "TestOut2.png");
        }
    }
}
