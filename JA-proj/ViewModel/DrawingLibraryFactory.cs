using System;
using JA_proj.Model;
using JA_proj.NativeCodeBridge;

namespace JA_proj.ViewModel
{
    public class DrawingLibraryFactory
    {
        private static IDrawingLibrary GetDrawingLibraryFor(AlgorithmsImplementation implementation)
        {
            switch (implementation)
            {
                case AlgorithmsImplementation.ASM:
                    return null;
                case AlgorithmsImplementation.CPP:
                    return new CppAccesorLibrary();
                default:
                    throw new ArgumentOutOfRangeException("implementation");
            }
        }

        public static IFigureDrawer GetFigureDrawer(AlgorithmsImplementation choosenAlgotithm, int width, int height)
        {
            var drawer = GetDrawingLibraryFor(choosenAlgotithm);
            return new FigureDrawer(drawer, width, height);
        }
    }
}