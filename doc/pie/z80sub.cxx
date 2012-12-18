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

// Table with parity, sign and zero flags precomputed for each byte value
unsigned char Z80::PSZ_[256] = {
    Zero|Parity, 0, 0, Parity, 0, Parity, Parity, 0, 0, Parity, Parity, 0, Parity, 0, 0, Parity, 
    0, Parity, Parity, 0, Parity, 0, 0, Parity, Parity, 0, 0, Parity, 0, Parity, Parity, 0, 
    0, Parity, Parity, 0, Parity, 0, 0, Parity, Parity, 0, 0, Parity, 0, Parity, Parity, 0, 
    Parity, 0, 0, Parity, 0, Parity, Parity, 0, 0, Parity, Parity, 0, Parity, 0, 0, Parity, 
    0, Parity, Parity, 0, Parity, 0, 0, Parity, Parity, 0, 0, Parity, 0, Parity, Parity, 0, 
    Parity, 0, 0, Parity, 0, Parity, Parity, 0, 0, Parity, Parity, 0, Parity, 0, 0, Parity, 
    Parity, 0, 0, Parity, 0, Parity, Parity, 0, 0, Parity, Parity, 0, Parity, 0, 0, Parity, 
    0, Parity, Parity, 0, Parity, 0, 0, Parity, Parity, 0, 0, Parity, 0, Parity, Parity, 0, 
    Sign, Sign|Parity, Sign|Parity, Sign, Sign|Parity, Sign, Sign, Sign|Parity, Sign|Parity, Sign, Sign, Sign|Parity, Sign, Sign|Parity, Sign|Parity, Sign, 
    Sign|Parity, Sign, Sign, Sign|Parity, Sign, Sign|Parity, Sign|Parity, Sign, Sign, Sign|Parity, Sign|Parity, Sign, Sign|Parity, Sign, Sign, Sign|Parity, 
    Sign|Parity, Sign, Sign, Sign|Parity, Sign, Sign|Parity, Sign|Parity, Sign, Sign, Sign|Parity, Sign|Parity, Sign, Sign|Parity, Sign, Sign, Sign|Parity, 
    Sign, Sign|Parity, Sign|Parity, Sign, Sign|Parity, Sign, Sign, Sign|Parity, Sign|Parity, Sign, Sign, Sign|Parity, Sign, Sign|Parity, Sign|Parity, Sign, 
    Sign|Parity, Sign, Sign, Sign|Parity, Sign, Sign|Parity, Sign|Parity, Sign, Sign, Sign|Parity, Sign|Parity, Sign, Sign|Parity, Sign, Sign, Sign|Parity, 
    Sign, Sign|Parity, Sign|Parity, Sign, Sign|Parity, Sign, Sign, Sign|Parity, Sign|Parity, Sign, Sign, Sign|Parity, Sign, Sign|Parity, Sign|Parity, Sign, 
    Sign, Sign|Parity, Sign|Parity, Sign, Sign|Parity, Sign, Sign, Sign|Parity, Sign|Parity, Sign, Sign, Sign|Parity, Sign, Sign|Parity, Sign|Parity, Sign, 
    Sign|Parity, Sign, Sign, Sign|Parity, Sign, Sign|Parity, Sign|Parity, Sign, Sign, Sign|Parity, Sign|Parity, Sign, Sign|Parity, Sign, Sign, Sign|Parity
};

