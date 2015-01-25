.686 
.model flat, stdcall 
.xmm
.data
.code
VERTEX struct 
 x SDWORD ?
 y SDWORD ?
VERTEX ends
;-------------wylicza przeciêcia danego wiersza z figur¹---------;
CalculateIntersections proc uses EBX ECX EDX ESI EDI row : SDWORD,	; aktualnie przetwarzany wiersz
							numberOfVerticies : SDWORD,				; liczba wierzcho³ków
							vertexTab : PTR VERTEX,					; wskaŸnik na tablice wierzcho³ków
							intersections : PTR SDWORD				; wskaŸnik do tablicy z przeciêciami


	mov EBX, 0						; EBX - licznik wyznaczonych przeciêæ
	mov EDX, numberOfVerticies
	dec EDX							; EDX  - liczba wierzcho³ków - 1 -> j
	mov ECX, 0
	calculateIntersectionsLoop:		; pêtla po wszystkich wierzcho³kach
		cmp ECX, numberOFVerticies			; ECX - iterator po pêtli
		jge calculateIntersectionsLoop_end	; je¿eli ECX wiêksze równe liczba wierzcho³ków przerywamy obliczenia
		
		;--- sprawdzamy czy dany wiersz znajduje siê miêdzy badan¹ par¹ wierzcho³ków
		;--- tak bêdzie jezeli (row < vertex[i].y && row >= vertex[j].y) || (row >= vertex[i].y && row < vertex[j].y)
		;--- gdzie vertex[i] i vertex[j] to para kolejnych wierzcho³ków

		mov ESI, vertexTab			; ESI - wskaŸnik do tablicy wierzcho³ków
		assume ESI : PTR VERTEX
		mov EAX, [ESI + ECX * 8].y	; vertex ma rozmiar 8 bo 2xSDWORD, EAX = vertex[i].Y
		cmp EAX, row 
		jge secondCondition			;vertex[i].Y  >= row
			;--- spe³niony warunek vertex[i].Y  < row
			mov EAX, [ESI + EDX*8].y		; EAX = vertex[j].y
			cmp EAX, row
			jge rowBetweenTwoVerticies		; vertex[i].y  >= row --> wiersz pomiedzy dwoma wierzcho³kami
			jmp checkNextPairOfVerticies	; przejdŸ do porównania kolejnej pary wierzcho³ków

		secondCondition:
			;--- spe³niony warunek vertex[i].Y  >= row
			mov EAX, [ESI + EDX*8].y		; EAX = vertex[j].Y
			cmp EAX, row
			jl rowBetweenTwoVerticies		; vertex[j].y  < row --> wiersz pomiedzy dwoma wierzcho³kami
			jmp checkNextPairOfVerticies	; przejdŸ do porównania kolejnej pary wierzcho³ków

				rowBetweenTwoVerticies:
					;--- wiersz znajduje siê miêdzy dwoma wierzcho³kami - wyznaczmy wspó³rzêdn¹ x przeciêcia siê danego wiersza 
					;--- z prost¹ przechodz¹ca przez badane wierzcho³ki
					mov EAX, [ESI + ECX*8].x	; EAX = vertex[i].X
					cmp EAX, [ESI + EDX*8].x	; porównaj EAX z vertex[j].X
					je saveIntersection			; je¿eli punkty vertex[i] i  vertez[j] le¿¹ na poziomej linii to pomiñ wyznaczanie wspó³czynników, 
												; w EAX mamy zapisan¹ wartoœæ przeciêcia wiersza z prost¹
						
					;--- wierzcho³ki nie le¿¹ na poziomej linii
					;--- obliczmy wspó³czynnik nachylenia prostej a korzystaj¹c ze wzoru
					;--- double a = (vertex[j].Y  - vertex[i].Y ) / (double)(vertex[j].X  - vertex[i].X );
						
					mov EAX, [ESI + EDX*8].y	; EAX = vertex[j].y
					sub EAX, [ESI + ECX*8].y	; EAX = vertex[j].y - vertex[i].y
					cvtsi2sd xmm0, EAX			; XMMO = vertex[j].y - vertex[i].y
					mov EAX, [ESI + EDX*8].x	; EAX = vertex[j].y
					sub EAX, [ESI + ECX*8].x	; EAX = vertex[j].x - vertex[i].x
					cvtsi2sd xmm1, eax			; XMM1 = vertex[j].x - vertex[i].x
					divsd xmm0, xmm1			; XMM0 = a
						
					;--- obliczmamy wyraz wolny równania prostej korzystaj¹c ze wzoru
					;--- double b = vertex[i].Y  - a * vertex[i].X 

					cvtsi2sd xmm1, SDWORD PTR [ESI + ECX*8].x	; XMM1 = vertex[i].x
					mulsd xmm1, xmm0							; XMM1 = a* vertex[i].x
					cvtsi2sd xmm2, SDWORD PTR [ESI + ECX*8].y	; XMM2 = vertex[i].y
					subsd xmm2, xmm1							; XMM2 = b

					;--- wyznaczamy przeciêcie z danym werszem 
					;--- intersections[numberOfIntersections++] = (int)((row - b) / a);

					cvtsi2sd xmm1, row		; XMM1 = row
					subsd xmm1, xmm2		; XMM1 = row - b
					divsd xmm1, xmm0		; XMM1 = (row - b) / a
					cvttsd2si eax, xmm1		; EAX = (int) XMM1 
						 
			saveIntersection: 
				;--- w rejestrze eax mamy wyznaczon¹ wartoœæ przeciêcia prostej z danym wierszem
				;--- zapisz wyznaczone przeciêcie w tabeli z przeciêciami
				mov EDI, intersections		; w EDI adres tablicy intersections
				mov [EDI + EBX *4], EAX		; EAX =  wartoœæ do zapisania, intersections[numberOFVerticies] = vertex[i] || (row - b) / a .
				inc EBX						; zwiêksz o 1 liczbê wyznaczonych przeciêæ

		checkNextPairOfVerticies:			; przechodzimy do analizy nastêpnej pary elementów 
			mov EDX, ECX					; j = i
			inc ECX							; i++
			jmp CalculateIntersectionsLoop

	calculateIntersectionsLoop_end: 
		mov EAX, EBX						; w EAX liczba wyznaczonych przeciêæ	
		ret

