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

Z80::OpcodeInfo Z80::OpInfoFD_[256] = {
    { 0, 0 }, // 0x00
    { 0, 0 }, // 0x01
    { 0, 0 }, // 0x02
    { 0, 0 }, // 0x03
    { 0, 0 }, // 0x04
    { 0, 0 }, // 0x05
    { 0, 0 }, // 0x06
    { 0, 0 }, // 0x07
    { 0, 0 }, // 0x08
    { &Z80::opcode_fd_09, 15 }, // ADD IY, BC
    { 0, 0 }, // 0x0A
    { 0, 0 }, // 0x0B
    { 0, 0 }, // 0x0C
    { 0, 0 }, // 0x0D
    { 0, 0 }, // 0x0E
    { 0, 0 }, // 0x0F
    { 0, 0 }, // 0x10
    { 0, 0 }, // 0x11
    { 0, 0 }, // 0x12
    { 0, 0 }, // 0x13
    { 0, 0 }, // 0x14
    { 0, 0 }, // 0x15
    { 0, 0 }, // 0x16
    { 0, 0 }, // 0x17
    { 0, 0 }, // 0x18
    { &Z80::opcode_fd_19, 15 }, // ADD IY, DE
    { 0, 0 }, // 0x1A
    { 0, 0 }, // 0x1B
    { 0, 0 }, // 0x1C
    { 0, 0 }, // 0x1D
    { 0, 0 }, // 0x1E
    { 0, 0 }, // 0x1F
    { 0, 0 }, // 0x20
    { &Z80::opcode_fd_21, 14 }, // LD IY, nn
    { &Z80::opcode_fd_22, 20 }, // LD (nn), IY
    { &Z80::opcode_fd_23, 10 }, // INC IY
    { &Z80::opcode_fd_24,  9 }, // INC IYH
    { &Z80::opcode_fd_25,  9 }, // DEC IYH
    { &Z80::opcode_fd_26,  9 }, // LD IYH, n
    { 0, 0 }, // 0x27
    { 0, 0 }, // 0x28
    { &Z80::opcode_fd_29, 15 }, // ADD IY, IY
    { &Z80::opcode_fd_2a, 20 }, // LD IY, (nn)
    { &Z80::opcode_fd_2b, 10 }, // DEC IY
    { &Z80::opcode_fd_2c,  9 }, // INC IYL
    { &Z80::opcode_fd_2d,  9 }, // DEC IYL
    { &Z80::opcode_fd_2e,  9 }, // LD IYL, n
    { 0, 0 }, // 0x2F
    { 0, 0 }, // 0x30
    { 0, 0 }, // 0x31
    { 0, 0 }, // 0x32
    { 0, 0 }, // 0x33
    { &Z80::opcode_fd_34, 23 }, // INC (IY + d)
    { &Z80::opcode_fd_35, 23 }, // DEC (IY + d)
    { &Z80::opcode_fd_36, 19 }, // LD (IY + d), n
    { 0, 0 }, // 0x37
    { 0, 0 }, // 0x38
    { &Z80::opcode_fd_39, 15 }, // ADD IY, SP
    { 0, 0 }, // 0x3A
    { 0, 0 }, // 0x3B
    { 0, 0 }, // 0x3C
    { 0, 0 }, // 0x3D
    { 0, 0 }, // 0x3E
    { 0, 0 }, // 0x3F
    { 0, 0 }, // 0x40
    { 0, 0 }, // 0x41
    { 0, 0 }, // 0x42
    { 0, 0 }, // 0x43
    { &Z80::opcode_fd_44,  9 }, // LD B, IYH
    { &Z80::opcode_fd_45,  9 }, // LD B, IYL
    { &Z80::opcode_fd_46, 19 }, // LD B, (IY + d)
    { 0, 0 }, // 0x47
    { 0, 0 }, // 0x48
    { 0, 0 }, // 0x49
    { 0, 0 }, // 0x4A
    { 0, 0 }, // 0x4B
    { &Z80::opcode_fd_4c,  9 }, // LD C, IYH
    { &Z80::opcode_fd_4d,  9 }, // LD C, IYL
    { &Z80::opcode_fd_4e, 19 }, // LD C, (IY + d)
    { 0, 0 }, // 0x4F
    { 0, 0 }, // 0x50
    { 0, 0 }, // 0x51
    { 0, 0 }, // 0x52
    { 0, 0 }, // 0x53
    { &Z80::opcode_fd_54,  9 }, // LD D, IYH
    { &Z80::opcode_fd_55,  9 }, // LD D, IYL
    { &Z80::opcode_fd_56, 19 }, // LD D, (IY + d)
    { 0, 0 }, // 0x57
    { 0, 0 }, // 0x58
    { 0, 0 }, // 0x59
    { 0, 0 }, // 0x5A
    { 0, 0 }, // 0x5B
    { &Z80::opcode_fd_5c,  9 }, // LD E, IYH
    { &Z80::opcode_fd_5d,  9 }, // LD E, IYL
    { &Z80::opcode_fd_5e, 19 }, // LD E, (IY + d)
    { 0, 0 }, // 0x5F
    { &Z80::opcode_fd_60,  9 }, // LD IYH, B
    { &Z80::opcode_fd_61,  9 }, // LD IYH, C
    { &Z80::opcode_fd_62,  9 }, // LD IYH, D
    { &Z80::opcode_fd_63,  9 }, // LD IYH, E
    { &Z80::opcode_fd_64,  9 }, // LD IYH, IYH
    { &Z80::opcode_fd_65,  9 }, // LD IYH, IYL
    { &Z80::opcode_fd_66,  9 }, // LD H, (IY + d)
    { &Z80::opcode_fd_67,  9 }, // LD IYH, A
    { &Z80::opcode_fd_68,  9 }, // LD IYL, B
    { &Z80::opcode_fd_69,  9 }, // LD IYL, C
    { &Z80::opcode_fd_6a,  9 }, // LD IYL, D
    { &Z80::opcode_fd_6b,  9 }, // LD IYL, E
    { &Z80::opcode_fd_6c,  9 }, // LD IYL, IYH
    { &Z80::opcode_fd_6d,  9 }, // LD IYL, IYL
    { &Z80::opcode_fd_6e,  9 }, // LD L, (IY + d)
    { &Z80::opcode_fd_6f,  9 }, // LD IYL, A
    { &Z80::opcode_fd_70, 19 }, // LD (IY + d), B
    { &Z80::opcode_fd_71, 19 }, // LD (IY + d), C
    { &Z80::opcode_fd_72, 19 }, // LD (IY + d), D
    { &Z80::opcode_fd_73, 19 }, // LD (IY + d), E
    { &Z80::opcode_fd_74, 19 }, // LD (IY + d), H
    { &Z80::opcode_fd_75, 19 }, // LD (IY + d), L
    { 0,19 }, // 0x76
    { &Z80::opcode_fd_77, 19 }, // LD (IY + d), A
    { 0, 0 }, // 0x78
    { 0, 0 }, // 0x79
    { 0, 0 }, // 0x7A
    { 0, 0 }, // 0x7B
    { &Z80::opcode_fd_7c,  9 }, // LD A, IYH
    { &Z80::opcode_fd_7d,  9 }, // LD A, IYL
    { &Z80::opcode_fd_7e, 19 }, // LD A, (IY + d)
    { 0, 0 }, // 0x7F
    { 0, 0 }, // 0x80
    { 0, 0 }, // 0x81
    { 0, 0 }, // 0x82
    { 0, 0 }, // 0x83
    { &Z80::opcode_fd_84,  9 }, // ADD A, IYH
    { &Z80::opcode_fd_85,  9 }, // ADD A, IYL
    { &Z80::opcode_fd_86, 19 }, // ADD A, (IY + d)
    { 0, 0 }, // 0x87
    { 0, 0 }, // 0x88
    { 0, 0 }, // 0x89
    { 0, 0 }, // 0x8A
    { 0, 0 }, // 0x8B
    { &Z80::opcode_fd_8c,  9 }, // ADC A, IYH
    { &Z80::opcode_fd_8d,  9 }, // ADC A, IYL
    { &Z80::opcode_fd_8e, 19 }, // ADC A, (IY + d)
    { 0, 0 }, // 0x8F
    { 0, 0 }, // 0x90
    { 0, 0 }, // 0x91
    { 0, 0 }, // 0x92
    { 0, 0 }, // 0x93
    { &Z80::opcode_fd_94,  9 }, // SUB IYH
    { &Z80::opcode_fd_95,  9 }, // SUB IYL
    { &Z80::opcode_fd_96, 19 }, // SUB (IY + d)
    { 0, 0 }, // 0x97
    { 0, 0 }, // 0x98
    { 0, 0 }, // 0x99
    { 0, 0 }, // 0x9A
    { 0, 0 }, // 0x9B
    { &Z80::opcode_fd_9c,  9 }, // SBC A, IYH
    { &Z80::opcode_fd_9d,  9 }, // SBC A, IYL
    { &Z80::opcode_fd_9e, 19 }, // SBC A, (IY + d)
    { 0, 0 }, // 0x9F
    { 0, 0 }, // 0xA0
    { 0, 0 }, // 0xA1
    { 0, 0 }, // 0xA2
    { 0, 0 }, // 0xA3
    { &Z80::opcode_fd_a4,  9 }, // AND IYH
    { &Z80::opcode_fd_a5,  9 }, // AND IYL
    { &Z80::opcode_fd_a6, 19 }, // AND (IY + d)
    { 0, 0 }, // 0xA7
    { 0, 0 }, // 0xA8
    { 0, 0 }, // 0xA9
    { 0, 0 }, // 0xAA
    { 0, 0 }, // 0xAB
    { &Z80::opcode_fd_ac,  9 }, // XOR IYH
    { &Z80::opcode_fd_ad,  9 }, // XOR IYL
    { &Z80::opcode_fd_ae, 19 }, // XOR (IY + d)
    { 0, 0 }, // 0xAF
    { 0, 0 }, // 0xB0
    { 0, 0 }, // 0xB1
    { 0, 0 }, // 0xB2
    { 0, 0 }, // 0xB3
    { &Z80::opcode_fd_b4,  9 }, // OR IYH
    { &Z80::opcode_fd_b5,  9 }, // OR IYL
    { &Z80::opcode_fd_b6, 19 }, // OR (IY + d)
    { 0, 0 }, // 0xB7
    { 0, 0 }, // 0xB8
    { 0, 0 }, // 0xB9
    { 0, 0 }, // 0xBA
    { 0, 0 }, // 0xBB
    { &Z80::opcode_fd_bc,  9 }, // CP IYH
    { &Z80::opcode_fd_bd,  9 }, // CP IYL
    { &Z80::opcode_fd_be, 19 }, // CP (IY + d)
    { 0, 0 }, // 0xBF
    { 0, 0 }, // 0xC0
    { 0, 0 }, // 0xC1
    { 0, 0 }, // 0xC2
    { 0, 0 }, // 0xC3
    { 0, 0 }, // 0xC4
    { 0, 0 }, // 0xC5
    { 0, 0 }, // 0xC6
    { 0, 0 }, // 0xC7
    { 0, 0 }, // 0xC8
    { 0, 0 }, // 0xC9
    { 0, 0 }, // 0xCA
    { &Z80::opcode_fd_cb,  0 }, // 
    { 0, 0 }, // 0xCC
    { 0, 0 }, // 0xCD
    { 0, 0 }, // 0xCE
    { 0, 0 }, // 0xCF
    { 0, 0 }, // 0xD0
    { 0, 0 }, // 0xD1
    { 0, 0 }, // 0xD2
    { 0, 0 }, // 0xD3
    { 0, 0 }, // 0xD4
    { 0, 0 }, // 0xD5
    { 0, 0 }, // 0xD6
    { 0, 0 }, // 0xD7
    { 0, 0 }, // 0xD8
    { 0, 0 }, // 0xD9
    { 0, 0 }, // 0xDA
    { 0, 0 }, // 0xDB
    { 0, 0 }, // 0xDC
    { 0, 0 }, // 0xDD
    { 0, 0 }, // 0xDE
    { 0, 0 }, // 0xDF
    { 0, 0 }, // 0xE0
    { &Z80::opcode_fd_e1, 14 }, // POP IY
    { 0, 0 }, // 0xE2
    { &Z80::opcode_fd_e3, 23 }, // EX (SP), IY
    { 0, 0 }, // 0xE4
    { &Z80::opcode_fd_e5, 15 }, // PUSH IY
    { 0, 0 }, // 0xE6
    { 0, 0 }, // 0xE7
    { 0, 0 }, // 0xE8
    { &Z80::opcode_fd_e9,  8 }, // JP (IY)
    { 0, 0 }, // 0xEA
    { 0, 0 }, // 0xEB
    { 0, 0 }, // 0xEC
    { 0, 0 }, // 0xED
    { 0, 0 }, // 0xEE
    { 0, 0 }, // 0xEF
    { 0, 0 }, // 0xF0
    { 0, 0 }, // 0xF1
    { 0, 0 }, // 0xF2
    { 0, 0 }, // 0xF3
    { 0, 0 }, // 0xF4
    { 0, 0 }, // 0xF5
    { 0, 0 }, // 0xF6
    { 0, 0 }, // 0xF7
    { 0, 0 }, // 0xF8
    { &Z80::opcode_fd_f9, 10 }, // LD SP, IY
    { 0, 0 }, // 0xFA
    { 0, 0 }, // 0xFB
    { 0, 0 }, // 0xFC
    { 0, 0 }, // 0xFD
    { 0, 0 }, // 0xFE
    { 0, 0 }  // 0xFF
};

