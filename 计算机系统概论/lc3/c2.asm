	.ORIG x3000
	LD R1,entern
	LEA R4,buffer
	LEA R0,prompt	; output the prompt
	PUTS
; get a string of name and store it in the buffer
loop	GETC
	OUT
	ADD R3,R1,R0	; check if an enter is press
	BRz find
	STR R0,R4,#0
	ADD R4,R4,1	; save the character
	BRnzp loop	

; start finding the same name
find	STR R3,R4,#0
	AND R5,R5,#0
; R0 the block start
; R5 counter for user
	
;findloop
	LDI R0,loca
floop	BRz checkag	; finish the loop when reach the end of link list

	LEA R3,buffer
	LDR R4,R0,#2	
	JSR checkstr	; check the first name
	BRz done

	LEA R3,buffer
	LDR R4,R0,#3
	JSR checkstr	; check the last name
	BRz done

	LDR R0,R0,#0	; goto the next node
	BRnzp floop

; check find one or not
checkag	ADD R5,R5,#0
	BRz fail
	HALT

; when find one same name, output the result and go on
done	ADD R1,R0,#0	; save R0 in R1

	LDR R0,R1,#3	; output the last name
	PUTS

	LD R0,space	; print a space
	PUTC

	LDR R0,R1,#2	; output the first name
	PUTS

	LD R0,space	; print a space
	PUTC

	LDR R0,R1,#1	; output the room number
	PUTS

	LD R0,newline	; change to a new line
	PUTC

	ADD R5,R5,#1
	ADD R0,R1,#0
	LDR R0,R0,#0	; goto the next node and continue searching
	BRnzp floop

; no name is find
fail	LEA R0,failure
	PUTS
	HALT

; function for comparing two strings:
; R0 the block start *
; R1 char1
; R2 char2
; R3 pos of char1 input *
; R4 pos of char2 being checked *
; if R1==1, false
; r1<-0 true

checkstr		
	LDR R1,R3,#0	; load char1 and char2
	BRz and1	; if char1==0, check char2 for empty case
	LDR R2,R4,#0	; else simply load char2
checks1	
	NOT R2,R2
	ADD R2,R2,#1
	ADD R2,R2,R1	; check if char1 == char2
	BRnp nots	; if not return false	
yesc	ADD R3,R3,#1		
	ADD R4,R4,#1
	LDR R1,R3,#0
	BRnp andn	
and1	LDR R2,R4,#0	; if char1==0, it will get here
	BRz yess        ; char 2 is zero, indicate char1 == 0 && char2 == 0 then yes
	BRnzp checks1	; 
andn	LDR R2,R4,#0	; char1 is not zero
	BRnzp checks1
nots	AND R1,R1,#0
	ADD R1,R1,#1
	ret
yess	AND R1,R1,#0
	ret

newline	.FILL X000A
space	.FILL x0020
entern	.FILL xFFF6
buffer	.BLKW #20
prompt	.STRINGZ "Type a name and press Enter:"
failure	.STRINGZ "Not Found"
loca	.FILL x4000
	.END