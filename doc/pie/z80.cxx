/*
    Z80 emulator

    Copyright (c) 1996-2003,2004 Alessandro Scotti
    http://www.ascotti.org/

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
*/
#include "z80.h"

/* Constructor */
Z80::Z80( Z80Environment & env )
    : env_( env )
{
    reset();
}

/* Copy constructor (it's ok to use the assignment operator in this case) */
Z80::Z80( const Z80 & cpu )
    : env_( cpu.env_ )
{
    operator = ( cpu );
}

/* Assignment operator */
Z80 & Z80::operator = ( const Z80 & cpu )
{
    B = cpu.B;
    C = cpu.C;
    D = cpu.D;
    E = cpu.E;
    H = cpu.H;
    L = cpu.L;
    A = cpu.A;
    F = cpu.F;
    B1 = cpu.B1;
    C1 = cpu.C1;
    D1 = cpu.D1;
    E1 = cpu.E1;
    H1 = cpu.H1;
    L1 = cpu.L1;
    A1 = cpu.A1;
    F1 = cpu.F1;
    IX = cpu.IX;
    IY = cpu.IY;
    PC = cpu.PC;
    SP = cpu.SP;
    I = cpu.I;
    R = cpu.R;

    iflags_ = iflags_;
    cycles_ = cycles_;

    return *this;
}

/* Resets the CPU */
void Z80::reset()
{
    PC = 0;         // Program counter is zero
    I = 0;          // Interrupt register cleared
    R = 0;          // Memory refresh register cleared
    iflags_ = 0;    // IFF1 and IFF2 cleared, IM0 enabled
    cycles_ = 0;    // Could that be 2 (according to some Zilog docs)?

    // There is no official documentation for the following!
    B = B1 = 0; 
    C = C1 = 0;
    D = D1 = 0; 
    E = E1 = 0;
    H = H1 = 0;
    L = L1 = 0;
    A = A1 = 0;
    F = F1 = 0;
    IX = 0;
    IY = 0;
    SP = 0xF000;
}

unsigned Z80::getSizeOfSnapshotBuffer() const
{
    unsigned result =
        8*2 +   // 8-bit registers
        1 +     // I
        1 +     // R
        2 +     // IX
        2 +     // IY
        2 +     // PC
        2 +     // SP
        4 +     // iflags_
        4;      // cycles_    

    return result;
}

static unsigned saveUint16( unsigned char * buffer, unsigned u )
{
    *buffer++ = (unsigned char) (u >> 8);
    *buffer   = (unsigned char) (u);

    return 2;
}

unsigned Z80::takeSnapshot( unsigned char * buffer )
{
    unsigned char * buf = buffer;

    *buf++ = A; *buf++ = A1;
    *buf++ = B; *buf++ = B1;
    *buf++ = C; *buf++ = C1;
    *buf++ = D; *buf++ = D1;
    *buf++ = E; *buf++ = E1;
    *buf++ = H; *buf++ = H1;
    *buf++ = L; *buf++ = L1;
    *buf++ = F; *buf++ = F1;

    *buf++ = I;
    *buf++ = R;

    buf += saveUint16( buf, IX );
    buf += saveUint16( buf, IY );
    buf += saveUint16( buf, PC );
    buf += saveUint16( buf, SP );

    buf += saveUint16( buf, iflags_ >> 16 );
    buf += saveUint16( buf, iflags_ );
    buf += saveUint16( buf, cycles_ >> 16 );
    buf += saveUint16( buf, cycles_ );

    return buffer - buf;
}

static unsigned loadUint16( unsigned char ** buffer )
{
    unsigned char * buf = *buffer;
    unsigned result = *buf++;

    result = (result << 8) | *buf++;

    *buffer = buf;

    return result;
}

unsigned Z80::restoreSnapshot( unsigned char * buffer )
{
    unsigned char * buf = buffer;

    A = *buf++; A1 = *buf++;
    B = *buf++; B1 = *buf++;
    C = *buf++; C1 = *buf++;
    D = *buf++; D1 = *buf++;
    E = *buf++; E1 = *buf++;
    H = *buf++; H1 = *buf++;
    L = *buf++; L1 = *buf++;
    F = *buf++; F1 = *buf++;

    I = *buf++;
    R = *buf++;

    IX = loadUint16( &buf );
    IY = loadUint16( &buf );
    PC = loadUint16( &buf );
    SP = loadUint16( &buf );

    iflags_ = loadUint16( &buf );
    iflags_ = (iflags_ << 16) | loadUint16(&buf);
    cycles_ = loadUint16( &buf );
    cycles_ = (cycles_ << 16) | loadUint16(&buf);

    return buf - buffer;
}

/* Executes one instruction */
void Z80::step()
{
    // Update memory refresh register (not strictly needed but...)
    R = (R+1) & 0x7F; 

    if( iflags_ & Halted ) {
        // CPU is halted, do a NOP instruction
        cycles_ += OpInfo_[0].cycles; // NOP
    }
    else {
        // Get the opcode to execute
        unsigned op = fetchByte();

        // Update the cycles counter with the number of cycles for this opcode
        cycles_ += OpInfo_[ op ].cycles;

        // Execute the opcode handler
        (this->*(OpInfo_[ op ].handler))();

        // Update registers
        PC &= 0xFFFF; // Clip program counter
        SP &= 0xFFFF; // Clip stack pointer
    }
}

/*
    Runs the CPU for the specified number of cycles.

    Note: the memory refresh register is not updated!
*/
unsigned Z80::run( unsigned runCycles )
{
    unsigned target_cycles = cycles_ + runCycles;

    // Execute instructions until the specified number of
    // cycles has elapsed
    while( cycles_ < target_cycles ) {
        if( iflags_ & Halted ) {
            // CPU is halted, do NOPs for the rest of cycles
            // (this may be off by a few cycles)
            cycles_ = target_cycles;
        }
        else {
            // Get the opcode to execute
            unsigned op = fetchByte();

            // Update the cycles counter with the number of cycles for this opcode
            cycles_ += OpInfo_[ op ].cycles; 

            // Execute the opcode handler
            (this->*(OpInfo_[ op ].handler))();
        }
    }

    // Update registers
    PC &= 0xFFFF; // Clip program counter
    SP &= 0xFFFF; // Clip stack pointer

    // Return the number of extra cycles executed
    return cycles_ - target_cycles;
}

/* Interrupt */
void Z80::interrupt( unsigned char data )
{
    // Execute interrupt only if interrupts are enabled
    if( iflags_ & IFF1 ) {
        // Disable maskable interrupts and restart the CPU if halted
        iflags_ &= ~(IFF1 | IFF2 | Halted); 

        switch( getInterruptMode() ) {
        case 0:
            (this->*(OpInfo_[ data ].handler))();
            cycles_ += 11;
            break;
        case 1:
            callSub( 0x38 );
            cycles_ += 11;
            break;
        case 2:
            callSub( readWord( ((unsigned)I) << 8 | (data & 0xFE) ) );
            cycles_ += 19;
            break;
        }
    }
}

/* Non-maskable interrupt */
void Z80::nmi()
{
    // Disable maskable interrupts but preserve IFF2 (that is a copy of IFF1),
    // also restart the CPU if halted
    iflags_ &= ~(IFF1 | Halted);

    callSub( 0x66 );

    cycles_ += 11;
}
