using System;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using GalaSoft.MvvmLight;
using GalaSoft.MvvmLight.Command;
using GalaSoft.MvvmLight.Messaging;
using JA_proj.Messages;
using JA_proj.Model;
using JA_proj.Properties;
using Microsoft.Win32;

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
        private readonly IFigureLoader figureLoader;
        private AlgorithmsImplementation choosenAlgotithm;
        private DrawingConfiguration drawingConfiguration;
        private string executionTime = "00:00";
        private string filePath;
        private RelayCommand loadXmlCommand;
        private int numberOfThreads = Environment.ProcessorCount;
        private BitmapSource outputImage;
        private RelayCommand runCommand;
        

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
            Placeholder = GetPlaceholder();
            OutputImage = Placeholder;
        }

        public BitmapSource Placeholder { get; set; }

        private BitmapSource GetPlaceholder()
        {
            var logo = new BitmapImage();
            logo.BeginInit();
            logo.UriSource = new Uri("pack://application:,,,/Assets/Placeholder.png");
            logo.EndInit();
            return logo;
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

        private string outputFilePath;

        public string OutputFilePath
        {
            get { return outputFilePath; }
            set { Set(() => OutputFilePath, ref outputFilePath, value); }
        }

        private bool autoNumberOfThreads = true;

        public bool AutoNumberOfThreads
        {
            get { return autoNumberOfThreads; }
            set
            {
                var wasSet = Set(() => AutoNumberOfThreads, ref autoNumberOfThreads, value);
                if (wasSet && value)
                {
                    SetDefault();
                }
            }
        }

        private void SetDefault()
        {
            numberOfThreads = Environment.ProcessorCount;
            RaisePropertyChanged(() => NumberOfThreads);
        }

        public int NumberOfThreads
        {
            get { return numberOfThreads; }
            set
            {
                var wasSet = Set(() => NumberOfThreads, ref numberOfThreads, value);
                if (wasSet)
                {
                    AutoNumberOfThreads = false;
                }
            }
        }


        public RelayCommand LoadFiguresCommand
        {
            get { return loadXmlCommand ?? (loadXmlCommand = new RelayCommand(LoadFigures)); }
        }

        public RelayCommand RunCommand
        {
            get { return runCommand ?? (runCommand = new RelayCommand(RunAlgorithm)); }
        }

        private RelayCommand saveBitmapCommand;

        public RelayCommand SaveBitmapCommand
        {
            get { return saveBitmapCommand ?? (saveBitmapCommand = new RelayCommand(SaveBitmap)); }
            set { Set(() => SaveBitmapCommand, ref saveBitmapCommand, value); }
        }


        /// <summary>
        /// </summary>
        public BitmapSource OutputImage
        {
            get { return outputImage; }
            set
            {
                Set(() => OutputImage, ref outputImage, value);
                if (outputImage == null)
                {
                    outputImage = Placeholder;
                    RaisePropertyChanged(() => OutputImage);
                }
            }
        }

        public DrawingConfiguration DrawingConfiguration
        {
            get { return drawingConfiguration; }
            set { Set(() => DrawingConfiguration, ref drawingConfiguration, value); }
        }

        public string ExecutionTime
        {
            get { return executionTime; }
            set { Set(() => ExecutionTime, ref executionTime, value); }
        }

        /// <summary>
        ///     G³ówna funkcja wywo³uj¹ca rysowanie figur
        /// </summary>
        private void RunAlgorithm()
        {
            try
            {
                IFigureDrawer drawer = DrawingLibraryFactory.GetFigureDrawer(choosenAlgotithm,
                    DrawingConfiguration.Width, DrawingConfiguration.Height);
                //pusta tablica do przechowywanie wyrysowanych figur
                int[] outputImageArray = drawer.GetEmptyBitmap();

                int figuresCount = DrawingConfiguration.Figures.Length;
                int threads = NumberOfThreads > figuresCount ? figuresCount : NumberOfThreads;
                //
                var figuresPerThread = (int) Math.Ceiling((double) figuresCount/threads);
                Stopwatch stopwatch = Stopwatch.StartNew();
                Parallel.For(0, NumberOfThreads, i =>
                {
                    int minIndex = i*figuresPerThread;
                    int maxIndex = minIndex + figuresPerThread;
                    maxIndex = maxIndex > figuresCount ? figuresCount : maxIndex;
                    for (int j = minIndex; j < maxIndex; j++)
                    {
                        Figure figure = DrawingConfiguration.Figures[j];
                        int[] imageArray = figure.Draw(drawer);
                        lock (outputImageArray)
                        {
                            ImageUtility.AddImageToImage(imageArray, outputImageArray);
                        }
                    }
                });
                stopwatch.Stop();
                OutputImage = ImageUtility.ConvertToImage(outputImageArray, DrawingConfiguration.Width,
                    DrawingConfiguration.Height);
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

        /// <summary>
        ///     Funkcja odpowiedzialna na odczytanie wysokoœci, szerokoœci obrazu i listy figur z pliku xml
        /// </summary>
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

        private void SaveBitmap()
        {
            var saveFileDialog = new SaveFileDialog();
            saveFileDialog.Filter = "bmp|*.bmp";
            var showDialog = saveFileDialog.ShowDialog();
            if (showDialog != null && showDialog.Value)
            {
                FilePath = saveFileDialog.FileName;
                ImageUtility.SaveBitmap(OutputImage, FilePath);
            }
        }
    }

    /// <summary>
    ///     Klasa dostarczaj¹ca potrzebnych operacji na obrazie w formacie BMP
    /// </summary>
    internal static class ImageUtility
    {
        /// <summary>
        ///     Funkcja nak³ada jeden obraz na drugi
        /// </summary>
        /// <param name="imageArray">obraz który chcemy nalo¿yæ</param>
        /// <param name="outputImage">obraz na który nak³adamy</param>
        public static void AddImageToImage(int[] imageArray, int[] outputImage)
        {
            for (int i = 0; i < imageArray.Length; i++)
            {
                uint alpha = ((uint) imageArray[i]) >> 24;
                if (alpha > 0)
                    outputImage[i] = imageArray[i];
            }
        }

        /// <summary>
        ///     Konwertujê tablicê intów w której przechowywujemy nasz obraz na obiekt klasy BitmapSource
        /// </summary>
        /// <param name="bitmapArray">tablica intów w której przechowywujemy nasz obraz</param>
        /// <param name="width">szerokoœæ obrazu</param>
        /// <param name="height">wysokoœæ obrazu</param>
        /// <returns>obiekt klasy BitmapSource odpowiedzilany za przechowywanie obrazu w formacie BMP</returns>
        public static BitmapSource ConvertToImage(int[] bitmapArray, int width, int height)
        {
            byte[] bytes = GetByteArrayFromIntArray(bitmapArray);
            PixelFormat format = PixelFormats.Pbgra32;
            int stride = width*format.BitsPerPixel/8;
            return BitmapSource.Create(width, height, 96, 96, format, null, bytes, stride);
        }

        /// <summary>
        ///     Konwertuje tablicê intów na tablicê bajtów
        /// </summary>
        /// <param name="intArray">tablica intów któr¹ chcemy przekonwertowaæ</param>
        /// <returns>tablicê bajtów utworzon¹ na podstawie tablicy intów przekazanej w paramentrze</returns>
        private static byte[] GetByteArrayFromIntArray(int[] intArray)
        {
            var data = new byte[intArray.Length*4];

            for (int i = 0; i < intArray.Length; i++)

                Array.Copy(BitConverter.GetBytes(intArray[i]), 0, data, i*4, 4);

            return data;
        }

        /// <summary>
        ///     Zapisuje bitmapê pod zdan¹ œcie¿k¹
        /// </summary>
        /// <param name="source">obiekt klasy BitmapSource z obrazem który chcemy zapisaæ</param>
        /// <param name="imagePath">œcie¿ka pod któr¹ chcemy zapisaæ obraz</param>
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