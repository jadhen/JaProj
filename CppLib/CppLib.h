// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the CPPLIB_EXPORTS
// symbol defined on the command line. This symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// CPPLIB_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
#ifdef CPPLIB_EXPORTS
#define CPPLIB_API __declspec(dllexport)
#else
#define CPPLIB_API __declspec(dllimport)
#endif

extern "C" CPPLIB_API struct Vertex
{
	int X;
	int Y;
};

extern "C" CPPLIB_API void DrawFigure(int bitmapArray[], int rowCount, int columnCount, int color, Vertex vertexTab[], int vertexCount);
extern "C" CPPLIB_API void DrawCircle(int bitmapArray[], int rowCount, int columnCount, int color, Vertex center, int radius);