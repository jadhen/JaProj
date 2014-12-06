using System.IO;
using System.Xml.Serialization;

namespace JA_proj.ViewModel
{
    public class XmlFigureLoader : IFigureLoader
    {
        public Figure[] LoadFromFile(string filePath)
        {
            var deserializer = new XmlSerializer(typeof(FigureFile));
            using (var streamReader = new StreamReader(filePath))
            {
                var figureFile = deserializer.Deserialize(streamReader) as FigureFile;
                return figureFile.Figures;
            }
        }
    }
}