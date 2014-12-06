using System.Windows.Documents.DocumentStructures;
using GalaSoft.MvvmLight;
using GalaSoft.MvvmLight.Command;
using JA_proj.Model;

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
                Figures = TemplateDataLoader.LoadTemplateFigures();
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

        private Figure[] figures;
        

        public Figure[] Figures
        {
            get { return figures; }
            set { Set(() => Figures, ref figures, value); }
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

        private void RunAlgorithm()
        {
            
        }

        private void LoadFigures()
        {
            Figures = figureLoader.LoadFromFile(FilePath);
        }
    }
}