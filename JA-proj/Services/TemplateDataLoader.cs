namespace JA_proj.ViewModel
{
    public class TemplateDataLoader
    {
        public static Figure[] LoadTemplateFigures()
        {
            var figure = new Figure("#FFEA2E2E");
            figure.Name = "Squere";
            figure.Vertices = new[] { new Vertex(10, 10), new Vertex(10, 15), new Vertex(14, 30) };

            var figure2 = new Figure("#FFEA2E2E");
            figure2.Name = "Circle";
            figure2.Vertices = new[] { new Vertex(10, 10), new Vertex(10, 15), new Vertex(14, 30) };
            return new[] {figure, figure2};
        }
    }
}