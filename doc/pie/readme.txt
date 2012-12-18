PIE - Pacman Instructional Emulator
Copyright (c) 1996-2004 Alessandro Scotti
http://www.ascotti.org/

Emulator and Win32 front-end sources.

The sources can be compiled with Visual C++ (makefile.vc)
or MinGW/g++ (makefile.mgw).

Homepage for the PIE emulator is:
http://www.ascotti.org/programming/pie/pie.htm

Supported games are:
* Namco Pacman, with ROM files:
  - namcopac.6e
  - namcopac.6f
  - namcopac.6h
  - namcopac.6j
  - pacman.5e
  - pacman.5f
* Midway Pacman, with ROM files:
  - pacman.6e
  - pacman.6f
  - pacman.6h
  - pacman.6j
  - pacman.5e
  - pacman.5f
* Ms. Pacman, with ROM files:
  - pacman.6e
  - pacman.6f
  - pacman.6h
  - pacman.6j
  - 5e
  - 5f
  - u5
  - u6
  - u7

In addition to the above ROMs the emulator also needs the color
ROM files:
- 82s123.7f
- 82s126.4a

The ROM files are the same required by MAME and other
emulators and they must be present in the directory from where the
emulator is started. Note however that MAME stores ROMs in ZIP files, 
while PIE is not able to read ZIPs and must have the files 
(unzipped and) directly available. The name for the MAME ZIP files
are: pacman.zip (Namco edition), pacmanm.zip (Midway edition) and
mspacman.zip.

Please remember that the Pacman game ROM(s) are copyrighted material
and are not included with the emulator. Furthermore, they must
be *never* bundled or distributed together with this emulator in
any format or media.
  
HISTORY
-------
29 dec 2003 Version 1.00
	- Initial release

12 jan 2004 Version 1.10
	- Emulator/documentation has been enhanced to support
	  all known features. 
	- Trimmed unused MFC references from resource.h/.rc to allow 
	  compilation with MinGW/g++.
	- Added minimalist makefiles for MinGW and Visual C++.
	- Double screen size is now allowed, required some adjustement
	  to make it fast enough.
	- The Dib24 class has been documented in ccdoc style.
	- Added new DIP switches: cocktail mode (try it with a 
	  two-players game!), test mode, rack advance and others.
	- Added the Pacman speed hack.
	- Some changes in the Z80 emulator (see z80_history.txt).
	- Added support for Ms. Pacman (just for fun).
	- Sound chip is emulated separately (and a bug was discovered
	  while doing the change, so now sound is correct...)

15 jan 2004 Version 1.12
	- Using DirectDraw for display, it's now fast enough.
	- Fixed a possible bug (?) in sound handling.
	- Sound is still giving trouble, with different behavior
	  on different machines. A triple buffering scheme seems
	  to help for now...


LICENSE
-------

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