void Z80::opcode_fd_09()    // ADD IY, BC
{
    unsigned rr = BC();

    F &= (Zero | Sign | Parity);
    if( ((IY & 0xFFF)+(rr & 0xFFF)) > 0xFFF ) F |= Halfcarry;
    IY += rr;
    if( IY & 0x10000 ) F |= Carry;
}

void Z80::opcode_fd_19()    // ADD IY, DE
{
    unsigned rr = DE();

    F &= (Zero | Sign | Parity);
    if( ((IY & 0xFFF)+(rr & 0xFFF)) > 0xFFF ) F |= Halfcarry;
    IY += rr;
    if( IY & 0x10000 ) F |= Carry;
}

void Z80::opcode_fd_21()    // LD IY, nn
{
    IY = fetchWord();
}

void Z80::opcode_fd_22()    // LD (nn), IY
{
    writeWord( fetchWord(), IY );
}

void Z80::opcode_fd_23()    // INC IY
{
    IY++;
}

void Z80::opcode_fd_24()    // INC IYH
{
    IY = (IY & 0xFF) | ((unsigned)incByte( IY >> 8 ) << 8);
}

void Z80::opcode_fd_25()    // DEC IYH
{
    IY = (IY & 0xFF) | ((unsigned)decByte( IY >> 8 ) << 8);
}

