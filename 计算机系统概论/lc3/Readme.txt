LC-3 Software README.TXT
August 17, 2003

Contents
--------
The LC-3 Software for Windows Distribution
contains the following files:

Simulate.exe - the LC-3 Simulator
Simulate.hlp - Simulator help file
Simulate.cnt - Simulator help file
LC3Edit.exe  - the LC-3 Editor
LC3Edit.hlp  - LC3Edit help file
LC3Edit.cnt  - LC3Edit help file
Readme.txt   - this file

Additionally, the following files are included to assist in writing extensions
for the LC-3 simulator:

ExtensionReadMe.txt	- A read me file that describes how to write extensions
LC3Extension.h		- A reusable header defining all necessary functions and constants
ExtensionSample.vcproj	- A Microsoft Visual Studio .NET project file for building the sample
ExtensionSample.cpp	- A sample extension for the simulator
ExtensionTest.asm	- A sample LC-3 program that takes advantage of the sample extension

Installation and Usage
----------------------
The LC-3 Software does not require a specific installation.  You may run
it directly off of the CD or copy it to your hard drive for easier access.

Directions and help information are available for both the simulator and the
editor by selecting the "Contents" option from the "Help" menu in each
respective program.


Version History
---------------
(Sep  3, 2003) Simulate v3.01 - Fixed bugs in interrupt PSR push and I/O
				status/data register locations
(Aug 17, 2003) Simulate v3.00 - Updated to the LC-3 architecture
			      - Added support for extensions
(Aug 17, 2003) LC3Edit  v3.00 - Updated to the LC-3 architecture
(Nov  4, 2001) Simulate v2.03 - Added the ability to save memory contents
(Jan 20, 2001) LC2Edit  v1.03 - Fixed a problem with invalid characters appearing
                                in the lst file
(Nov 12, 2000) Simulate v2.02 - Fixed a bug with the toggle breakpoint option
                                Added the ability to save console output
(Jun 16, 2000) LC2Edit  v1.02 - Initial Release
(Jun 16, 2000) Simulate v2.01 - Initial Release


Legal Information
-----------------
This software is provided "AS IS".  No warranty is expressed or implied.
Permission to copy without fee all or part of this material is granted
provided that the copies are not made or distributed for direct commercial
advantage, this copyright notice is included, and notice that copying is
by permission of the author of this software.  To copy otherwise, or to
republish, requires a fee and/or specific written permission from the author.

Copyright (c) 1998 - 2003 Brian J. Hartman
brianhartman@hotmail.com
