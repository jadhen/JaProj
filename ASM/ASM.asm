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
CalculateIntersections proc uses EBX ECX EDX ESI EDI row : SDWORD, ; aktualnie przetwarzany wiersz
							numberOfVerticies : SDWORD, ; liczba wierzcho³ków
							vertexTab : PTR VERTEX, ; wskaŸnik na tablice wierzcho³ków
							intersections : PTR SDWORD ; wskaŸnik do tablicy z przeciêciami


	mov ebx, 0 ; EBX - licznik wyznaczonych przeciêæ
	mov EDX, numberOfVerticies
	dec EDX ;  w edx liczba wierzcho³ków - 1 -> j
	mov ECX, 0
	calculateIntersectionsLoop: ; pêtla po wszystkich wierzcho³kach
		cmp ECX, numberOFVerticies ; ECX - iterator po pêtli
		jge calculateIntersectionsLoop_end
		;----------pierwszy if ----------
		mov esi, vertexTab ; ESI - wskaŸnik do tablicy wierzcho³ków
		assume ESI : PTR VERTEX
		checkIfBetweenPairOfVerices:
		mov eax, [ESI + ECX * 8].y ; vertex ma rozmiar 8 bo 2xSDWORD, eax = vertex[i].Y
		cmp eax, row 
		jge secondCondition ;-----vertex[i].Y  >= row
		;------vertex[i].Y  < row
			mov EAX, [ESI + EDX*8].y ; eax = vetricies[j].y
			cmp EAX, row
			jge rowBetweenTwoVerticies ; vertex[i].y  >= row --> wiersz pomiedzy dwoma wierzcho³kami
			jmp checkNextPairOfVerticies
		secondCondition:
			mov EAX, [ESI + EDX*8].y ; eax = vetricies[j].Y
			cmp EAX, row
			jl rowBetweenTwoVerticies ; vertex[j].y  < row --> wiersz pomiedzy dwoma wierzcho³kami
			jmp checkNextPairOfVerticies
				rowBetweenTwoVerticies:
					mov EAX, [ESI + ECX*8].x ; eax = vertex[i].X
					cmp EAX, [ESI + EDX*8].x ; porównaj eax z vertex[j].X
					je verticalLine ;  punkty vertex[i] i  vertez[j] le¿¹ na poziomej linii
						;--- wierzcho³ki nie le¿¹ na poziomej linii
						;----double a = (vertex[j].Y  - vertex[i].Y ) / (double)(vertex[j].X  - vertex[i].X );
						mov EAX, [ESI + EDX*8].y ; eax = vertex[j].y
						sub EAX, [ESI + ECX*8].y ; eax = vertex[j].y - vertex[i].y
						cvtsi2sd xmm0, eax ; xmm0 = vertex[j].y - vertex[i].y
						mov EAX, [ESI + EDX*8].x ; eax = vertex[j].y
						sub EAX, [ESI + ECX*8].x ; eax = vertex[j].x - vertex[i].x
						cvtsi2sd xmm1, eax ; xmm1 = vertex[j].x - vertex[i].x

						divsd xmm0, xmm1 ; xmm0 = a
						;--------double b = vertex[i].Y  - a * vertex[i].X ;
						cvtsi2sd xmm1, SDWORD PTR [ESI + ECX*8].x ; xmm1 = vertex[i].x
						mulsd xmm1, xmm0 ; xmm1 = a* vertex[i].x
						cvtsi2sd xmm2, SDWORD PTR [ESI + ECX*8].y ; xmm2 = vertex[i].y
						subsd xmm2, xmm1 ; xmm2 = b
						;---------intersections[numberOfIntersections++] = (int)((row - b) / a);
						cvtsi2sd xmm1, row ; xmm1 = row
						subsd xmm1, xmm2 ; xmm1 = row - b
						divsd xmm1, xmm0 ; xmm1 = (row - b) / a
						cvttsd2si eax, xmm1 ; eax = (int) xmm1
						 
						; w eax mamy wartoœæ któr¹ chcemy zapisaæ wiec mozemy wykorzystaæ makro ponizej
				
					verticalLine: ; wyznacz przeciêcie jezeli punkty vertex[i] i  vertez[j] le¿¹ na poziomej linii
						;push EDX ; zapisanie wartoœæ edx na stosie
						mov EDI, intersections ; w edx adres tablicy intersections
						mov [EDI + EBX *4], EAX ; eax =  wartoœæ do zapisania, intersections[numberOFVerticies] = vertex[i] || (row - b) / a .
						;pop EDX ; przywrócenie wartoœci rejestru edx
						inc EBX ; zwiêksz o 1 liczbê wyznaczonych przeciêæ

		checkNextPairOfVerticies: ; 
			mov EDX, ECX ; i = j
			inc ECX ; i++
			jmp CalculateIntersectionsLoop
	calculateIntersectionsLoop_end: 
		mov EAX, EBX ; w eax liczba wyznaczonych przeciêæ
		

		
 ret
