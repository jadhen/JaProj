using System;
using System.ComponentModel;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Windows.Documents.DocumentStructures;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using GalaSoft.MvvmLight;
using GalaSoft.MvvmLight.Command;
using GalaSoft.MvvmLight.Messaging;
using JA_proj.Messages;
using JA_proj.Model;
using Microsoft.Win32;
using Image = System.Windows.Controls.Image;

namespace JA_proj.ViewModel
{
    /// <summary>
    ///     This class contains properties that the main View can data bind to.
    ///     <para>
    ///         Use the <strong>mvvminpc</strong> snippet to add bindable properties to this ViewModel.
    ///     </para>
    ///     <para>
    ///         You can also use Blend to data bind with the tool's support.
    ///     </para>
    ///     <para>
    ///         See http://www.galasoft.ch/mvvm
    ///     </para>
    /// </summary>
    public class MainViewModel : ViewModelBase
    {
        private AlgorithmsImplementation choosenAlgotithm;
        private IFigureLoader figureLoader;
        private string filePath;
        private int numberOfThreads;

        /// <summary>
        ///     Initializes a new instance of the MainViewModel class.
        /// </summary>
        public MainViewModel(IFigureLoader figureLoader)
        {
            this.figureLoader = figureLoader;
            if (IsInDesignMode)
            {
                DrawingConfiguration = TemplateDataLoader.LoadTemplateFigures();
            }

        }

        public AlgorithmsImplementation ChoosenAlgotithm
        {
            get { return choosenAlgotithm; }
            set { Set(() => ChoosenAlgotithm, ref choosenAlgotithm, value); }
        }

        public string FilePath
        {
            get { return filePath; }
            set { Set(() => FilePath, ref filePath, value); }
        }


        public int NumberOfThreads
        {
            get { return numberOfThreads; }
            set { Set(() => NumberOfThreads, ref numberOfThreads, value); }
        }


        private RelayCommand loadXmlCommand;
        public RelayCommand LoadFiguresCommand
        {
            get
            {
                return loadXmlCommand ?? (loadXmlCommand = new RelayCommand(LoadFigures));         
            }
        }

        private RelayCommand runCommand;

        public RelayCommand RunCommand
        {
            get { return runCommand ?? (runCommand = new RelayCommand(RunAlgorithm)); }
        }

        private BitmapSource outputImage;
        private DrawingConfiguration drawingConfiguration;

        public BitmapSource OutputImage
        {
            get { return outputImage; }
            set { Set(() => OutputImage, ref outputImage, value); }
        }


        private void RunAlgorithm()
        {
            try
            {
                var drawer = DrawingLibraryFactory.GetFigureDrawer(choosenAlgotithm, DrawingConfiguration.Width, DrawingConfiguration.Height );
                var stream = new FileStream("new.png", FileMode.Create);
                var encoder = new PngBitmapEncoder();
                foreach (var figure in DrawingConfiguration.Figures)
                {
                    encoder.Interlace = PngInterlaceOption.On;
                    OutputImage = figure.Draw(drawer);
                    encoder.Frames.Add(BitmapFrame.Create(OutputImage));                
                }
                encoder.Save(stream);
                stream.Close();    
                
            }
            catch (Exception e)
            {
                var message = new NativeLibraryMessage();
                message.Message = "Nie mo¿na uruchomiæ biblioteki " + e.Message; 
                Messenger.Default.Send(message);
            }
        }

        private void LoadFigures()
        {
            var openFileDialog = new OpenFileDialog();
            openFileDialog.Filter = "XmlFile|*.xml";
            if (openFileDialog.ShowDialog().Value)
            {
                FilePath = openFileDialog.FileName;
                try
                {
                    DrawingConfiguration = figureLoader.LoadFromFile(FilePath);
                    
                }
                catch (Exception e)
                {
                    var xmlMessage = new InvalidXmlMessage("Nie mo¿na by³o wczytaæ podanego pliku");
                    Messenger.Default.Send(xmlMessage);  
                }
            }
        }

        public DrawingConfiguration DrawingConfiguration
        {
            get { return drawingConfiguration; }
            set
            {
                Set(() => DrawingConfiguration, ref drawingConfiguration, value);
            }
        }
    }
}