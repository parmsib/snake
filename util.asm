
;---------------------------------

;IN:
;Gr12: X-värde som vanligt word
;Gr13: Y-värde som vanligt word
;Gr14: return-adress

;UT:
;Gr15: Adress formaterad för GMEM

TOGMEM
	STORE $F00, Gr12; spara undan X, och Y
	STORE $F01, Gr13;
	LOAD $F01, Gr15; ladda in Y till Gr15.
	LSL #5, Gr15; shifta ut Y-bitarna till sin rätta plats
	OR $F00, Gr15; ORa in X-delen
	STORE $F10, Gr14 ;lägg returnadressen på ett ställe i minnet
	BRA $F10; returnera

;----------------------------------



;IN
;Gr14 return-adress
;Gr15 GMEM-formaterad adress

;UT
;Gr12 X-värde som vanligt ord
;Gr13 Y-värde som vanligt ord

FROMGMEM
	STORE $F00, Gr15; spara undan in-värdet
	LOAD $F00, Gr12; ladda till X
	AND #$001F, Gr12; ANDa bort y-delen från x
	LOAD $F00, Gr13;
	LSR #5, Gr13; Shifta bort y-delen till LSBs
	STORE $F10, Gr14 ;lägg returnadressen på ett ställe i minnet
	BRA $F10;

;----------------------------------

;IN

;Gr14 return-adress
;Gr15 pos på GMEM-form

;OUT
;Gr11 $FFFF om det är hinder på (x, y)
;	annars $0000

GETOBSTACLEBYGMEM
	STORE $F00, Gr15; spara GMEM-posen på F00
	STORE $F01, Gr15; spara GMEM-posen på F01
	LOAD $F00, Gr12; ladda ovanstående
	;Gr12 får vara X
	;Gr15 Y
	AND #$001F, Gr12; ta bort Y-bitarna
	LSR #5, Gr15; shifta bort Y-bitarna till LSBs
	;MUL #32, Gr15; multiplicera Y med 32 för få antal bitar den offsetar
	LSL #5, Gr15;
	STORE $F00, Gr15; addera de båda och sätt resultat i Gr12
	ADD $F00, Gr12;
	;nu innehåller Gr12 det bitnr vår bit har
	STORE $F00, Gr12; kopiera datat till Gr15
	LOAD $F00, Gr15;
	;DIV #16, Gr15; heltalsdela Gr15 med 16 för att hitta word-index
	LSR #4, Gr15;
	;MOD #16, Gr12; gör modulus 16 på Gr12 för att hitta hur mycket
	;			...vi måste shifta till vänster sen i wordet
	AND #$000F, Gr12;
	STORE $F02, Gr10
	LOAD $DB0, Gr10, Gr15; ladda rätt word i kartan till Gr10
	STORE $F00, Gr12;
	LSL $F00, Gr10; Shifta wordet till vänster Gr12 antal gånger
	AND #$8000, Gr10; anda bort all annan data
	LOAD #$0000, Gr11;ladda ett standardvärde till Gr11
	CMP #$8000, Gr10; kolla om det är en etta vi shiftat in
	BNE #WASNOTOBSTACLE; om så inte var fallet
	LOAD #$FFFF, Gr11; annars (var hinder där)
WASNOTOBSTACLE
	STORE $F10, Gr14 ;lägg returnadressen på ett ställe i minnet
	LOAD $F02, Gr10;
	LOAD $F01, Gr15;
	BRA $F10; return
		
;-------------------------------------------------------------------
; IN
; Gr9  COLOR (GPU FORMAT)
; Gr12 startX 	
; Gr13 startY
; Gr15 startAdr
; Gr14 returnAdr
; Gr10 stopX
; Gr11 stopY
; VARNING, fuckar med registren!

PRINT
	STORE $F23, Gr10 ;	
	STORE $F24, Gr11 ;
	STORE $F25, Gr12 ;
	STORE $F26, Gr13 ;
	STORE $F21, Gr14 ;
	STORE $F22, Gr15 ;
	LSL #12, Gr9;
	STORE $F27, Gr9;
	;calculate hur många words som är i en rad
	LOAD $F23, Gr8 ;
	SUB $F25, Gr8 ;
	LSR #2, Gr8 ;
	STORE $F28, Gr8 ;
	LOAD #0, Gr7;

