;
; Copyright (c) 1998-2003 Brian J. Hartman
;
; This software is provided "AS IS".  No warranty is expressed or implied.
; Permission to copy without fee all or part of this material is granted
; provided that the copies are not made or distributed for direct commercial
; advantage, this copyright notice is included, and notice that copying is
; by permission of the author of this software.  To copy otherwise, or to
; republish, requires a fee and/or specific written permission from the author.
;
; This file is a demonstration of the sample LC3 extension included with the
; LC3 Simulator.  This program performs the following operations:
;		
;	* First, the program initializes the necessary memory and registers
;	  for interrupts.  The stack pointer is set to the top of a stack.
;	  The interrupt handler is set to the location of a subroutine within
;	  this program.  And finally, interrupt x81 is enabled.  Location x1000
;	  is defined as the interrupt enable address for interrupt x81 in the
;	  LC3 extension.
;
;	* The main program then loops, continually checking the value of a
;	  counter.  The counter is decremented in the interrupt handler each
;	  time a character is written to the console.  When the counter reaches
;	  zero, the program halts.
;
;	* When interrupt x81 fires, the program gets a random number by using
;	  the reserved opcode implementation in the LC3 extension.  The interrupt
;	  handler then writes that number to the console and updates the counter.
;

	.ORIG x3000

	; Initialize the stack
	LEA R6, Stack

	; Set a handler for interrupt x81
	LEA R1, TimeSub
	STI R1, Int81

	; Enable interrupt x81.  The LC3 sample extension defines the
	; interrupt enable location for interrupt x81 as location x1000
	AND R1, R1, #0
	ADD R1, R1, #1
	STI R1, Enable

	; Wait until the counter reaches zero before terminating the
	; program.  Loading the counter value sets the condition codes
Loop	LD R2, Counter
	BRP Loop

	HALT

	; The location in the interrupt table for interrupt x81.  The address of
	; the interrupt handler routine should be placed there.
Int81	.FILL x0181

	; The interrupt enable address for interrupt x81
Enable	.FILL x1000

	; A counter for the number of characters to write to the console
Counter	.FILL #30

	; The reserved opcode generates random numbers in the range of 0 to 9.
	; By adding x0030 to that number, we get the ASCII code for the that digit.
ASCII	.FILL x0030

	; The stack
	.BLKW 100 #0
Stack	.FILL #0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TimeSub subroutine.  The TimeSub subroutine is the interrupt handler for interrupt x81
; (the one second timer).  This routine generates a random number and writes it to the console. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TimeSub	ST R0, SaveR0	; Save R0 so that changes aren't seen outside the subroutine
	ST R4, SaveR4	; Save R4 so that changes aren't seen outside the subroutine

	; Execute the reserved instruction.  Generate a random number in R4
	.FILL xD800 ; RESERVED R4

	; Convert the digit to its ASCII representation
	LD R0, ASCII
	ADD R0, R4, R0

	; Write the character to the console
	OUT

	; Decrement the character counter
	LD R0, Counter
	ADD R0, R0, #-1
	ST R0, Counter

	; Restore modified registers
	LD R0, SaveR0
	LD R4, SaveR4

	RTI

	; Save locations
SaveR0 .FILL #0
SaveR4 .FILL #0

	.END
