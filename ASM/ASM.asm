.686 
.387
.model flat, stdcall 
.xmm
.data
.code
;-------------wylicza przeci�cia danego wiersza z figur�---------;
CalculateIntersections proc

CalculateIntersections endp
;-------------sortuje obliczone wierzcho�ki ----------------------;
SortIntersections proc

SortIntersections endp
;----------------wype�nia kolorem kolenjne obszary mi�dzy przeci�ciami-------;
FillPolygon proc

FillPolygon endp

;-------------Funkcja rysuj�ca wielok�t-----------------------;

DrawFigure proc uses EBX bitmapArray : PTR SDWORD, ;tablica reprezentuj�ca bitmap�
	rowCount : SDWORD,		; wysoko�� bitmapy
	columnCount : SDWORD,	; szeroko�� bitmapy
	color :SDWORD,			; kolor wype�niania figury
	vertexTab : PTR VERTEX, ; tablica z wierzcho�kami
	vertexCount : SDWORD	; liczba wierzcho�k�w
	;------zmienne
	local height : SDWORD ; zmienna reprezentuj�ca wysoko�� bitmapy
	local i : SWORD ; iterator
	local row : SDWORD ; licznik wierszy
	;------inicjalizacja
	mov eax, rowCount
	mov height, eax

	mov eax, 0
	mov row, eax
	
	;------g��wna p�tla programu
	mov EBX, row 
	main_loop:
		cmp EBX, height ;warunek p�tli
		jge end_main_loop
	
;		invoke CalculateIntersections
	;	invoke SortIntersections
	;	invoke FillPolygon

		;----inkrementacja licznika wierszy i zapisanie go do rejestru EBX
		inc row
		mov EBX, row
	;------koniec g��wnej p�tli programu
	end_main_loop:
	ret
DrawFigure endp

DrawCircle proc bitmapArray : PTR SDWORD, rowCount:SDWORD, columnCount : SDWORD,  color : SDWORD,  center : VERTEX, radius: SDWORD
	mov eax, rowCount
	ret
DrawCircle endp
end 