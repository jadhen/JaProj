.686 
.387
.model flat, stdcall 
.xmm
.data
.code


;-------------Funkcja rysuj�ca wielok�t-----------------------;

DrawFigure proc uses ebx bitmapArray : PTR SDWORD, ;tablica reprezentuj�ca bitmap�
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

	mov 0, row
	
	;------g��wna p�tla programu
	cmp 

DrawFigure endp

end 