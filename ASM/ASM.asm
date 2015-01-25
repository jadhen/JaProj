.686 
.model flat, stdcall 
.xmm
.data
.code
VERTEX struct 
 x SDWORD ?
 y SDWORD ?
VERTEX ends
;-------------wylicza przeci�cia danego wiersza z figur�---------;
CalculateIntersections proc uses EBX ECX EDX ESI EDI row : SDWORD,	; aktualnie przetwarzany wiersz
							numberOfVerticies : SDWORD,				; liczba wierzcho�k�w
							vertexTab : PTR VERTEX,					; wska�nik na tablice wierzcho�k�w
							intersections : PTR SDWORD				; wska�nik do tablicy z przeci�ciami


	mov EBX, 0						; EBX - licznik wyznaczonych przeci��
	mov EDX, numberOfVerticies
	dec EDX							; EDX  - liczba wierzcho�k�w - 1 -> j
	mov ECX, 0
	calculateIntersectionsLoop:		; p�tla po wszystkich wierzcho�kach
		cmp ECX, numberOFVerticies			; ECX - iterator po p�tli
		jge calculateIntersectionsLoop_end	; je�eli ECX wi�ksze r�wne liczba wierzcho�k�w przerywamy obliczenia
		
		;--- sprawdzamy czy dany wiersz znajduje si� mi�dzy badan� par� wierzcho�k�w
		;--- tak b�dzie jezeli (row < vertex[i].y && row >= vertex[j].y) || (row >= vertex[i].y && row < vertex[j].y)
		;--- gdzie vertex[i] i vertex[j] to para kolejnych wierzcho�k�w

		mov ESI, vertexTab			; ESI - wska�nik do tablicy wierzcho�k�w
		assume ESI : PTR VERTEX
		mov EAX, [ESI + ECX * 8].y	; vertex ma rozmiar 8 bo 2xSDWORD, EAX = vertex[i].Y
		cmp EAX, row 
		jge secondCondition			;vertex[i].Y  >= row
			;--- spe�niony warunek vertex[i].Y  < row
			mov EAX, [ESI + EDX*8].y		; EAX = vertex[j].y
			cmp EAX, row
			jge rowBetweenTwoVerticies		; vertex[i].y  >= row --> wiersz pomiedzy dwoma wierzcho�kami
			jmp checkNextPairOfVerticies	; przejd� do por�wnania kolejnej pary wierzcho�k�w

		secondCondition:
			;--- spe�niony warunek vertex[i].Y  >= row
			mov EAX, [ESI + EDX*8].y		; EAX = vertex[j].Y
			cmp EAX, row
			jl rowBetweenTwoVerticies		; vertex[j].y  < row --> wiersz pomiedzy dwoma wierzcho�kami
			jmp checkNextPairOfVerticies	; przejd� do por�wnania kolejnej pary wierzcho�k�w

				rowBetweenTwoVerticies:
					;--- wiersz znajduje si� mi�dzy dwoma wierzcho�kami - wyznaczmy wsp�rz�dn� x przeci�cia si� danego wiersza 
					;--- z prost� przechodz�ca przez badane wierzcho�ki
					mov EAX, [ESI + ECX*8].x	; EAX = vertex[i].X
					cmp EAX, [ESI + EDX*8].x	; por�wnaj EAX z vertex[j].X
					je saveIntersection			; je�eli punkty vertex[i] i  vertez[j] le�� na poziomej linii to pomi� wyznaczanie wsp�czynnik�w, 
												; w EAX mamy zapisan� warto�� przeci�cia wiersza z prost�
						
					;--- wierzcho�ki nie le�� na poziomej linii
					;--- obliczmy wsp�czynnik nachylenia prostej a korzystaj�c ze wzoru
					;--- double a = (vertex[j].Y  - vertex[i].Y ) / (double)(vertex[j].X  - vertex[i].X );
						
					mov EAX, [ESI + EDX*8].y	; EAX = vertex[j].y
					sub EAX, [ESI + ECX*8].y	; EAX = vertex[j].y - vertex[i].y
					cvtsi2sd xmm0, EAX			; XMMO = vertex[j].y - vertex[i].y
					mov EAX, [ESI + EDX*8].x	; EAX = vertex[j].y
					sub EAX, [ESI + ECX*8].x	; EAX = vertex[j].x - vertex[i].x
					cvtsi2sd xmm1, eax			; XMM1 = vertex[j].x - vertex[i].x
					divsd xmm0, xmm1			; XMM0 = a
						
					;--- obliczmamy wyraz wolny r�wnania prostej korzystaj�c ze wzoru
					;--- double b = vertex[i].Y  - a * vertex[i].X 

					cvtsi2sd xmm1, SDWORD PTR [ESI + ECX*8].x	; XMM1 = vertex[i].x
					mulsd xmm1, xmm0							; XMM1 = a* vertex[i].x
					cvtsi2sd xmm2, SDWORD PTR [ESI + ECX*8].y	; XMM2 = vertex[i].y
					subsd xmm2, xmm1							; XMM2 = b

					;--- wyznaczamy przeci�cie z danym werszem 
					;--- intersections[numberOfIntersections++] = (int)((row - b) / a);

					cvtsi2sd xmm1, row		; XMM1 = row
					subsd xmm1, xmm2		; XMM1 = row - b
					divsd xmm1, xmm0		; XMM1 = (row - b) / a
					cvttsd2si eax, xmm1		; EAX = (int) XMM1 
						 
			saveIntersection: 
				;--- w rejestrze eax mamy wyznaczon� warto�� przeci�cia prostej z danym wierszem
				;--- zapisz wyznaczone przeci�cie w tabeli z przeci�ciami
				mov EDI, intersections		; w EDI adres tablicy intersections
				mov [EDI + EBX *4], EAX		; EAX =  warto�� do zapisania, intersections[numberOFVerticies] = vertex[i] || (row - b) / a .
				inc EBX						; zwi�ksz o 1 liczb� wyznaczonych przeci��

		checkNextPairOfVerticies:			; przechodzimy do analizy nast�pnej pary element�w 
			mov EDX, ECX					; j = i
			inc ECX							; i++
			jmp CalculateIntersectionsLoop

	calculateIntersectionsLoop_end: 
		mov EAX, EBX						; w EAX liczba wyznaczonych przeci��	
		ret

