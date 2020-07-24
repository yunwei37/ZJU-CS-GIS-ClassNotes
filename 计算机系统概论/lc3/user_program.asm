	.ORIG x3000
	STACK	.BLKW #1	; init the stack

	LD R1,ENTREN	
	STI R1,IVT	;  set up the keyboard interrupt vector table entry

	LD R1,MASK
	STI R1,KBSR	; enable keyboard interrupts

	LEA R6,STACK	; initialize the stack pointer
; R4 is the '*' or'#'	
	LD R4,char2	 ; init the pattern 
; R0 stores the ascii code of the char to display
; start of actual user program to print the checkerboard
LOOP	AND R1,R1,#0
	ADD R1,R1,#8
line1	JSR c2s4	; print the pattern followed by four space" eight times
	ADD R1,R1,#-1
	BRp line1
	LD R0,newline	; print a newline
	JSR PUTCHAR
	JSR DELAY	; delay 2500 counts
	
	LD R0,SPACE	; print three spaces
	JSR PUTCHAR
	JSR PUTCHAR
	JSR PUTCHAR

	AND R1,R1,#0
	ADD R1,R1,#7
line2	JSR c2s4	; print the pattern followed by four space" seven times
	ADD R1,R1,#-1
	BRp line2	
	
	LD R0,newline	; print a newline
	JSR PUTCHAR
	JSR DELAY	; delay 2500 counts

	BRnzp LOOP

; function for print 2 char and 4 spaces
c2s4	STR R1,R6,#0
	ADD R6,R6,#-1	;save R1
	STR R7,R6,#0	
	ADD R6,R6,#-1	;save R7
	ADD R0,R4,#0
	JSR PUTCHAR	; print the pattern char twice
	ADD R0,R4,#0
	JSR PUTCHAR
	LD R0,SPACE
	JSR PUTCHAR	; print four spaces
	JSR PUTCHAR
	JSR PUTCHAR
	JSR PUTCHAR	
	LDR R7,R6,#1
	ADD R6,R6,#1	;reload R7
	LDR R1,R6,#1
	ADD R6,R6,#1	;reload R1
	RET

; putcahr function: R0 is the char to show
PUTCHAR	STR R1,R6,#0
	ADD R6,R6,#-1	; save R1 in the stack
SHOW	LDI R1,DSR
	BRzp SHOW	
	STI R0,DDR	; print the char
	LDR R1,R6,#1	; reload R1 from the stack
	ADD R6,R6,#1
	RET

; the delay function: 
DELAY 	STR R1,R6,#0
	ADD R6,R6,#-1	; save R1 in the stack
	LD R1,COUNT
REP 	ADD R1,R1, #-1	; count from 2500 to 1
	BRp REP
	LDR R1,R6,#1	; reload R1 from the stack
	ADD R6,R6,#1
	RET

COUNT 	.FILL #2500
; some chars for output
newline	.FILL x000A
char1	.FILL x0023	;'#'
char2	.FILL x002A	;'*'
SPACE	.FIll x0020

; device
MASK	.FILL x4000	; use to set the IE flag 
KBSR	.FILL xFE00
KBDR	.FILL xFE02
DSR	.FILL xFE04
DDR	.FILL xFE06

IVT	.FILL x0180	; the address from INTV
ENTREN	.FILL x2000	; the entry address of interrupt service routine
	.END
