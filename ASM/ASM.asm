.686 
.387
.model flat, stdcall 
.xmm
.data
.code


;-------------Funkcja rysuj¹ca wielok¹t-----------------------;

DrawFigure proc uses ebx bitmapArray : PTR SDWORD, ;tablica reprezentuj¹ca bitmapê
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

	mov 0, row
	
	;------g³ówna pêtla programu
	cmp 

DrawFigure endp

end 