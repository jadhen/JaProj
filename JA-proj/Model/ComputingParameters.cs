using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace JA_proj.Model
{
    class ComputingParameters
    {
        public String FilePath {
            get { return _filePath; }
            set { _filePath = value; }
        }
        public int ThreadsNumber {
            get { return _threadsNumber; }
            set { _threadsNumber = value; }
        }

        public AlgorithmsImplementation Implementation {
            get { return _algorithmImplementation; }
            set { _algorithmImplementation = value; }
        }

        private String _filePath;
        private int _threadsNumber;
        private AlgorithmsImplementation _algorithmImplementation;

        public string ToString()
        {
            return FilePath + " " + ThreadsNumber + " " + Implementation ;
        }
    }
}
