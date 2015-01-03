.686 
.387
.model flat, stdcall 
.xmm
.data
.code
;-------------wylicza przeciêcia danego wiersza z figur¹---------;
CalculateIntersections proc

CalculateIntersections endp
;-------------sortuje obliczone wierzcho³ki ----------------------;
SortIntersections proc

SortIntersections endp
;----------------wype³nia kolorem kolenjne obszary miêdzy przeciêciami-------;
FillPolygon proc

FillPolygon endp

;-------------Funkcja rysuj¹ca wielok¹t-----------------------;

DrawFigure proc uses EBX bitmapArray : PTR SDWORD, ;tablica reprezentuj¹ca bitmapê
	rowCount : SDWORD,		; wysokoœæ bitmapy
	columnCount : SDWORD,	; szerokoœæ bitmapy
	color :SDWORD,			; kolor wype³niania figury
	vertexTab : PTR VERTEX, ; tablica z wierzcho³kami
	vertexCount : SDWORD	; liczba wierzcho³ków
	;------zmienne
	local height : SDWORD ; zmienna reprezentuj¹ca wysokoœæ bitmapy
	local i : SWORD ; iterator
	local row : SDWORD ; licznik wierszy
	;------inicjalizacja
	mov eax, rowCount
	mov height, eax

	mov eax, 0
	mov row, eax
	
	;------g³ówna pêtla programu
	mov EBX, row 
	main_loop:
		cmp EBX, height ;warunek pêtli
		jge end_main_loop
	
;		invoke CalculateIntersections
	;	invoke SortIntersections
	;	invoke FillPolygon

		;----inkrementacja licznika wierszy i zapisanie go do rejestru EBX
		inc row
		mov EBX, row
	;------koniec g³ównej pêtli programu
	end_main_loop:
	ret
DrawFigure endp

DrawCircle proc bitmapArray : PTR SDWORD, rowCount:SDWORD, columnCount : SDWORD,  color : SDWORD,  center : VERTEX, radius: SDWORD
	mov eax, rowCount
	ret
DrawCircle endp
end 