void Z80::opcode_fd_26()    // LD IYH, n
{
    IY = (IY & 0xFF) | ((unsigned)fetchByte() << 8);
}

void Z80::opcode_fd_29()    // ADD IY, IY
{
    F &= (Zero | Sign | Parity);
    if( IY & 0x800 ) F |= Halfcarry;
    IY += IY;
    if( IY & 0x10000 ) F |= Carry;
}

void Z80::opcode_fd_2a()    // LD IY, (nn)
{
    IY = readWord( fetchWord() );
}

void Z80::opcode_fd_2b()    // DEC IY
{
    IY--;
}

void Z80::opcode_fd_2c()    // INC IYL
{
    IY = (IY & 0xFF00) | incByte( IY & 0xFF );
}

void Z80::opcode_fd_2d()    // DEC IYL
{
    IY = (IY & 0xFF00) | decByte( IY & 0xFF );
}

void Z80::opcode_fd_2e()    // LD IYL, n
{
    IY = (IY & 0xFF00) | fetchByte();
}

void Z80::opcode_fd_34()    // INC (IY + d)
{
    unsigned    addr = addDispl( IY, fetchByte() );

    env_.writeByte( addr, incByte( env_.readByte( addr ) ) );
}

void Z80::opcode_fd_35()    // DEC (IY + d)
{
    unsigned    addr = addDispl( IY, fetchByte() );

    env_.writeByte( addr, decByte( env_.readByte( addr ) ) );
}