CalculateIntersections endp
;-------------sortuje obliczone wierzcho³ki ----------------------;
SortIntersections proc uses EBX ECX EDX ESI EDI numberOfIntersections : SDWORD, ; liczba przecieæ w danym wierszu
												intersectionsTab : PTR SDWORD	; wskaŸnik do tablicy przeciêæ

	mov ECX, 0						; ECX -  iterator pêtli
	mov EBX, numberOfIntersections 
	dec EBX							; EBX = numberOfIntersections -1
	mov EDX, intersectionsTab		; EDX - adres tablicy z przecieciami 
	mainLoop: 
		cmp ECX, EBX				; je¿eli ECX > 	
		jge endMainLoop
			mov ESI, [EDX + ECX*4]		; ESI = intersections[i]
			mov EDI, [EDX + ECX*4+4]	; EDI = intersections[i+1]
			cmp ESI, EDI
			jle correctOrder ;nie trzeba zamieniaæ elementów
			;--- zamiana elementów
				mov [EDX + ECX*4], EDI
				mov [EDX + ECX*4+4], ESI
				cmp ECX, 0 ; if(i == 0)
				jz mainLoop
					dec ECX
				jmp mainLoop
			correctOrder:
				inc ECX
				jmp MainLoop

	endMainLoop:
		ret
		
						
 ret
SortIntersections endp

;----------------wype³nia kolorem kolenjne obszary miêdzy przeciêciami-------;
FillPolygon proc uses EBX ECX EDX ESI EDI	numberOfIntersections : SDWORD, ; liczba przecieæ w wierzu
											intersectionsTab : PTR SDWORD, ; wskaŸnik do tablicy w wyznaczonymi przeciêciami
											maxX : SDWORD, ; szerokoœæ obrazu
											bitmapArray : PTR SDWORD, ; wskaŸnik do tablicy w obrazem
											color : SDWORD, ; kolor którym bêdziemy wype³niaæ figure
											row : SDWORD ; numer wiersza który wpe³niamy
	
	
	mov EDX, 0					; EDX- licznik pêtli	
	mov ESI, intersectionsTab	; ESI - wskaŸnik na tablice z przecieciami
	assume ESI : PTR SDWORD
	fillLoop:							; pêtla po wszystkich przeciêciach
		cmp EDX, numberOfIntersections
		jge endFillLoop
		mov EAX, 0
		; if intersection[i] < 0 then intersection[i] = 0 - ¿eby nie rysowaæ poza obszarem obrazu 
		cmp EAX, [ESI + EDX*4]
			cmovl EAX, [ESI + EDX*4]
		; if intersection[i+1] > maxX then intersection[i+1] = maxX - ¿eby nie rysowaæ poza obrazem
		mov ECX, [ESI + EDX*4+4]
		cmp ECX,  maxX
			CMOVG ECX, maxX				 
		;---------przygotowanie pod operacje ³añcuchowe
		sub ECX, EAX					; ECX -licznik dla operacji ³añcuchowej - liczba punktów do pomalowania
		mov EBX, maxX
		imul EBX, row					; EBX - offset
		add EBX, EAX					; EBX = offset + minX
		imul EBX,  4					; EBX = 4(offset+minX) odwo³ujemy sie do elementu [EDI + 4(offset+min)]
		mov EDI, bitmapArray			; EDI -addres bitmapy
		add EDI, EBX					; adres od którego kolorujemy w EDI
		mov EAX, color
		; wype³nianie obszaru miedzy przecieciami 
		rep stosd							
		add EDX, 2 ; inkrementacja licznika petli
		jmp fillLoop;
	endFillLoop:		
		ret
