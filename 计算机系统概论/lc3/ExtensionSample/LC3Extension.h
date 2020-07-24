/*
	Copyright (c) 1998-2003 Brian J. Hartman

	This software is provided "AS IS".  No warranty is expressed or implied.
	Permission to copy without fee all or part of this material is granted
	provided that the copies are not made or distributed for direct commercial
	advantage, this copyright notice is included, and notice that copying is
	by permission of the author of this software.  To copy otherwise, or to
	republish, requires a fee and/or specific written permission from the author.

	This include file contains all of the constants and function prototypes needed
	to write an extension to LC3 Simulator.  An LC3 extension is a DLL that exports
	the two LC_API methods defined below.  This file is designed to be reused and
	should be included in your project.
*/

#ifndef _lc3extension_h_
#define _lc3extension_h_

// Export type.  Methods defined with LC_API must be exported from the LC3 Simulator
// extension DLL.
#define LC_API extern "C" __declspec(dllexport)

// Each memory location and register is 16 bit
#define BITS unsigned short

// When getting or setting values in LC3 registers, each register
// can be identified by the following constants
#define LCEXT_R0	-1
#define LCEXT_R1	-2
#define LCEXT_R2	-3
#define LCEXT_R3	-4
#define LCEXT_R4	-5
#define LCEXT_R5	-6
#define LCEXT_R6	-7
#define LCEXT_R7	-8
#define LCEXT_PC	-9
#define LCEXT_PSR	-10

// GetValue and SetValue return one of the following status codes
#define LCEXT_SUCCESS			0	// The get/set was successful
#define LCEXT_NOT_IN_CALL		1	// The GetValue/SetValue function pointers are
									// only valid for the duration of the method call
									// and should not be saved.  This error results from
									// calling GetValue/SetValue from a saved pointer.
#define LCEXT_INVALID_LOCATION	2	// The specified location to get/set is not valid
#define LCEXT_INVALID_VALUE		3	// The value set to the PSR is invalid

// Return this value from FireInterupt if you are not firing an interrupt
#define NO_INTERRUPT			-1				

// When the DLL exported methods are called, they are passed in function pointers that
// can be used to get or set values in the LC3 address space.  The functions pointers
// are of the following type:
typedef int (*GetValueMethod)(int location, BITS &value);
typedef int (*SetValueMethod)(int location, BITS value);

// A required LC3 extension export.  This function must be implemented in your DLL with
// the following signature.  FireInterrupt3 is called at the beginning of each instruction
// cycle when an interrupt handler is not already running.  A return value of NO_INTERRUPT
// causes execution to continue normally.  A return value in the range of x80 to xFF causes
// an interrupt with that interrupt vector to fire.
LC_API int FireInterrupt3(GetValueMethod GetValue);

// A required LC3 extension export.  This function must be implemented in your DLL with
// the following signature.  ExecuteReservedOpcode3 is called when the simulator is
// executing an instruction with the reserved opcode.  The method is called during the
// execute phase of the instruction cycle.  The PC has already been incremented during the
// fetch phase.
LC_API void ExecuteReservedOpcode3(GetValueMethod GetValue, SetValueMethod SetValue);

#endif
