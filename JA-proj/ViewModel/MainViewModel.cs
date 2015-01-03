using System;
using System.ComponentModel;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Documents.DocumentStructures;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using GalaSoft.MvvmLight;
using GalaSoft.MvvmLight.Command;
using GalaSoft.MvvmLight.Messaging;
using JA_proj.Messages;
using JA_proj.Model;
using Microsoft.Win32;
using System.Diagnostics;
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
        private int numberOfThreads = Environment.ProcessorCount;
        private string executionTime = "00:00";

        /// <summary>
        ///     Initializes a new instance of the MainViewModel class.
        /// </summary>
        public MainViewModel(IFigureLoader figureLoader)
        {
            this.figureLoader = figureLoader;
            ChoosenAlgotithm = AlgorithmsImplementation.CPP;
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
        /// <summary>
        /// 
        /// </summary>
        public BitmapSource OutputImage
        {
            get { return outputImage; }
            set { Set(() => OutputImage, ref outputImage, value); }
        }

        /// <summary>
        /// 
        /// </summary>
        private void RunAlgorithm()
        {
            try
            {

                
                var drawer = DrawingLibraryFactory.GetFigureDrawer(choosenAlgotithm, DrawingConfiguration.Width, DrawingConfiguration.Height );
                int[] outputImageArray = drawer.GetEmptyBitmap();

                int figuresCount = DrawingConfiguration.Figures.Length;
                var threads = NumberOfThreads > figuresCount ? figuresCount : NumberOfThreads;
                //
                var figuresPerThread = (int)Math.Ceiling((double) figuresCount / threads);
                Stopwatch stopwatch = Stopwatch.StartNew();
                Parallel.For(0, NumberOfThreads, (i) =>
                {
                    var minIndex = i*figuresPerThread;
                    var maxIndex = minIndex + figuresPerThread;
                    maxIndex = maxIndex > figuresCount ? figuresCount : maxIndex;
                    for (int j = minIndex; j < maxIndex; j++)
                    {
                        var figure = DrawingConfiguration.Figures[j];
                        var imageArray = figure.Draw(drawer);
                        lock (outputImageArray)
                        {
                            ImageUtility.AddImageToImage(imageArray, outputImageArray);
                        }
                    }
                    
                });
                stopwatch.Stop();
                OutputImage = ImageUtility.ConvertToImage(outputImageArray, DrawingConfiguration.Width, DrawingConfiguration.Height);
                ExecutionTime = stopwatch.Elapsed.Seconds + " : " + stopwatch.Elapsed.Milliseconds;
            }
            catch (Exception e)
            {
                var message = new NativeLibraryMessage();
                if (DrawingConfiguration == null || DrawingConfiguration.Figures == null)
                {
                    message.Message = "Proszê wczytaæ figury do narysowania";                     
                }
                else
                {
                    message.Message = "Nie mo¿na uruchomiæ biblioteki " + e.Message; 
                    
                }
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

        public string ExecutionTime
        {
            get { return executionTime ; }
            set
            {
                Set(() => ExecutionTime, ref executionTime, value); 
                
            }
        }
    }

    internal static class ImageUtility
    {
        /// <summary>
        /// 
        /// </summary>
        /// <param name="imageArray"></param>
        /// <param name="outputImage"></param>
        public static void AddImageToImage(int[] imageArray, int[] outputImage)
        {
            for (int i = 0; i < imageArray.Length; i++)
            {
                
                var alpha = ((uint)imageArray[i]) >> 24;
                if(alpha > 0)
                    outputImage[i] = imageArray[i];
            }
        }

        public static BitmapSource ConvertToImage(int[] bitmapArray, int width, int height)
        {
            var bytes = GetByteArrayFromIntArray(bitmapArray);
            var format = PixelFormats.Pbgra32;
            var stride = width * format.BitsPerPixel / 8;
            return BitmapSource.Create(width, height, 96, 96, format, null, bytes, stride);
        }

        private static byte[] GetByteArrayFromIntArray(int[] intArray)
        {

            byte[] data = new byte[intArray.Length * 4];

            for (int i = 0; i < intArray.Length; i++)

                Array.Copy(BitConverter.GetBytes(intArray[i]), 0, data, i * 4, 4);

            return data;

        }

        public static void SaveBitmap(BitmapSource source, string imagePath)
        {
            var stream = new FileStream(imagePath, FileMode.Create);
            var encoder = new PngBitmapEncoder();
            encoder.Interlace = PngInterlaceOption.On;

            encoder.Frames.Add(BitmapFrame.Create(source));

            encoder.Save(stream);
            stream.Close();    

        }
    }
}