	LOAD #$FFFF, Gr0

	LOAD #5, Gr12;
	LOAD #10, Gr13;
	LOAD #RETURN1, Gr14;
	BRA #TOGMEM;
RETURN1
	GSTORE Gr0;
	;BREAK #0, Gr0
	LOAD #RETURN2, Gr14
	BRA #FROMGMEM
RETURN2
	ADD #2, Gr12;
	SUB #2, Gr13;
	LOAD #RETURN3, Gr14;
	BRA #TOGMEM;
RETURN3
	GSTORE Gr0;	

	LOAD #RETURN4, Gr14;
	BRA #GETOBSTACLEBYGMEM
RETURN4
	BREAK #0, Gr0;
	
LOOP
	BRA #LOOP;

INCLUDE util.asm