FillPolygon endp


;-------------Funkcja rysuj¹ca wielok¹t-----------------------;

DrawFigure proc uses EBX ECX EDX ESI EDI bitmapArray : PTR SDWORD,	; tablica reprezentuj¹ca bitmapê
										 rowCount : SDWORD,			; wysokoœæ bitmapy
										 columnCount : SDWORD,		; szerokoœæ bitmapy
										 color :SDWORD,				; kolor wype³niania figury
										 vertexTab : PTR VERTEX,	; tablica z wierzcho³kami
										 vertexCount : SDWORD		; liczba wierzcho³ków
	
	;--- zmienne lokalne
	local height : SDWORD						; zmienna reprezentuj¹ca wysokoœæ bitmapy
	local i : SWORD								; iterator
	local numberOfIntersectionsInRow : SDWORD	; liczba przeciêæ wyznaczona w danym wierszu 
	local intersections[200] : SDWORD			; tablica przechowywuj¹ca wyznaczone przeciêcia
	
	;--- inicjalizacja lokalnych zmiennych
	mov EAX, rowCount
	mov height, EAX

	;------g³ówna pêtla programu
	mov EBX, 0				; EBX licznik rzedow	
	mov esi, bitmapArray	; wpisanie do ESI adresu tablicy w której prxehowywujemy wyrysowany obraz
	
	main_loop:
		cmp EBX, height				; warunek pêtli
		jge end_main_loop
		mov EDX, vertexTab			; EDX - adres tablicy z przeciêciami
		;--- wyznacz przeciêcia dla danego wiersza
		invoke CalculateIntersections, EBX, vertexCount, EDX, addr intersections
		mov numberOfIntersectionsInRow, EAX		; w EAX zwrócna wartoœæ przez funkcje CalculateIntersections, czyli liczba wyznaczonych przeciêæ
		;--- sortuj wyznaczone przeciêcia
		invoke SortIntersections , numberOfIntersectionsInRow, addr intersections
		;--- wype³nij wiersz kolorem
		invoke FillPolygon ,numberOfIntersectionsInRow, addr intersections, columnCount, bitmapArray, color, EBX
	
		;----inkrementacja licznika wierszy i zapisanie go do rejestru EBX
		inc EBX
		jmp main_loop
	;------koniec g³ównej pêtli programu
	end_main_loop:
	ret
DrawFigure endp

;--- funkcja sprawdza czy dany punkt jest wewn¹trz okrêgu
IsInsideCircle proc uses EBX ECX EDX	centerX : SDWORD, ; wspó³rzêdna x œrodka okrêgu
										centerY : SDWORD, ; wspó³rzêdna y œrodka okrêgu
										radiusSqr : SDWORD, ; kwadrat promienia okrêgu
										x : SDWORD, ; wspó³rzêdna x przetwarzanego punktu
										y : SDWORD ; wspó³rzêdna y przetwarzanego punktu
	
	mov EAX, x 
	sub EAX, centerX	; EAX = x - center.X
	mul EAX				; EAX = sqr(eax)
	mov EBX, EAX		; EBX = sqr(x - center.X)
	mov EAX, y
	sub EAX, centerY	; EAX = y - centerY
	mul EAX				; EAX = sqr(y - center.Y)
	add EAX, EBX		; EAX = sqr(x - center.X) + sqr(y- center.Y)
		cmp EAX, radiusSqr
		jge false
		mov EAX, 1		; obszar wewn¹trz okregu, poniewa¿ sqr(x - center.X) + sqr(y- center.Y) < radiusSqr
		ret
	false: 
		mov EAX, 0		; punkt poza okrêgiem, poniewa¿ sqr(x - center.X) + sqr(y- center.Y) >= radiusSqr
		ret		
							
IsInsideCircle endp	

