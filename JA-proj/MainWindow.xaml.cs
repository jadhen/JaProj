using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Xceed.Wpf.Toolkit;
using JA_proj.ViewModel;
namespace JA_proj
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            DataContext = new MainViewModel();
        }

        private void UIOnFileDrop(object sender, DragEventArgs e)
        {
            var dc = DataContext as MainViewModel;
            if (dc != null)
            {
                dc.OnFileDragDrop(e);
            }

        }

        private void ButtonBase_OnClick(object sender, RoutedEventArgs e)
        {
            var dc = DataContext as MainViewModel;
            if (dc != null)
            {
                dc.PresentComputingParameters();
            }
        }
    }
}