CalculateIntersections endp
;-------------sortuje obliczone wierzcho³ki ----------------------;
SortIntersections proc uses EBX ECX EDX ESI EDI numberOfIntersections : SDWORD, ; liczba przecieæ w danym wierszu
												intersectionsTab : PTR SDWORD	; wskaŸnik do tablicy przeciêæ

	mov ECX, 0 ; ecx -  iterator pêtli
	mov EBX, numberOfIntersections 
	dec EBX ; ebx = numberOfIntersections -1
	mov EDX, intersectionsTab ; edx - adres tablicy z przecieciami 
	mainLoop: 
		cmp ECX, EBX
		jg endMainLoop
			mov ESI, [EDX + ECX*4] ; esi = intersections[i]
			mov EDI, [EDX + ECX*4+4] ; edi = intersections[i+1]
			cmp ESI, EDI
			jle correctOrder ;nie trzeba zamieniaæ elementów
			;--- zamiana elementów
				mov [EDX + ECX*4], EDI
				mov [EDX + ECX*4+4], ESI
				cmp ECX, 0 ; if(i == 0)
				jne mainLoop
					dec ECX
					jmp mainLoop
			correctOrder:
				inc ECX

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
	
	
	mov EDX, 0	;edx - licznik pêtli	
	mov ESI, intersectionsTab ; ESI - wskaŸnik na tablice z przecieciami
	assume ESI : PTR SDWORD
	fillLoop:		;pêtla po wszystkich wierzcho³akch
		cmp EDX, numberOfIntersections
		jge endFillLoop
		mov EAX, 0
		cmp EAX, [ESI + EDX*4]
			cmovl EAX, [ESI + EDX*4] ; if intersection[i] < 0
		mov ECX, [ESI + EDX*4+4]
		cmp ECX,  maxX
			CMOVG ECX, maxX ; if intersection[i+1] > maxX
		;---------przygotowanie pod operacje ³añcuchowe
		sub ECX, EAX ; ecx = ecx - eax, ró¿nica miêdzy dwoma kolejnymi wierzco³kami
		mov EBX, maxX
		imul EBX, row ; ebx - offset
		add EBX, EAX ; ebx = offset + min
		imul EBX,  4 ; EBX = 4(offset+min) odwo³ujemy sie do elementu [EDI + 4(offset+min)]
		mov EDI, bitmapArray ; edi -addres bitmapy
		add EDI, EBX ; adres od którego kolorujemy w EDI
		mov EAX, color
		; wype³nianie obszaru miedzy przecieciami
		rep stosd ;
		add EDX, 2 ; inkrementacja licznika petli
		jmp fillLoop;
	endFillLoop:		
		ret
FillPolygon endp


;-------------Funkcja rysuj¹ca wielok¹t-----------------------;

DrawFigure proc uses EBX ECX EDX ESI EDI bitmapArray : PTR SDWORD, ;tablica reprezentuj¹ca bitmapê
	rowCount : SDWORD,		; wysokoœæ bitmapy
	columnCount : SDWORD,	; szerokoœæ bitmapy
	color :SDWORD,			; kolor wype³niania figury
	vertexTab : PTR VERTEX, ; tablica z wierzcho³kami
	vertexCount : SDWORD	; liczba wierzcho³ków
	;------zmienne
	local height : SDWORD ; zmienna reprezentuj¹ca wysokoœæ bitmapy
	local i : SWORD ; iterator
	local numberOfIntersectionsInRow : SDWORD ;liczba przeciêæ wyznaczona w danym wierszu 
	; local row : SDWORD ; licznik wierszy
	;local maxNumberOfIntersections : SDWORD 50
	local intersections[50] : SDWORD ; tablica przechowywuj¹ca wyznaczone przeciêcia
	;------inicjalizacja
	mov eax, rowCount
	mov height, eax

	
	;------g³ówna pêtla programu
	mov EBX, 0 ; EBX licznik rzedow
	
	mov esi, bitmapArray ; wpisanie do ESI adresu tablicy 
	
	main_loop:
		cmp EBX, height ;warunek pêtli
		jge end_main_loop
		mov EDX, vertexTab ; edx - adres tablicy z przeciêciami
		;lea ESI, intersections[0] ;  ESI - adres tablicy na przeciêcia
		invoke CalculateIntersections, EBX, vertexCount, EDX, addr intersections
		mov numberOfIntersectionsInRow, EAX ; w eax zwrócna wartoœæ przez funkcje CalculateIntersections
		invoke SortIntersections , numberOfIntersectionsInRow, addr intersections
		invoke FillPolygon ,numberOfIntersectionsInRow, addr intersections, rowCount, bitmapArray, color, EBX
	
		;mov edx, rowCount ; wyznaczenie offsetu
		;imul edx, ebx

		;mov ecx, color ; skopiowanie koloru

		;mov [esi + edx * 4], ecx ; wype³nienie komórki bitmapy
		;----inkrementacja licznika wierszy i zapisanie go do rejestru EBX
		inc EBX
		jmp main_loop
	;------koniec g³ównej pêtli programu
	end_main_loop:
	ret
