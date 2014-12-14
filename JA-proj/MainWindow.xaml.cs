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
using GalaSoft.MvvmLight.Messaging;
using JA_proj.Messages;
using Xceed.Wpf.Toolkit;
using JA_proj.ViewModel;
using MessageBox = System.Windows.MessageBox;

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
            Messenger.Default.Register<InvalidXmlMessage>(this, ReceiveInvalidXml);
            Messenger.Default.Register<NativeLibraryMessage>(this, ReceiveNativeLibraryMessage);
        }

        private void ReceiveNativeLibraryMessage(NativeLibraryMessage obj)
        {
            MessageBox.Show(obj.Message, "Bilbioteka");
        }

        private void ReceiveInvalidXml(InvalidXmlMessage obj)
        {
            MessageBox.Show(obj.InvalidMessage, "Błąd wczytywania pliku");
        }

        private void ListView_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }
    }
}