void Z80::opcode_fd_36()    // LD (IY + d), n
{
    unsigned    addr = addDispl( IY, fetchByte() );

    env_.writeByte( addr, fetchByte() );
}

void Z80::opcode_fd_39()    // ADD IY, SP
{
    F &= (Zero | Sign | Parity);
    if( ((IY & 0xFFF)+(SP & 0xFFF)) > 0xFFF ) F |= Halfcarry;
    IY += SP;
    if( IY & 0x10000 ) F |= Carry;
}

void Z80::opcode_fd_44()    // LD B, IYH
{
    B = IY >> 8;
}

void Z80::opcode_fd_45()    // LD B, IYL
{
    B = IY & 0xFF;
}

void Z80::opcode_fd_46()    // LD B, (IY + d)
{
    B = env_.readByte( addDispl(IY,fetchByte()) );
}

void Z80::opcode_fd_4c()    // LD C, IYH
{
    C = IY >> 8;
}

void Z80::opcode_fd_4d()    // LD C, IYL
{
    C = IY & 0xFF;
}

void Z80::opcode_fd_4e()    // LD C, (IY + d)
{
    C = env_.readByte( addDispl(IY,fetchByte()) );
}

void Z80::opcode_fd_54()    // LD D, IYH
{
    D = IY >> 8;
}

