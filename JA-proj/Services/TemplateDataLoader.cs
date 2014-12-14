namespace JA_proj.ViewModel
{
    public class TemplateDataLoader
    {
        public static DrawingConfiguration LoadTemplateFigures()
        {
            var figure = new VerterxFigure("#FFEA2E2E");
            figure.Name = "Squere";
            figure.Vertices = new[] { new Vertex(10, 10), new Vertex(10, 15), new Vertex(14, 30) };

            var figure2 = new VerterxFigure("#FFEA2E2E");
            figure2.Name = "Circle";
            figure2.Vertices = new[] { new Vertex(10, 10), new Vertex(10, 15), new Vertex(14, 30) };
            var figures = new[] {figure, figure2};
            var config = new DrawingConfiguration()
            {
                Figures = figures,
                Width = 700,
                Height = 700
            };
            return config;
        }
    }
}