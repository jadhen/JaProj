using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Windows.Data;

namespace JA_proj.Converters
{
    /// <summary>
    /// Konwereter 
    /// </summary>
    public class EnumGroupRadioButton: IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            return value.Equals(parameter);
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            return ((bool)value) ? parameter : Binding.DoNothing;
        }
    }
}