CalculateIntersections endp
;-------------sortuje obliczone wierzcho�ki ----------------------;
SortIntersections proc uses EBX ECX EDX ESI EDI numberOfIntersections : SDWORD, ; liczba przecie� w danym wierszu
												intersectionsTab : PTR SDWORD	; wska�nik do tablicy przeci��

	mov ECX, 0						; ECX -  iterator p�tli
	mov EBX, numberOfIntersections 
	dec EBX							; EBX = numberOfIntersections -1
	mov EDX, intersectionsTab		; EDX - adres tablicy z przecieciami 
	mainLoop: 
		cmp ECX, EBX				; je�eli ECX > 	
		jge endMainLoop
			mov ESI, [EDX + ECX*4]		; ESI = intersections[i]
			mov EDI, [EDX + ECX*4+4]	; EDI = intersections[i+1]
			cmp ESI, EDI
			jle correctOrder ;nie trzeba zamienia� element�w
			;--- zamiana element�w
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

;----------------wype�nia kolorem kolenjne obszary mi�dzy przeci�ciami-------;
FillPolygon proc uses EBX ECX EDX ESI EDI	numberOfIntersections : SDWORD, ; liczba przecie� w wierzu
											intersectionsTab : PTR SDWORD, ; wska�nik do tablicy w wyznaczonymi przeci�ciami
											maxX : SDWORD, ; szeroko�� obrazu
											bitmapArray : PTR SDWORD, ; wska�nik do tablicy w obrazem
											color : SDWORD, ; kolor kt�rym b�dziemy wype�nia� figure
											row : SDWORD ; numer wiersza kt�ry wpe�niamy
	
	
	mov EDX, 0					; EDX- licznik p�tli	
	mov ESI, intersectionsTab	; ESI - wska�nik na tablice z przecieciami
	assume ESI : PTR SDWORD
	fillLoop:							; p�tla po wszystkich przeci�ciach
		cmp EDX, numberOfIntersections
		jge endFillLoop
		mov EAX, 0
		; if intersection[i] < 0 then intersection[i] = 0 - �eby nie rysowa� poza obszarem obrazu 
		cmp EAX, [ESI + EDX*4]
			cmovl EAX, [ESI + EDX*4]
		; if intersection[i+1] > maxX then intersection[i+1] = maxX - �eby nie rysowa� poza obrazem
		mov ECX, [ESI + EDX*4+4]
		cmp ECX,  maxX
			CMOVG ECX, maxX				 
		;---------przygotowanie pod operacje �a�cuchowe
		sub ECX, EAX					; ECX -licznik dla operacji �a�cuchowej - liczba punkt�w do pomalowania
		mov EBX, maxX
		imul EBX, row					; EBX - offset
		add EBX, EAX					; EBX = offset + minX
		imul EBX,  4					; EBX = 4(offset+minX) odwo�ujemy sie do elementu [EDI + 4(offset+min)]
		mov EDI, bitmapArray			; EDI -addres bitmapy
		add EDI, EBX					; adres od kt�rego kolorujemy w EDI
		mov EAX, color
		; wype�nianie obszaru miedzy przecieciami 
		rep stosd							
		add EDX, 2 ; inkrementacja licznika petli
		jmp fillLoop;
	endFillLoop:		
		ret
