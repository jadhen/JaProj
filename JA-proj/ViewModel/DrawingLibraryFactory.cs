using System;
using JA_proj.Model;
using JA_proj.NativeCodeBridge;

namespace JA_proj.ViewModel
{
    /// <summary>
    /// Fabryka obiektu odpowiedzialnego za konfigurację rysowania figur
    /// </summary>
    public class DrawingLibraryFactory
    {
        /// <summary>
        /// Na podstawie wybranej przez użytkownika implementacji algorytmu zwraca klasę dostepową do odpowiedniej implementacji
        /// </summary>
        /// <param name="implementation">wybrana implemencja przez użytkownika</param>
        /// <returns>klasę dostępową do wybranej implementacji algorytmu</returns>
        private static IDrawingLibrary GetDrawingLibraryFor(AlgorithmsImplementation implementation)
        {
            switch (implementation)
            {
                case AlgorithmsImplementation.ASM:
                    return new AsmLibraryAccesor();
                case AlgorithmsImplementation.CPP:
                    return new CppAccesorLibrary();
                default:
                    throw new ArgumentOutOfRangeException("implementation");
            }
        }
        /// <summary>
        /// Klasa zwraca klasę rysującą figurę o zadanych przez użytkownika parametrach
        /// </summary>
        /// <param name="choosenAlgotithm">wybrana implementacja algorytmu</param>
        /// <param name="width">szerokość obrazu</param>
        /// <param name="height">wysokość obrazu</param>
        /// <returns>klasę rysującą obraz o podanym wymiarze, wykorzystująca zadany algorytm</returns>
        public static IFigureDrawer GetFigureDrawer(AlgorithmsImplementation choosenAlgotithm, int width, int height)
        {
            var drawer = GetDrawingLibraryFor(choosenAlgotithm);
            return new FigureDrawer(drawer, width, height);
        }
    }
}