/*
    Adds the specified byte op to the accumulator, adding
    carry.
*/
void Z80::addByte( unsigned char op, unsigned char cf )
{
    unsigned    x = A + op;

    if( cf ) x++; // Add carry

    F = 0;
    if( !(x & 0xFF) ) F |= Zero;
    if( x & 0x80 ) F |= Sign;
    if( x >= 0x100 ) F |= Carry;

    /*
        Halfcarry is set on carry from the low order four bits.

        To see how to compute it, let's take a look at the following table, which
        shows the binary addition of two binary numbers:

        A   B   A+B
        -----------
        0   0   0
        0   1   1
        1   0   1
        1   1   0

        Note that if only the lowest bit is used, then A+B, A-B and A^B yield the same 
        value. If we know A, B and the sum A+B+C, then C is easily derived:
            C = A+B+C - A - B,  that is
            C = A+B+C ^ A ^ B.

        For the halfcarry, A and B above are the fifth bit of a byte, which corresponds
        to the value 0x10. So:

            Halfcarry = ((accumulator+operand+halfcarry) ^ accumulator ^ operand) & 0x10

        Note that masking off all bits but one is important because we have worked all
        the math by using one bit only.
    */
    if( (A ^ op ^ x) & 0x10 ) F |= Halfcarry;

    /*
        The overflow bit is set when the result is too large to fit into the destination
        register, causing a change in the sign bit.

        For a sum, we can only have overflow when adding two numbers that are both positive
        or both negative. For example 0x5E + 0x4B (94 + 75) yields 0xA9 (169), which fits
        into an 8-bit register only if it is interpreted as an unsigned number. If we 
        consider the result as a signed integer, then 0xA9 corresponds to decimal -87 and
        we have overflow.
        Note that if we add two signed numbers of opposite sign then we cannot overflow
        the destination register, because the absolute value of the result will always fit
        in 7 bits, leaving the most significant bit free for use as a sign bit.

        We can code all the above concisely by noting that:

            ~(A ^ op) & 0x80

        is true if and only if A and op have the same sign. Also:

            (x ^ op) & 0x80

        is true if and only if the sum of A and op has taken a sign opposite to that
        of its operands.

        Thus the expression:

            ~(A ^ op) & (x ^ op) & 0x80

        reads "A has the same sign as op, and the opposite as x", where x is the sum of
        A and op (and an optional carry).
    */
    if( ~(A ^ op) & (x ^ op) & 0x80 ) F |= Overflow;

    A = x;
}

/*
    Subtracts the specified byte op from the accumulator, using carry as
    borrow from a previous operation.
*/
unsigned char Z80::subByte( unsigned char op, unsigned char cf )
{
    unsigned char   x = A - op;

    if( cf ) x--;

    F = Subtraction;
    if( x == 0 ) F |= Zero;
    if( x & 0x80 ) F |= Sign;
    if( (x >= A) && (op | cf)) F |= Carry;

    // See addByte() for an explanation of the halfcarry bit
    if( (A ^ op ^ x) & 0x10 ) F |= Halfcarry;

    // See addByte() for an explanation of the overflow bit. The only difference here
    // is that for a subtraction we must check that the two operands have different
    // sign, because in fact A-B is A+(-B). Note however that since subtraction is not
    // symmetric, we have to use (x ^ A) to get the correct result, whereas for the
    // addition (x ^ A) is equivalent to (x ^ op)
    if( (A ^ op) & (x ^ A) & 0x80 ) F |= Overflow;

    return x;
}

/*
    Sets the interrupt mode to IM0, IM1 or IM2.
*/
void Z80::setInterruptMode( unsigned mode )
{
    if( mode <= 2 ) {
        iflags_ = (iflags_ & ~0x03) | mode;
    }
}

/*
    Calls a subroutine at the specified address.
*/
void Z80::callSub( unsigned addr )
{
    SP -= 2;
    writeWord( SP, PC ); // Save current program counter in the stack
    PC = addr & 0xFFFF; // Jump to the specified address
}

/*
    Decrements a byte value by one. 
    Note that this is different from subtracting one from the byte value,
    because flags behave differently.
*/
unsigned char Z80::decByte( unsigned char b )
{
    F = Subtraction | (F & Carry); // Preserve the carry flag
    if( (b & 0x0F) == 0 ) F |= Halfcarry;
    --b;
    if( b == 0x7F ) F |= Overflow;
    if( b & 0x80 ) F |= Sign;
    if( b == 0 ) F |= Zero;

    return b;
}

