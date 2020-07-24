	.ORIG x3000
	STACK	.BLKW #1	; init the stack
	LEA R6,STACK	; initialize the stack pointer

	LD R1,loca	; R1 the adress of height matrix
	LDR R2,R1,#-2
	ST R2,row	; read row

	LDR R5,R1,#-1
	ST R5,colunm	; read colunm	

	AND R4,R4,#0
mul	ADD R4,R5,R4
	ADD R2,R2,#-1
	BRp mul
	NOT R4,R4
	ADD R4,R4,#1
	ST R4,dend	; calculate the max shift in R4

	NOT R3,R5
	ADD R3,R3,#1
	ST R3,dcolunm	; the - row lwngth

	AND R5,R5,#0	; init R5 the colunm number
	
	AND R3,R3,#0	; the max shhift is in R3
loop	LD R0,savesh	; the main loop: travel all the cells
	JSR fun		; call the function
	JSR max
	LD R0,savesh
	ADD R0,R0,#1	; add shift
	ADD R5,R5,#1	; add colunm num
	LD R1,dcolunm
	ADD R1,R5,R1	; if R5 == m , R5=0
	BRnp nzeror5
	AND R5,R5,#0
nzeror5	ST R0,savesh
	ADD R1,R4,R0	
	BRn loop

	ADD R2,R3,#0	; send result to R2
	HALT

; function for recursive
; return R0 ; var: R0 shift of the cell 
fun	STR R7,R6,#0	
	ADD R6,R6,#-1	;save R7
	STR R1,R6,#0	
	ADD R6,R6,#-1	;save R1
	STR R2,R6,#0	
	ADD R6,R6,#-1	;save R2
	STR R3,R6,#0	
	ADD R6,R6,#-1	;save R3
	STR R4,R6,#0	
	ADD R6,R6,#-1	;save R4

	LEA R1,matrix
	ADD R1,R1,R0
	LDR R1,R1,#0
	BRnz prepare
	ADD R0,R1,#0	; check if have done
	BRnzp done
	
prepare	LD R2,loca
	ADD R2,R2,R0
	LDR R2,R2,#0
	NOT R1,R2
	ADD R4,R1,#1	; - this height R4
	
	AND R3,R3,#0	; init the length of this cell in R3
	
up	LD R1,dcolunm
	ADD R1,R1,R0	; new shift R1
	BRn down	; compare the shift and 0
	JSR geth
	ADD R2,R4,R2	; compare height
	BRzp down

	STR R0,R6,#0	
	ADD R6,R6,#-1	;save R0

	ADD R0,R1,#0
	JSR fun
	JSR max
	
	LDR R0,R6,#1
	ADD R6,R6,#1	;reload R0

down	LD R1,colunm
	ADD R1,R1,R0	; new shift R1
	LD R2,dend
	ADD R2,R1,R2	; compare the shift and the max shift
	BRzp left
	JSR geth
	ADD R2,R4,R2	; compare height
	BRzp left

	STR R0,R6,#0	
	ADD R6,R6,#-1	;save R0

	ADD R0,R1,#0
	JSR fun
	JSR max
	
	LDR R0,R6,#1
	ADD R6,R6,#1	;reload R0

left	ADD R5,R5,#0	; check if R5==0
	BRz right
	ADD R1,R0,#-1	; new shift R1
	JSR geth
	ADD R2,R4,R2	; compare height
	BRzp right

	STR R0,R6,#0	
	ADD R6,R6,#-1	; save R0
	ADD R5,R5,#-1	; move R5
	ADD R0,R1,#0
	JSR fun
	JSR max
	ADD R5,R5,#1
	LDR R0,R6,#1
	ADD R6,R6,#1	; reload R0

right	LD R1,dcolunm	
	ADD R1,R5,R1	; check if R5 == m
	ADD R1,R1,#1
	BRz store1
	ADD R1,R0,#1	; new shift R1
	JSR geth
	ADD R2,R4,R2	; compare height
	BRzp store1

	STR R0,R6,#0	
	ADD R6,R6,#-1	; save R0
	ADD R5,R5,#1	; move R5
	ADD R0,R1,#0
	JSR fun
	JSR max
	ADD R5,R5,#-1	; 
	LDR R0,R6,#1
	ADD R6,R6,#1	; reload R0


store1	LEA R1,matrix
	ADD R1,R1,R0
	ADD R3,R3,#1	; add 1 to the length
	STR R3,R1,#0	; save the result
	ADD R0,R3,#0	; R0 <- R3
done	LDR R4,R6,#1
	ADD R6,R6,#1	; reload R4
	LDR R3,R6,#1
	ADD R6,R6,#1	; reload R3
	LDR R2,R6,#1
	ADD R6,R6,#1	; reload R2
	LDR R1,R6,#1
	ADD R6,R6,#1	; reload R1
	LDR R7,R6,#1
	ADD R6,R6,#1	; reload R7
	RET

; function max
; var R3,R0
; return R3
max	STR R2,R6,#0	
	ADD R6,R6,#-1	;save R2
	NOT R2,R3
	ADD R2,R2,#1
	ADD R2,R0,R2
	BRnz r3w
	ADD R3,R0,#0
r3w	LDR R2,R6,#1
	ADD R6,R6,#1
	RET

; function geth:  var shift R1 return R2
; get the height of the cell
geth	LD R2,loca
	ADD R2,R2,R1
	LDR R2,R2,#0
	RET

loca	.FILL x3202	; the start location of matrix
colunm	.FILL x0000	; the colunm count
dcolunm .FILL x0000	; - the colunm count
row	.FILL x0000	; the row count
dend	.FILL x0000	; - the max shift 
savesh	.FILL x0000	; save the shift in the main loop

matrix	.BLKW #51	; record the max length of each cell
	.END
