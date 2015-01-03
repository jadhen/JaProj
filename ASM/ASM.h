// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the ASM_EXPORTS
// symbol defined on the command line. This symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// ASM_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
#ifdef ASM_EXPORTS
#define ASM_API __declspec(dllexport)
#else
#define ASM_API __declspec(dllimport)
#endif

// This class is exported from the ASM.dll
class ASM_API CASM {
public:
	CASM(void);
	// TODO: add your methods here.
};

extern "C" ASM_API struct Vertex
{
	int X;
	int Y;
};
extern ASM_API int nASM;

ASM_API int fnASM(void);
extern "C" ASM_API void _stdcall DrawFigure(int bitmapArray[], int rowCount, int columnCount, int color, Vertex vertexTab[], int vertexCount);
extern "C" ASM_API void _stdcall DrawCircle(int bitmapArray[], int rowCount, int columnCount, int color, Vertex center, int radius);