FillPolygon endp


;-------------Funkcja rysuj�ca wielok�t-----------------------;

DrawFigure proc uses EBX ECX EDX ESI EDI bitmapArray : PTR SDWORD,	; tablica reprezentuj�ca bitmap�
										 rowCount : SDWORD,			; wysoko�� bitmapy
										 columnCount : SDWORD,		; szeroko�� bitmapy
										 color :SDWORD,				; kolor wype�niania figury
										 vertexTab : PTR VERTEX,	; tablica z wierzcho�kami
										 vertexCount : SDWORD		; liczba wierzcho�k�w
	
	;--- zmienne lokalne
	local height : SDWORD						; zmienna reprezentuj�ca wysoko�� bitmapy
	local i : SWORD								; iterator
	local numberOfIntersectionsInRow : SDWORD	; liczba przeci�� wyznaczona w danym wierszu 
	local intersections[200] : SDWORD			; tablica przechowywuj�ca wyznaczone przeci�cia
	
	;--- inicjalizacja lokalnych zmiennych
	mov EAX, rowCount
	mov height, EAX

	;------g��wna p�tla programu
	mov EBX, 0				; EBX licznik rzedow	
	mov esi, bitmapArray	; wpisanie do ESI adresu tablicy w kt�rej prxehowywujemy wyrysowany obraz
	
	main_loop:
		cmp EBX, height				; warunek p�tli
		jge end_main_loop
		mov EDX, vertexTab			; EDX - adres tablicy z przeci�ciami
		;--- wyznacz przeci�cia dla danego wiersza
		invoke CalculateIntersections, EBX, vertexCount, EDX, addr intersections
		mov numberOfIntersectionsInRow, EAX		; w EAX zwr�cna warto�� przez funkcje CalculateIntersections, czyli liczba wyznaczonych przeci��
		;--- sortuj wyznaczone przeci�cia
		invoke SortIntersections , numberOfIntersectionsInRow, addr intersections
		;--- wype�nij wiersz kolorem
		invoke FillPolygon ,numberOfIntersectionsInRow, addr intersections, columnCount, bitmapArray, color, EBX
	
		;----inkrementacja licznika wierszy i zapisanie go do rejestru EBX
		inc EBX
		jmp main_loop
	;------koniec g��wnej p�tli programu
	end_main_loop:
	ret
DrawFigure endp

;--- funkcja sprawdza czy dany punkt jest wewn�trz okr�gu
IsInsideCircle proc uses EBX ECX EDX	centerX : SDWORD, ; wsp�rz�dna x �rodka okr�gu
										centerY : SDWORD, ; wsp�rz�dna y �rodka okr�gu
										radiusSqr : SDWORD, ; kwadrat promienia okr�gu
										x : SDWORD, ; wsp�rz�dna x przetwarzanego punktu
										y : SDWORD ; wsp�rz�dna y przetwarzanego punktu
	
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
		mov EAX, 1		; obszar wewn�trz okregu, poniewa� sqr(x - center.X) + sqr(y- center.Y) < radiusSqr
		ret
	false: 
		mov EAX, 0		; punkt poza okr�giem, poniewa� sqr(x - center.X) + sqr(y- center.Y) >= radiusSqr
		ret		
							
IsInsideCircle endp	

