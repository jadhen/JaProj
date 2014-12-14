using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Data;
using System.Windows.Media;
using System.Windows.Shapes;
using JA_proj.ViewModel;

namespace JA_proj.Converters
{
    public class ShapeConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            var figure = value as Figure;
            if (value is VerterxFigure)
            {
                var rect = new Rectangle
                {
                    Width = 10,
                    Height = 10,
                    Fill = new SolidColorBrush(figure.Color.Color)
                };
                return rect;
            } else if (value is Circle)
            {
                var circle = new System.Windows.Shapes.Ellipse()
                {
                    Width = 10,
                    Height = 10,
                    Fill = new SolidColorBrush(figure.Color.Color)
                };
                return circle;
            }
            return null;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}
