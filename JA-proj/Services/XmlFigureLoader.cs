using System.IO;
using System.Xml.Serialization;

namespace JA_proj.ViewModel
{
    public class XmlFigureLoader : IFigureLoader
    {
        public DrawingConfiguration LoadFromFile(string filePath)
        {
            var deserializer = new XmlSerializer(typeof(DrawingConfiguration));
            using (var streamReader = new StreamReader(filePath))
            {
                var figureFile = deserializer.Deserialize(streamReader) as DrawingConfiguration;
                return figureFile;
            }
        }
    }
}