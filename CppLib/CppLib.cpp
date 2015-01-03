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
			if (vertex[i].X  == vertex[j].X ) // jezeli pozioma linia
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
}
void FillPolygon(int numberOfIntersectionInRow, int * intersections, int max_x, int canvas[], int color, int row)
{
	int i, j, index;
	int offset = max_x * row;
	for (int i = 0; i < numberOfIntersectionInRow; i += 2)
	{
		int minX = intersections[i] < 0 ? 0 : intersections[i];
		int maxX = intersections[i + 1] > max_x ? max_x : intersections[i + 1];

		//if (intersections[i] >= max_x) break;
		for (int j = minX; j < maxX; j++)
		{
			int index = offset + j;
			canvas[index] = color;
		}
	}
}
bool IsInsideCircle(int centerX, int centerY, int radianSqrt, int x, int y)
{
	int part1 = (x - centerX);
	part1 *= part1;
	int part2 = (y - centerY);
	part2 *= part2;
	int sum = part1 + part2;
	return sum < radianSqrt;
}
extern "C" CPPLIB_API void DrawCircle(int bitmapArray[], int rowCount, int columnCount, unsigned int color, Vertex center, int radius)
{
	for (int row = 0; row < rowCount; row++)
	{
		int index;
		int radianSqrt = radius * radius;

		int minY = center.Y - radius;
		int maxY = center.X + radius;

		int endY = maxY < rowCount ? maxY : rowCount;
		int startY = minY > 0 ? minY : 0;

		for (int y = startY; y < endY; y++)
		{
			for (int x = 0; x < radius; x++)
			{
				if (IsInsideCircle(center.X, center.Y, radianSqrt, center.X + x, y))
				{
					int right = center.X + x;
					int left = center.X - x;

					if (left >= columnCount)
					{
						continue;
					}
					if (right < 0)
					{
						continue;
					}
					if (right < columnCount)
					{
						index = y * columnCount + right;
						bitmapArray[index] = color;
					}


					if (left >= 0)
					{
						index = y * columnCount + left;
						bitmapArray[index] = color;
					}
				}
			}
		}

	}
}