DrawFigure endp
;----------------------sprawdza czy dany punkt jest wewn¹trz okrêgu
IsInsideCircle proc uses EBX ECX EDX	centerX : SDWORD, ; wspó³rzêdna x œrodka okrêgu
									centerY : SDWORD, ; wspó³rzêdna y œrodka okrêgu
									radiusSqr : SDWORD, ; kwadrat promienia okrêgu
									x : SDWORD, ; wspó³rzêdna x przetwarzanego punktu
									y : SDWORD ; wspó³rzêdna y przetwarzanego punktu
	
	mov EAX, x 
	sub EAX, centerX ; eax = x - centerX
	mul EAX ; eax = eax ^2
	mov EBX, EAX ; ebx = (x - centerX)^2
	mov EAX, y
	sub EAX, centerY
	mul EAX ; eax = (y - centerY)^2
	add EAX, EBX ; eax = sum
	cmp EAX, radiusSqr
		jnl false
		mov EAX, 1 ; obszar wewn¹trz okregu
		ret
	false: 
		mov EAX, 0 ; punkt poza okrêgiem	
		ret		
							
IsInsideCircle endp	

DrawCircle proc uses EBX ECX EDX ESI EDI	bitmapArray : PTR SDWORD, ; wskaŸnik do tablicy z obrazem
											rowCount:SDWORD, ; liczba wierszy -> wysokoœæ obrazu
											columnCount : SDWORD,  ; liczba kolumn -> szerokoœæ wykresu
											color : SDWORD,  ; kolor wype³nienia figury
											center : VERTEX, ; wspó³rzedna œrodka okrêgu
											radius: SDWORD ; prominieñ okrêgu

		local minY : SDWORD ; wyznacza lewa krawedz okrêgu
		local maxY :SDWORD ; wyznacza praw¹ 

		

		mov ESI, bitmapArray ; w ESI wskaŸnik do tablicy z obrazem 
		assume ESI :  PTR SDWORD
		mov EBX, center.y
		sub EBX, radius ; ebx = minY
		mov EDX, center.y 
		add EDX, radius ; edx = maxY
		mov EAX, 0
		cmp EBX, EAX
			cmovl EBX, EAX ; if ebx < 0 ebx = 0 ebx =startY
		cmp EDX, rowCount
			cmovg EDX, rowCount ; if edx > rowCount, edx = rowCount ; edx = endY
		mov maxY, EDX
		;mov minY, EBX 
		fillLoop: 
			cmp EBX, maxY ;for (int y = startY; y < endY; y++) ebx = minY
			jge endFillLoop
				mov minY, EBX 
				
				mov ECX, 0 
				innerLoop:
					cmp ECX, radius
					jge endInnerLoop
						mov EDX, center.x 
						
						mov EAX, radius
						mul radius ; eax = radius^2
						mov EDI, center.x 
						add EDI, ECX ; edi = center.x + x
						invoke IsInsideCircle, center.x, center.y, EAX, EDI, minY
						cmp EAX, 0 
						je nextInnerLoop
							
							
							;-----edi - left, edx - right
							mov EDX, center.x 
						sub EDX, ECX ; eax = center.x-x 
							cmp EDI, columnCount
							jge nextInnerLoop
							mov EDX, center.x 
						sub EDX, ECX ; eax = center.x-x 
							cmp EDX, 0
							jl nextInnerLoop
							cmp EDX, columnCount ;EDX
							jge nextCondition
								mov EAX, columnCount
								mul EBX
								mov EDX, center.x 
								sub EDX, ECX ; eax = center.x-x 
								add EAX, EDX ; eax - index
								mov EBX, color
								mov [ESI + EAX*4], EBX
								mov EBX, minY
						nextCondition:
							mov EDI, center.x 
						add EDI, ECX ; edi = center.x + x
							cmp EDI, 0
							jl nextInnerLoop
								mov EAX, columnCount
								mul EBX
								add EAX, EDI ; eax - index
								mov EBX, color
								mov [ESI + EAX*4], EBX		
						nextInnerLooP:
							inc ECX ; zwiekszenie 
							mov EBX, minY
							jmp innerLoop

				endInnerLoop:
					
					inc EBX ;  zinkrementowanie licznika g³ónej pêtli 
					jmp fillLoop ; kolejna iteracja g³ównej pêtli

		
	endFillLoop:
		ret
DrawCircle endp
end 