// CppLib.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include "CppLib.h"

int CalculateIntersection(int row, int numberOfVertices, Vertex vertices[], int * intersections);
void SortIntersections(int numberOfIntersectionInRow, int * intersections);
void FillPolygon(int numberOfIntersectionInRow, int * intersections, int max_x, int bitmap[], int color, int row);

// This is an example of an exported function.
extern "C" CPPLIB_API void DrawFigure(int bitmapArray[], int rowCount, int columnCount, int color, Vertex vertexTab[], int verticesCount)
{
	int intersections[200];
	
	for (int row = 0; row < rowCount; row++)
	{
		
		int numberOfIntersectionInRow = CalculateIntersection(row, verticesCount, vertexTab, intersections);
		SortIntersections(numberOfIntersectionInRow, intersections);
		FillPolygon(numberOfIntersectionInRow, intersections, rowCount, bitmapArray, color, row);
	}
}
int CalculateIntersection(int row, int numberOfVertices, Vertex vertex[], int * intersections)
{
	int numberOfIntersections = 0;
	int j = numberOfVertices - 1;
	for (int i = 0; i < numberOfVertices; i++)
	{
		if ((vertex[i].Y  < row && vertex[j].Y  >= row) || (vertex[j].Y  < row && vertex[i].Y  >= row))
		{
			if (vertex[i].Y  == vertex[j].Y ) // jezeli pozioma linia
				intersections[numberOfIntersections++] = vertex[i].X ;
			else
			{
				double a = (vertex[j].Y  - vertex[i].Y ) / (double)(vertex[j].X  - vertex[i].X );
				double b = vertex[i].Y  - a * vertex[i].X ;
				intersections[numberOfIntersections++] = (int)((row - b) / a);
			}
		}
		j = i;
	}
	return numberOfIntersections; //zwraca liczbe przeciêæ z danym wierszem
}
void SortIntersections(int numberOfIntersectionInRow, int * intersections)
{
	int i = 0;
	int swap;
	while (i < numberOfIntersectionInRow - 1)
	{
		if (intersections[i] > intersections[i + 1])
		{
			swap = intersections[i];
			intersections[i] = intersections[i + 1];
			intersections[i + 1] = swap;
			if (i)
				i--;
		}
		else
			i++;
	}
	//po posortowaniu usuwamy powtarzj¹ce siê 
}
void FillPolygon(int numberOfIntersectionInRow, int * intersections, int max_x, int canvas[], int color, int row)
{
	int i, j, index;
	int offset = max_x * row;
	for (int i = 0; i < numberOfIntersectionInRow; i += 2)
	{
		//if (intersections[i] >= max_x) break;
		for (int j = intersections[i]; j <= intersections[i + 1]; j++)
		{
			int index = offset + j;
			canvas[index] = color;
		}
	}
}
//bool isVertex(int x, int y)
//{
//	for (int i = 0;  i < numberOfVertices; i++)
//	{
//		if (y == vertex_y[i] && x == vertex_x[i])
//			return true;
//	}
//	return false;
//}
