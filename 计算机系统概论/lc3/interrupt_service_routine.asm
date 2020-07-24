	.ORIG x2000	
	ADD R5,R0,#0	; save ori R0 in R5
			
	LD R0,diffc1	; change the pattern style
	ADD R4,R0,R4	; check the ori style
	BRz ifc1
	LD R4,char1	; change to the new style
	BRnzp chkr0
ifc1	LD R4,char2
	
chkr0	ADD R0,R5,R0	; if R0 is '#' or '*', change the content of R0
	BRz dr0		; check R0 '#'
	LD R0,diffc2
	ADD R0,R5,R0	; check R0 '*'
	BRnp ckb
dr0	ADD R5,R4,#0

ckb	LDI R2,KBSR	; get the input form the keyboard
	BRzp ckb
	LDI R0,KBDR

	AND R2,R2,#0
	ADD R2,R2,#10	; set loop times 10
loop	LDI R3,DSR
	BRzp loop
	STI R0,DDR	; print the char 10 times
	ADD R2,R2,#-1	
	BRp loop

	LD R0,newline	; print a newline character
loop1	LDI R3,DSR
	BRzp loop1
	STI R0,DDR

	ADD R0,R5,#0	; recover R0 from R5

	RTI		; return

;	device
KBSR	.FILL xFE00
KBDR	.FILL xFE02
DSR	.FILL xFE04
DDR	.FILL xFE06
;	char for output
newline	.FILL x000A
char1	.FILL x0023	;'#'
char2	.FILL x002A	;'*'
diffc1	.FILL xFFDD	; 0-'#'
diffc2	.FILL xFFD6	; 0-'*'
	.END