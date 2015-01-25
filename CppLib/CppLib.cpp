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
	//tabela z wyznaczonymi przeci�ciami w danym rzedzie.
	//maksymalna liczba przeci�� w danym rz�dzie wynosi 200
	int intersections[200];
	
	for (int row = 0; row < rowCount; row++)
	{
		int numberOfIntersectionInRow = CalculateIntersection(row, verticesCount, vertexTab, intersections);
		SortIntersections(numberOfIntersectionInRow, intersections);
		FillPolygon(numberOfIntersectionInRow, intersections, columnCount, bitmapArray, color, row);
	}
}

//Funckja wyznaczaj�ca przeci�cia w danym wierszu. Funkcja zwraca liczb� wyznaczonych przeci�� w danym wierszu
//int row - numer wiersza dla kt�rego wyznaczamy przeci�cie
//int numberOfVertices - liczba wierzcho�k�w danej figury
//Vertex vertex [] - tablica z wierzcho�kami danej figury
// int * intersections - wska�nik do tabeli w kt�rej zapisujemy wyznaczone przeci�cia z danym wierszem
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
	return numberOfIntersections; 
}
//Funckja sortuje rosn�co wyznaczone przeci�cia korzystaj�c z algorytmu sortowania b�belkowego
//int numberOfIntersectionInRow - liczba wyznaczonych przeci�� dla danego wiersza
// int * intersections - wska�nik na tablic� z wyznaczonymi przeci�ciami
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
//Funkcja wype�niaj�ca pojedy�czy wiersz bitmapy
//int numberOfIntersectionInRow - liczba wyznaczonych przeci�� dla danego wiersza
//int * intersections - tablica z wyznaczonymi przeci�ciami dla danego wiersza
//int width - szeroko�� bitmapy, czyli te� maksymalna warto�� jak� mo�e przyj�� wsp�rz�dna x
//int canvas[] - tablica w kt�rej przechowywujemy wyrysowan� figur�
//int color - kolor wype�nienia
//int row - numer wype�nianego wiersza
void FillPolygon(int numberOfIntersectionInRow, int * intersections, int width, int canvas[], int color, int row)
{
	int i, j, index;
	int offset = width * row;
	for (int i = 0; i < numberOfIntersectionInRow; i += 2)
	{
		//sprawdzamy czy przeci�cia nie wystaj� poza obszar bitmapy czyli czy znajduj� si� w zakresie <0, width>
		int minX = intersections[i] < 0 ? 0 : intersections[i];
		int maxX = intersections[i + 1] > width ? width : intersections[i + 1];
		//dla punkt�w mi�dzy par� kolejnych przeci�� -> wype�nij je kolorem
		for (int j = minX; j < maxX; j++)
		{
			int index = offset + j;
			canvas[index] = color;
		}
	}
}
//Fukcja sprawdza czy punkt o wsp�rz�dnych (x,y) znajduje si� wewn�trz okr�gu o �rodku w punkcie (centerX, centerY) i  o promieniu radian. 
//Badamy warunek czy sqr(x-centerX) + sqr(y-centerY) < srq(radian)
//int centerX - wsp�rz�dna x �rodka ko�a
// int centerY - wsp�rz�dna y �rodka okr�gu
// int radianSqr - kwadrat promienia okr�gu
// int x - wsp�rz�dna x badanego punktu
//int y - wsp�rz�dna y badanego punktu
bool IsInsideCircle(int centerX, int centerY, int radiusSqr, int x, int y)
{
	int part1 = (x - centerX);
	part1 *= part1;
	int part2 = (y - centerY);
	part2 *= part2;
	int sum = part1 + part2;
	return sum < radiusSqr;
}
extern "C" CPPLIB_API void DrawCircle(int bitmapArray[], int rowCount, int columnCount, int color, Vertex center, int radius)
{

		int index;
		int radiusSqr = radius*radius;

		int minY = center.Y - radius;
		int maxY = center.Y + radius;

		int endY = maxY < rowCount ? maxY : rowCount;
		int startY = minY > 0 ? minY : 0;

		for (int y = startY; y < endY; y++)
		{
			for (int x = 0; x < radius; x++)
			{
				if (IsInsideCircle(center.X, center.Y, radiusSqr, center.X + x, y))
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