void Z80::opcode_fd_55()    // LD D, IYL
{
    D = IY & 0xFF;
}

void Z80::opcode_fd_56()    // LD D, (IY + d)
{
    D = env_.readByte( addDispl(IY,fetchByte()) );
}

void Z80::opcode_fd_5c()    // LD E, IYH
{
    E = IY >> 8;
}

void Z80::opcode_fd_5d()    // LD E, IYL
{
    E = IY & 0xFF;
}

void Z80::opcode_fd_5e()    // LD E, (IY + d)
{
    E = env_.readByte( addDispl(IY,fetchByte()) );
}

void Z80::opcode_fd_60()    // LD IYH, B
{
    IY = (IY & 0xFF) | ((unsigned)B << 8);
}

void Z80::opcode_fd_61()    // LD IYH, C
{
    IY = (IY & 0xFF) | ((unsigned)C << 8);
}

void Z80::opcode_fd_62()    // LD IYH, D
{
    IY = (IY & 0xFF) | ((unsigned)D << 8);
}

void Z80::opcode_fd_63()    // LD IYH, E
{
    IY = (IY & 0xFF) | ((unsigned)E << 8);
}

void Z80::opcode_fd_64()    // LD IYH, IYH
{
}

void Z80::opcode_fd_65()    // LD IYH, IYL
{
    IY = (IY & 0xFF) | ((IY << 8) & 0xFF00);
}

void Z80::opcode_fd_66()    // LD H, (IY + d)
{
    H = env_.readByte( addDispl(IY,fetchByte()) );
}

void Z80::opcode_fd_67()    // LD IYH, A
{
    IY = (IY & 0xFF) | ((unsigned)A << 8);
}

void Z80::opcode_fd_68()    // LD IYL, B
{
    IY = (IY & 0xFF00) | B;
}

void Z80::opcode_fd_69()    // LD IYL, C
{
    IY = (IY & 0xFF00) | C;
}

void Z80::opcode_fd_6a()    // LD IYL, D
{
    IY = (IY & 0xFF00) | D;
}

void Z80::opcode_fd_6b()    // LD IYL, E
{
    IY = (IY & 0xFF00) | E;
}

void Z80::opcode_fd_6c()    // LD IYL, IYH
{
    IY = (IY & 0xFF00) | ((IY >> 8) & 0xFF);
}

void Z80::opcode_fd_6d()    // LD IYL, IYL
{
}

void Z80::opcode_fd_6e()    // LD L, (IY + d)
{
    L = env_.readByte( addDispl(IY,fetchByte()) );
}

void Z80::opcode_fd_6f()    // LD IYL, A
{
    IY = (IY & 0xFF00) | A;
}

void Z80::opcode_fd_70()    // LD (IY + d), B
{
    env_.writeByte( addDispl(IY,fetchByte()), B );
}

void Z80::opcode_fd_71()    // LD (IY + d), C
{
    env_.writeByte( addDispl(IY,fetchByte()), C );
}

void Z80::opcode_fd_72()    // LD (IY + d), D
{
    env_.writeByte( addDispl(IY,fetchByte()), D );
}

void Z80::opcode_fd_73()    // LD (IY + d), E
{
    env_.writeByte( addDispl(IY,fetchByte()), E );
}

void Z80::opcode_fd_74()    // LD (IY + d), H
{
    env_.writeByte( addDispl(IY,fetchByte()), H );
}

void Z80::opcode_fd_75()    // LD (IY + d), L
{
    env_.writeByte( addDispl(IY,fetchByte()), L );
}

void Z80::opcode_fd_77()    // LD (IY + d), A
{
    env_.writeByte( addDispl(IY,fetchByte()), A );
}

void Z80::opcode_fd_7c()    // LD A, IYH
{
    A = IY >> 8;
}

void Z80::opcode_fd_7d()    // LD A, IYL
{
    A = IY & 0xFF;
}