;--- funkcja rysuj¹ca okr¹g-------------------------------------------------------------------------
DrawCircle proc uses EBX ECX EDX ESI EDI	bitmapArray : PTR SDWORD, ; wskaŸnik do tablicy z obrazem
											rowCount:SDWORD, ; liczba wierszy -> wysokoœæ obrazu
											columnCount : SDWORD,  ; liczba kolumn -> szerokoœæ wykresu
											color : SDWORD,  ; kolor wype³nienia figury
											center : VERTEX, ; wspó³rzedna œrodka okrêgu
											radius: SDWORD ; prominieñ okrêgu
	
	;--- zmienne lokalne
	local minY : SDWORD			; najbardziej wysuniêty w dó³ punkt okrêgu
	local maxY : SDWORD			; najbardziej wysuniêty w górê lewo punkt okrêgu
	
	mov ESI, bitmapArray	; w ESI wskaŸnik do tablicy z obrazem 
	assume ESI :  PTR SDWORD
	mov EBX, center.y
	sub EBX, radius			; EBX = minY
	mov EDX, center.y 
	add EDX, radius			; EDX = maxY
	mov EAX, 0
	; wyznaczamy skrajne punkty okrêgu w pionie
	cmp EBX, EAX
		cmovl EBX, EAX		; if ebx < 0 ? ebx = 0 ebx =startY
	cmp EDX, rowCount
		cmovg EDX, rowCount ; if edx > rowCount ? edx = rowCount ; edx = endY
	mov maxY, EDX 
	
	; g³ówna pêtla wype³niaj¹ca okr¹g, przechodz¹ca po wspó³rzêdnych y
	; nie musimy przechodziæ po wszystkich wspó³rzêdnych y, wystarczy przejœæ po y nale¿¹cych do zbioru <minY,maxY>
	fillLoop: 
		; for (int y = startY; y < endY; y++). EBX = minY, EBX - licznik pêtli po wierszach
		cmp EBX, maxY		
		jge endFillLoop
			mov minY, EBX 
			mov ECX, 0 

			; pêtla wewnêtrza przemieszczaj¹ca siê po punktach z zbioru 
			; <center.x-radius , center.x + radius> dla danego wiersza
			innerLoop:     
				cmp ECX, radius 
				jge endInnerLoop
					mov EDX, center.x 
					mov EAX, radius
					mul radius			; EAX = sqr(radius)
					mov EDI, center.x 
					add EDI, ECX		; EDI = center.x + x

					;sprawdzamy czy dany punkt nale¿y do okrêgu
					invoke IsInsideCircle, center.x, center.y, EAX, EDI, minY
					cmp EAX, 0			; w EAX zapisano wartoœæ 1/0 odowiednio gdy punkt znajduje / nie znajduje siê wewn¹trz okrêgu 
					je nextInnerLoop	; je¿eli punkt nie znajduje sie wewn¹trz okregu, przejdŸ dalej 
						; 
						mov EDX, center.x 
						sub EDX, ECX			; EDX = center.x-x 
						cmp EDX, columnCount
						jge nextInnerLoop		; je¿eli center.x -x jest wiêksza do iloœci kolumn (czyli maksymalnej wartoœci x) to przejdŸ do nastêpnego punktu
						mov EDX, center.x 
						sub EDX, ECX			; EDX = center.x-x 
						cmp EDI, 0				; EDI = center.x + x
						jl nextInnerLoop		; je¿eli center.x + x < 0 przejdŸ do nastêpnego punktu
						cmp EDI, columnCount	
						jge nextCondition		; je¿eli center.x+x > columnCount, sprawdŸ czy mo¿na pomalowaæ punkt center.x -x
							; punkt o wspó³rzêdych center.x + x mo¿na kolorowaæ bo nale¿y do okrêgu i znajduje siê na obrazie
							mov EAX, columnCount
							mul EBX
							add EAX, EDI		; EAX = index + center.x + x
							mov EBX, color
							mov [ESI + EAX*4], EBX
							mov EBX, minY
					nextCondition:
						;mov EDI, center.x 
						;add EDI, ECX			; EDI = center.x + x
						cmp EDX, 0
						jl nextInnerLoop
							; punkt o wspó³rzêdych center.x - x mo¿na kolorowaæ bo nale¿y do okrêgu i znajduje siê na obrazie
							mov EAX, columnCount
							mul EBX				; EAX = index 
							mov EDX, center.x 
							sub EDX, ECX		; EDX = center.x-x 
							add EAX, EDX		; EAX = index + center.x - x
							mov EBX, color
							mov [ESI + EAX*4], EBX		

					nextInnerLooP:
						inc ECX					; zwiekszenie licznika wewnêtrzenej pêtli
						mov EBX, minY 
						jmp innerLoop			; powrót do pocz¹tku wewnêtrznej pêtli 
	
			endInnerLoop:
				inc EBX			; zinkrementowanie licznika g³ónej pêtli 
				jmp fillLoop	; kolejna iteracja g³ównej pêtli

	endFillLoop:
		ret
DrawCircle endp
end 