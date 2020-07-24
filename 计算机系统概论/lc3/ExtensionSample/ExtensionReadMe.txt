Files included:

ExtensionReadMe.txt	- this file
LC3Extension.h		- A reusable header defining all necessary functions and constants
ExtensionSample.vcproj	- A Microsoft Visual Studio .NET project file for building the sample
ExtensionSample.cpp	- A sample extension for the simulator
ExtensionTest.asm	- A sample LC-3 program that takes advantage of the sample extension

What is an extension?
An extension lets you add new functionality to the LC3 simulator.  An extension
is a DLL that exports two methods: FireInterrupt3 and ExecuteReservedOpcode3.
The simulator calls these methods at the appropriate time during the instruction
cycle to allow the extension to implement interrupts and/or to provide an
implementation for the reserved opcode in the LC3 ISA.

What must you implement?
Your DLL must export FireInterrupt3 and ExecuteReservedOpcode3.  The function
prototypes are defined in LC3Extension.h along with other constants that may be
useful in writing your extension.  A sample project is also included that
implements both of these functions.  LC3Extension.h is designed to be resused
in your own extension.  Each of these methods takes callback methods to
read and write to the various memory addresses and registers in the LC3 memory
space at the time of the call.

ExecuteReservedOpcode3 takes a callback for reading and writing values to the
LC3 memory space.  An implementation will typically use these callbacks to get
the bits of the current instruction then perform some custom operation given
those bits.

FireInterrupt3 returns the interrupt vector for the interrupt that should be
fired.  If no interrupt should be fired, the method returns NO_INTERRUPT.
This method takes only the read callback and therefore can not write to the
LC3 memory space.  Any modifications should be performed by the executing
program in the interrupt handler.  It is often the case that the interrupt
handler will make use of the reserved opcode to make further calls into the
extension.

The sample program
The included sample program can be compiled with Microsoft Visual Studio .Net.
It implements an interrupt, x0081, as a one second timer.  The simulator
calls FireInterrupt3 each time through the instruction cycle in which no
interrupt handler is executing.  The sample extension keeps track of the
amount of time since it last fired the interrupt.  If more than one second
has passed, it fires the interrupt again.

The accompanying LC3 application implements an interrupt handler for interrupt
x0081.  The handler executes an instruction that uses the reserved opcode.
The extension has defined the opcode to return a random number from 0 to 9
in the register defined in bits 9 to 11 of the instruction.  The LC3 program
then writes that value to the console in the interrupt handler.

Recommendations for your extensions
Don't cache the callback pointers you receive during the extension calls.
They should not be saved and used in other threads after your extension
returns.  They may also change from one call to the next.

The LC3 has been designed to operate on all 32 bit Windows operating systems
with a minimum of access rights.  As a result, the simulator does not access
the registry or require any type of installation.  It's expected that
the simulator will run in a variety of environments, from personal computers
to university networks.  Therefore it interacts as little as possible with
permissioned system resources and does not take advantage of any functionality
available only in more recent operating systems.  Please keep this in mind
when considering who will use your extension and how you intend to
distribute it.
