// CPP.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include "CPP.h"


// This is an example of an exported variable
CPP_API int nCPP=0;

// This is an example of an exported function.
CPP_API int fnCPP(void)
{
	return 42;
}

// This is the constructor of a class that has been exported.
// see CPP.h for the class definition
CCPP::CCPP()
{
	return;
}
