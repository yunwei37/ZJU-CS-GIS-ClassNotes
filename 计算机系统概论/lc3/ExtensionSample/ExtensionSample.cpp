/*
	Copyright (c) 1998-2003 Brian J. Hartman

	This software is provided "AS IS".  No warranty is expressed or implied.
	Permission to copy without fee all or part of this material is granted
	provided that the copies are not made or distributed for direct commercial
	advantage, this copyright notice is included, and notice that copying is
	by permission of the author of this software.  To copy otherwise, or to
	republish, requires a fee and/or specific written permission from the author.

	This file provides a sample implementation of an LC3 extension and is designed to
	be used with the ExtensionTest.asm assembly file.  This extension performs the
	following operations:
		
		* The extension uses Interrupt x81 as a one second timer.  If the time
		  since the last interrupt call is more than one second, interrupt x81
		  is fired.  Location x1000 is used as the interrupt enable address.
		  Interrupt x81 is enabled only in location x1000 is non zero.

		* The extension implements the reserved opcode as an instruction that
		  should write a random number in the range of 0 to 9 in the register
		  indicated in bits 9 to 11 in the instruction.

	  The corresponding ExtensionSample.asm sets the interrupt handler and enables
	  interrupts.  The interrupt handler calls the reserved opcode then writes the
	  random number to the console.
*/

#define VC_EXTRALEAN
#include <windows.h>
#include "LC3Extension.h"

// The last time the interrupt was called.  This is necessary to determine if
// one second has elapsed since the last call and consequently, whether another
// interrupt should fire.
DWORD gLastInterruptTime;

// The standard DLL entry point.  This function is not necessary.  It called by
// the Win32 framework.  One time initialization and cleanup should occur here.
BOOL APIENTRY DllMain(HANDLE hModule, DWORD ul_reason_for_call, LPVOID lpReserved)
{
	// On start up, initialize the last interrupt time to the current time
	// and seed the random number generator.
	if (ul_reason_for_call == DLL_PROCESS_ATTACH)
	{
		gLastInterruptTime = GetTickCount();
		srand(gLastInterruptTime);
	}

    return TRUE;
}

// FireInterrupt3 is a required method for an LC3 extension.  This implementation fires
// interrupt x81 if at least one second has elapsed since the last firing of the
// interrupt.  x1000 is treated as the interrupt enable address.  Interrupts only
// fire if x1000 contains a non-zero value.
LC_API int FireInterrupt3(GetValueMethod GetValue)
{
	// Determine if interrupt x81 is enabled.  Get the value at x1000 and
	// verify it is non-zero.
	BITS interruptEnable;
	if (GetValue(0x1000, interruptEnable) != LCEXT_SUCCESS)
		return NO_INTERRUPT;	// Unexpected error
	if (interruptEnable == 0)
		return NO_INTERRUPT;	// Interrupts not enabled

	// Determine if at least one second has passed since the last x81 interrupt.
	DWORD currentTime = GetTickCount();
	if (currentTime - gLastInterruptTime >= 1000)
	{
		gLastInterruptTime = currentTime;
		return 0x0081;
	}

	// It's not time for another interrupt
	return NO_INTERRUPT;
}

// ExecuteReservedOpcode3 is a required method for an LC3 extension.  This implementation
// saves a random number in the range of 0 to 9 at the register designated in the 
// instruction.  The instruction bits are:
//
//		1  1  1  1  1  1
//		5  4  3  2  1  0  9  8  7  6  5  4  3  2  1  0
//	  +------------------------------------------------+
//    | 1  1  0  1 |  DR   |          MBZ              |
//	  +------------------------------------------------+
// 
LC_API void ExecuteReservedOpcode3(GetValueMethod GetValue, SetValueMethod SetValue)
{
	// Get the location of the instruction.  The PC has already been incremented, so
	// substract one to get the location of the executing instruction.  If PC = 0,
	// then PC + 1 overflowed.  This shouldn't happen since the first and last few
	// memory location are reserved for various system operations.  But it can't
	// hurt to check!
	BITS pc;
	if (GetValue(LCEXT_PC, pc) != LCEXT_SUCCESS)
		return;	// Unexpected failure
	int instructionLocation;
	if (pc != 0)
		instructionLocation = pc - 1;
	else
		instructionLocation = 0x0FFFF;

	// Get the instruction from memory
	BITS instruction;
	if (GetValue(instructionLocation, instruction) != LCEXT_SUCCESS)
		return;	// Unexpected error

	// Get the destination register for the random number
	int destRegister = (instruction & 0x0E00) >> 9;

	// Convert the register number to a constant that can be passed to SetValue
	int setLocation = 0;
	switch (destRegister)
	{
		case 0: setLocation = LCEXT_R0; break;
		case 1: setLocation = LCEXT_R1; break;
		case 2: setLocation = LCEXT_R2; break;
		case 3: setLocation = LCEXT_R3; break;
		case 4: setLocation = LCEXT_R4; break;
		case 5: setLocation = LCEXT_R5; break;
		case 6: setLocation = LCEXT_R6; break;
		case 7: setLocation = LCEXT_R7; break;
	}

	// Generate a random number
	int randomValue = rand() % 10;

	// Write the random number
	if (SetValue(setLocation, randomValue) != LCEXT_SUCCESS)
		return;	// Unexpected failure
}
