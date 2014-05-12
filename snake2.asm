SNAKELOADOLD2
	;först spara positionen gamla huvudet är på. 
	LOAD $C7E, Gr0; ladda head-pointern till Gr0
	;dags att förberade subrutinkall till FROMGMEM
	LOAD $C40, Gr15, Gr0; ladda Gr15 med gamla huvudets position (Gr0 som index)
	LOAD #SNAKERETURNA, Gr14; returadress
	BRA #FROMGMEM; Lägger X, Y i Gr12, Gr13
SNAKERETURN2A
	
	; nu: Gr12, Gr13 innehåller X, Y
	; ska ge dem rätt värde utifrån rörelseriktning
	
	;ta reda på SPI-data för snake 1
	;TODO FIXA JOYSTICK
	;välj direction baserat på SPI-data
	
SNAKELEFT2
	SUB #1, Gr12; minska X med 1
	BRA #SNAKESTOREHEADPOS
SNAKEUP2
	SUB #1, Gr13; minska Y med 1
	BRA #SNAKESTOREHEADPOS
SNAKERIGHT2
	ADD #1, Gr12; öka X med 1
	BRA #SNAKESTOREHEADPOS
SNAKEDOWN2
	ADD #1, Gr13; öka Y med 1
	BRA #SNAKESTOREHEADPOS
	
SNAKESTOREHEADPOS2
	LOAD #SNAKERETURNB, Gr14;
	BRA #TOGMEM; formatera tillbaka till GMEM-form
SNAKERETURNB2
	;Nu ligger första ormens nya huvudposition i Gr15, formaterat för Gmem
	STORE $D01; Spara huvudets position för senare användning	
	
;------------------------------------------------------------------------------------------

	LOAD $C7E, Gr0; orm 2 head pointer till gr0
	ADD #1, Gr0; 
	MOD #62, Gr0; cirkulär lista. orm-array max 62 lång.
	LOAD $D01, Gr1; ladda in nya huvudpos till Gr1
	STORE $C40, Gr1, Gr0; spara nya huvudpos på huvudplatsen i orm-arrayen
	STORE $C7E, Gr0; lägg tillbaka nya huvudplatsen igen