/*
    Increments a byte value by one. 
    Note that this is different from adding one to the byte value,
    because flags behave differently.
*/
unsigned char Z80::incByte( unsigned char b )
{
    ++b;
    F &= Carry; // Preserve the carry flag
    if( ! (b & 0x0F) ) F |= Halfcarry;
    if( b == 0x80 ) F |= Overflow;
    if( b & 0x80 ) F |= Sign;
    if( b == 0 ) F |= Zero;

    return b;
}

/*
    Reads one byte from port C, updating flags according to the rules of "IN r,(C)".
*/
unsigned char Z80::inpReg()
{
    unsigned char   r = env_.readPort( C );

    F = (F & Carry) | PSZ_[r];

    return r;
}

/*
    Performs a relative jump to the specified offset.
*/
void Z80::relJump( unsigned char o )
{
    int offset = (int)((char)o);

    PC = (unsigned)((int)PC + offset) & 0xFFFF;
    cycles_++;
}

/*
    Returns from a subroutine, popping the saved Program Counter from the stack.
*/
void Z80::retFromSub()
{
    PC = readWord( SP );
    SP += 2;
}

/*
    Rotates left one byte thru the carry flag.
*/
unsigned char Z80::rotateLeft( unsigned char op )
{
    unsigned char f = F;

    F = 0;
    if( op & 0x80 ) F |= Carry;
    op <<= 1;
    if( f & Carry ) op |= 0x01;
    F |= PSZ_[op];
    
    return op;
}

/*
    Rotates left one byte copying the most significant bit (bit 7) in the carry flag.
*/
unsigned char Z80::rotateLeftCarry( unsigned char op )
{
    F = 0;
    if( op & 0x80 ) F |= Carry;
    op = (op << 1) | (op >> 7);
    F |= PSZ_[op];
    
    return op;
}

/*
    Rotates right one byte thru the carry flag.
*/
unsigned char Z80::rotateRight( unsigned char op )
{
    unsigned char f = F;

    F = 0;
    if( op & 0x01 ) F |= Carry;
    op >>= 1;
    if( f & Carry ) op |= 0x80;
    F |= PSZ_[op];
    
    return op;
}

/*
    Rotates right one byte copying the least significant bit (bit 0) in the carry flag.
*/
unsigned char Z80::rotateRightCarry( unsigned char op )
{
    F = 0;
    if( op & 0x01 ) F |= Carry;
    op = (op >> 1) | (op << 7);
    F |= PSZ_[op];
    
    return op;
}

/*
    Shifts left one byte.
*/
unsigned char Z80::shiftLeft( unsigned char op )
{
    F = 0;
    if( op & 0x80 ) F |= Carry;
    op <<= 1;
    F |= PSZ_[op];
    
    return op;
}

/*
    Shifts right one byte, preserving its sign (most significant bit).
*/
unsigned char Z80::shiftRightArith( unsigned char op )
{
    F = 0;
    if( op & 0x01 ) F |= Carry;
    op = (op >> 1) | (op & 0x80);

    F |= PSZ_[op];
    
    return op;
}

/*
    Shifts right one byte.
*/
unsigned char Z80::shiftRightLogical( unsigned char op )
{
    F = 0;
    if( op & 0x01 ) F |= Carry;
    op >>= 1;

    F |= PSZ_[op];
    
    return op;
}

/*
    Tests whether the specified bit of op is set.
*/
void Z80::testBit( unsigned char bit, unsigned char op )
{
    // Flags for a bit test operation are:
    // S, P: unknown
    // Z: set if bit is zero, reset otherwise
    // N: reset
    // H: set
    // C: unaffected
    // However, it seems that parity is always set like Z, so we emulate that as well.
    F = (F & (Carry | Sign)) | Halfcarry;

    if( (op & (1 << bit)) == 0 ) {
        // Bit is not set, so set the zero flag
        F |= Zero | Parity;
    }
}