;--- funkcja rysuj�ca okr�g-------------------------------------------------------------------------
DrawCircle proc uses EBX ECX EDX ESI EDI	bitmapArray : PTR SDWORD, ; wska�nik do tablicy z obrazem
											rowCount:SDWORD, ; liczba wierszy -> wysoko�� obrazu
											columnCount : SDWORD,  ; liczba kolumn -> szeroko�� wykresu
											color : SDWORD,  ; kolor wype�nienia figury
											center : VERTEX, ; wsp�rzedna �rodka okr�gu
											radius: SDWORD ; prominie� okr�gu
	
	;--- zmienne lokalne
	local minY : SDWORD			; najbardziej wysuni�ty w d� punkt okr�gu
	local maxY : SDWORD			; najbardziej wysuni�ty w g�r� lewo punkt okr�gu
	
	mov ESI, bitmapArray	; w ESI wska�nik do tablicy z obrazem 
	assume ESI :  PTR SDWORD
	mov EBX, center.y
	sub EBX, radius			; EBX = minY
	mov EDX, center.y 
	add EDX, radius			; EDX = maxY
	mov EAX, 0
	; wyznaczamy skrajne punkty okr�gu w pionie
	cmp EBX, EAX
		cmovl EBX, EAX		; if ebx < 0 ? ebx = 0 ebx =startY
	cmp EDX, rowCount
		cmovg EDX, rowCount ; if edx > rowCount ? edx = rowCount ; edx = endY
	mov maxY, EDX 
	
	; g��wna p�tla wype�niaj�ca okr�g, przechodz�ca po wsp�rz�dnych y
	; nie musimy przechodzi� po wszystkich wsp�rz�dnych y, wystarczy przej�� po y nale��cych do zbioru <minY,maxY>
	fillLoop: 
		; for (int y = startY; y < endY; y++). EBX = minY, EBX - licznik p�tli po wierszach
		cmp EBX, maxY		
		jge endFillLoop
			mov minY, EBX 
			mov ECX, 0 

			; p�tla wewn�trza przemieszczaj�ca si� po punktach z zbioru 
			; <center.x-radius , center.x + radius> dla danego wiersza
			innerLoop:     
				cmp ECX, radius 
				jge endInnerLoop
					mov EDX, center.x 
					mov EAX, radius
					mul radius			; EAX = sqr(radius)
					mov EDI, center.x 
					add EDI, ECX		; EDI = center.x + x

					;sprawdzamy czy dany punkt nale�y do okr�gu
					invoke IsInsideCircle, center.x, center.y, EAX, EDI, minY
					cmp EAX, 0			; w EAX zapisano warto�� 1/0 odowiednio gdy punkt znajduje / nie znajduje si� wewn�trz okr�gu 
					je nextInnerLoop	; je�eli punkt nie znajduje sie wewn�trz okregu, przejd� dalej 
						; 
						mov EDX, center.x 
						sub EDX, ECX			; EDX = center.x-x 
						cmp EDX, columnCount
						jge nextInnerLoop		; je�eli center.x -x jest wi�ksza do ilo�ci kolumn (czyli maksymalnej warto�ci x) to przejd� do nast�pnego punktu
						mov EDX, center.x 
						sub EDX, ECX			; EDX = center.x-x 
						cmp EDI, 0				; EDI = center.x + x
						jl nextInnerLoop		; je�eli center.x + x < 0 przejd� do nast�pnego punktu
						cmp EDI, columnCount	
						jge nextCondition		; je�eli center.x+x > columnCount, sprawd� czy mo�na pomalowa� punkt center.x -x
							; punkt o wsp�rz�dych center.x + x mo�na kolorowa� bo nale�y do okr�gu i znajduje si� na obrazie
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
							; punkt o wsp�rz�dych center.x - x mo�na kolorowa� bo nale�y do okr�gu i znajduje si� na obrazie
							mov EAX, columnCount
							mul EBX				; EAX = index 
							mov EDX, center.x 
							sub EDX, ECX		; EDX = center.x-x 
							add EAX, EDX		; EAX = index + center.x - x
							mov EBX, color
							mov [ESI + EAX*4], EBX		

					nextInnerLooP:
						inc ECX					; zwiekszenie licznika wewn�trzenej p�tli
						mov EBX, minY 
						jmp innerLoop			; powr�t do pocz�tku wewn�trznej p�tli 
	
			endInnerLoop:
				inc EBX			; zinkrementowanie licznika g��nej p�tli 
				jmp fillLoop	; kolejna iteracja g��wnej p�tli

	endFillLoop:
		ret
DrawCircle endp
end 