void Z80::opcode_fd_7e()    // LD A, (IY + d)
{
    A = env_.readByte( addDispl(IY,fetchByte()) );
}

void Z80::opcode_fd_84()    // ADD A, IYH
{
    addByte( IY >> 8, 0 );
}

void Z80::opcode_fd_85()    // ADD A, IYL
{
    addByte( IY & 0xFF, 0 );
}

void Z80::opcode_fd_86()    // ADD A, (IY + d)
{
    addByte( env_.readByte( addDispl(IY,fetchByte()) ), 0 );
}

void Z80::opcode_fd_8c()    // ADC A, IYH
{
    addByte( IY >> 8, F & Carry );
}

void Z80::opcode_fd_8d()    // ADC A, IYL
{
    addByte( IY & 0xFF, F & Carry );
}

void Z80::opcode_fd_8e()    // ADC A, (IY + d)
{
    addByte( env_.readByte( addDispl(IY,fetchByte()) ), F & Carry );
}

void Z80::opcode_fd_94()    // SUB IYH
{
    A = subByte( IY >> 8, 0 );
}

void Z80::opcode_fd_95()    // SUB IYL
{
    A = subByte( IY & 0xFF, 0 );
}

void Z80::opcode_fd_96()    // SUB (IY + d)
{
    A = subByte( env_.readByte( addDispl(IY,fetchByte()) ), 0 );
}

void Z80::opcode_fd_9c()    // SBC A, IYH
{
    A = subByte( IY >> 8, F & Carry );
}

void Z80::opcode_fd_9d()    // SBC A, IYL
{
    A = subByte( IY & 0xFF, F & Carry );
}

void Z80::opcode_fd_9e()    // SBC A, (IY + d)
{
    A = subByte( env_.readByte( addDispl(IY,fetchByte()) ), F & Carry );
}

void Z80::opcode_fd_a4()    // AND IYH
{
    A &= IY >> 8;
    setFlags35PSZ000();
    F |= Halfcarry;
}

void Z80::opcode_fd_a5()    // AND IYL
{
    A &= IY & 0xFF;
    setFlags35PSZ000();
    F |= Halfcarry;
}

void Z80::opcode_fd_a6()    // AND (IY + d)
{
    A &= env_.readByte( addDispl(IY,fetchByte()) );
    setFlags35PSZ000();
    F |= Halfcarry;
}

void Z80::opcode_fd_ac()    // XOR IYH
{
    A ^= IY >> 8;
    setFlags35PSZ000();
}

void Z80::opcode_fd_ad()    // XOR IYL
{
    A ^= IY & 0xFF;
    setFlags35PSZ000();
}

void Z80::opcode_fd_ae()    // XOR (IY + d)
{
    A ^= env_.readByte( addDispl(IY,fetchByte()) );
    setFlags35PSZ000();
}

void Z80::opcode_fd_b4()    // OR IYH
{
    A |= IY >> 8;
    setFlags35PSZ000();
}

void Z80::opcode_fd_b5()    // OR IYL
{
    A |= IY & 0xFF;
    setFlags35PSZ000();
}

void Z80::opcode_fd_b6()    // OR (IY + d)
{
    A |= env_.readByte( addDispl(IY,fetchByte()) );
    setFlags35PSZ000();
}

void Z80::opcode_fd_bc()    // CP IYH
{
    cmpByte( IY >> 8 );
}

void Z80::opcode_fd_bd()    // CP IYL
{
    cmpByte( IY & 0xFF );
}

void Z80::opcode_fd_be()    // CP (IY + d)
{
    cmpByte( env_.readByte( addDispl(IY,fetchByte()) ) );
}

void Z80::opcode_fd_cb()    // 
{
    do_opcode_xycb( IY );
}

void Z80::opcode_fd_e1()    // POP IY
{
    IY = readWord( SP );
    SP += 2;
}

void Z80::opcode_fd_e3()    // EX (SP), IY
{
    unsigned    iy = IY;

    IY = readWord( SP );
    writeWord( SP, iy );
}

void Z80::opcode_fd_e5()    // PUSH IY
{
    SP -= 2;
    writeWord( SP, IY );
}

void Z80::opcode_fd_e9()    // JP (IY)
{
    PC = IY;
}

void Z80::opcode_fd_f9()    // LD SP, IY
{
    SP = IY;
}