PRINTLOOPX
	LOAD #PRINTLOOPXRETURN, Gr14;
	BRA #TOGMEM;
PRINTLOOPXRETURN
	;Nu innehåller Gr15 Y-adressen konkatenerat med X-adressen, redo för GMEM
	STORE $F20, Gr7 ;
	LOAD $F20, Gr2;
	;Behöver indexera minnesrymden som innehåller menybilden.
	;STORE $F20, Gr13; Lägg y * (32bitar = 8 words) i Gr2 som är word-index i statiska bilden
	;LOAD $F20, Gr2;
	;SUB $F26, Gr2 ;
	;               MUL #8, Gr2;
	;LSL #3, Gr2;
	STORE $F20, Gr12; Lägg till x // 4 till Gr3, för att få rätt word-offset i x-led
	LOAD $F20, Gr3; 
	SUB $F25, Gr3;
	;DIV #4, Gr3; heltalsdivision (avrunda nedåt)
	LSR #2, Gr3;
	STORE $F20, Gr3;
	ADD $F20, Gr2;
	;nu innehåller Gr2 hela adressen till det word som vår sökta tile ligger i
	
	;behöver ta reda på vilken tile i detta word vi är ute efter
	STORE $F20, Gr12; Spara (x mod 4) - 1 till Gr3, vilket är tile-index i wordet
	LOAD $F20, Gr3;
	SUB $F25, Gr3 ;
	;MOD #4, Gr3;
	AND #$0003, Gr3; MOD #4
	;SUB #1, Gr3;
	;nu innehåller Gr3 tile-index i wordet

	STORE $F20, Gr2;	
	LOAD $F22, Gr5;
	ADD $F20, Gr5;
	STORE $F20, Gr5;
	LOAD ($F20), Gr4; Ladda in rätt word från bilden till register 4
	;MUL #4, Gr3; multiplicera tile-index för att få hur långt vi måste shifta i wordet
	LSL #2, Gr3;
	STORE $F20, Gr3; Shifta wordet så att vår tile hamnar längs till vänster (MSBs, vilket är vad GMEMet tar från bussen)
	LSL $F20, Gr4
	AND #$F000, Gr4; ANDa bort de bitar som låg efter vår tile i wordet
	
	AND $F27, Gr4 ;
	;Nu innehåller Gr4 den tile som ska ut på bussen och in i GMEM! :D
	;Gr15 innehåller den adress i GMEM som tilen ska sparas på, vilket är enligt överenskommelse.
	GSTORE Gr4;
	
	ADD #1, Gr12;
	CMP $F23, Gr12;
	BNE #PRINTLOOPX; om vi inte loopat fördigt på x, gör det igen
	;annars, gå vidare ner till Y
	
	;LOOP Y
	ADD #1, Gr13;
	ADD $F28, Gr7 ;
	CMP $F24, Gr13;
	LOAD $F25, Gr12; nollställ X, på nästa rad
	BNE #PRINTLOOPX; om vi inte loopat färdigt på Y, fortsätt loopa
	;annars (vi har loopat färdigt), gå vidare

	BRA $F21;





;---------------------
; Gr14 - return adr
; Gr15 - clearcolor
; VARNING, fuckar register

CLEARSCREEN
	STORE $F30, Gr14;
	LSL #12, Gr15 ;
	STORE $F31, Gr15;
	LOAD $F31, Gr11 ;
	LOAD #0, Gr12 ;
	LOAD #0, Gr13 ;
CLEARSCREENLOOPY
	LOAD #0, Gr12 ; 
CLEARSCREENLOOPX
	LOAD #CLEARSCREENRETURN, Gr14 ;
	BRA #TOGMEM ;
CLEARSCREENRETURN
	GSTORE Gr11 ;

	ADD #1, Gr12 ;
	CMP #32, Gr12 ;
	BNE #CLEARSCREENLOOPX ;

	ADD #1, Gr13;
	CMP #32, Gr13;
	BNE #CLEARSCREENLOOPY ;

	BRA $F30 ;








	
	
	
	
	
	
	
	
	
	
	















