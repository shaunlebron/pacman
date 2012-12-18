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

Z80::OpcodeInfo Z80::OpInfoDD_[256] = {
    { 0, 0 }, // 0x00
    { 0, 0 }, // 0x01
    { 0, 0 }, // 0x02
    { 0, 0 }, // 0x03
    { 0, 0 }, // 0x04
    { 0, 0 }, // 0x05
    { 0, 0 }, // 0x06
    { 0, 0 }, // 0x07
    { 0, 0 }, // 0x08
    { &Z80::opcode_dd_09, 15 }, // ADD IX, BC
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
    { &Z80::opcode_dd_19, 15 }, // ADD IX, DE
    { 0, 0 }, // 0x1A
    { 0, 0 }, // 0x1B
    { 0, 0 }, // 0x1C
    { 0, 0 }, // 0x1D
    { 0, 0 }, // 0x1E
    { 0, 0 }, // 0x1F
    { 0, 0 }, // 0x20
    { &Z80::opcode_dd_21, 14 }, // LD IX, nn
    { &Z80::opcode_dd_22, 20 }, // LD (nn), IX
    { &Z80::opcode_dd_23, 10 }, // INC IX
    { &Z80::opcode_dd_24,  9 }, // INC IXH
    { &Z80::opcode_dd_25,  9 }, // DEC IXH
    { &Z80::opcode_dd_26,  9 }, // LD IXH, n
    { 0, 0 }, // 0x27
    { 0, 0 }, // 0x28
    { &Z80::opcode_dd_29, 15 }, // ADD IX, IX
    { &Z80::opcode_dd_2a, 20 }, // LD IX, (nn)
    { &Z80::opcode_dd_2b, 10 }, // DEC IX
    { &Z80::opcode_dd_2c,  9 }, // INC IXL
    { &Z80::opcode_dd_2d,  9 }, // DEC IXL
    { &Z80::opcode_dd_2e,  9 }, // LD IXL, n
    { 0, 0 }, // 0x2F
    { 0, 0 }, // 0x30
    { 0, 0 }, // 0x31
    { 0, 0 }, // 0x32
    { 0, 0 }, // 0x33
    { &Z80::opcode_dd_34, 23 }, // INC (IX + d)
    { &Z80::opcode_dd_35, 23 }, // DEC (IX + d)
    { &Z80::opcode_dd_36, 19 }, // LD (IX + d), n
    { 0, 0 }, // 0x37
    { 0, 0 }, // 0x38
    { &Z80::opcode_dd_39, 15 }, // ADD IX, SP
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
    { &Z80::opcode_dd_44,  9 }, // LD B, IXH
    { &Z80::opcode_dd_45,  9 }, // LD B, IXL
    { &Z80::opcode_dd_46, 19 }, // LD B, (IX + d)
    { 0, 0 }, // 0x47
    { 0, 0 }, // 0x48
    { 0, 0 }, // 0x49
    { 0, 0 }, // 0x4A
    { 0, 0 }, // 0x4B
    { &Z80::opcode_dd_4c,  9 }, // LD C, IXH
    { &Z80::opcode_dd_4d,  9 }, // LD C, IXL
    { &Z80::opcode_dd_4e, 19 }, // LD C, (IX + d)
    { 0, 0 }, // 0x4F
    { 0, 0 }, // 0x50
    { 0, 0 }, // 0x51
    { 0, 0 }, // 0x52
    { 0, 0 }, // 0x53
    { &Z80::opcode_dd_54,  9 }, // LD D, IXH
    { &Z80::opcode_dd_55,  9 }, // LD D, IXL
    { &Z80::opcode_dd_56, 19 }, // LD D, (IX + d)
    { 0, 0 }, // 0x57
    { 0, 0 }, // 0x58
    { 0, 0 }, // 0x59
    { 0, 0 }, // 0x5A
    { 0, 0 }, // 0x5B
    { &Z80::opcode_dd_5c,  9 }, // LD E, IXH
    { &Z80::opcode_dd_5d,  9 }, // LD E, IXL
    { &Z80::opcode_dd_5e, 19 }, // LD E, (IX + d)
    { 0, 0 }, // 0x5F
    { &Z80::opcode_dd_60,  9 }, // LD IXH, B
    { &Z80::opcode_dd_61,  9 }, // LD IXH, C
    { &Z80::opcode_dd_62,  9 }, // LD IXH, D
    { &Z80::opcode_dd_63,  9 }, // LD IXH, E
    { &Z80::opcode_dd_64,  9 }, // LD IXH, IXH
    { &Z80::opcode_dd_65,  9 }, // LD IXH, IXL
    { &Z80::opcode_dd_66,  9 }, // LD H, (IX + d)
    { &Z80::opcode_dd_67,  9 }, // LD IXH, A
    { &Z80::opcode_dd_68,  9 }, // LD IXL, B
    { &Z80::opcode_dd_69,  9 }, // LD IXL, C
    { &Z80::opcode_dd_6a,  9 }, // LD IXL, D
    { &Z80::opcode_dd_6b,  9 }, // LD IXL, E
    { &Z80::opcode_dd_6c,  9 }, // LD IXL, IXH
    { &Z80::opcode_dd_6d,  9 }, // LD IXL, IXL
    { &Z80::opcode_dd_6e,  9 }, // LD L, (IX + d)
    { &Z80::opcode_dd_6f,  9 }, // LD IXL, A
    { &Z80::opcode_dd_70, 19 }, // LD (IX + d), B
    { &Z80::opcode_dd_71, 19 }, // LD (IX + d), C
    { &Z80::opcode_dd_72, 19 }, // LD (IX + d), D
    { &Z80::opcode_dd_73, 19 }, // LD (IX + d), E
    { &Z80::opcode_dd_74, 19 }, // LD (IX + d), H
    { &Z80::opcode_dd_75, 19 }, // LD (IX + d), L
    { 0,19 }, // 0x76
    { &Z80::opcode_dd_77, 19 }, // LD (IX + d), A
    { 0, 0 }, // 0x78
    { 0, 0 }, // 0x79
    { 0, 0 }, // 0x7A
    { 0, 0 }, // 0x7B
    { &Z80::opcode_dd_7c,  9 }, // LD A, IXH
    { &Z80::opcode_dd_7d,  9 }, // LD A, IXL
    { &Z80::opcode_dd_7e, 19 }, // LD A, (IX + d)
    { 0, 0 }, // 0x7F
    { 0, 0 }, // 0x80
    { 0, 0 }, // 0x81
    { 0, 0 }, // 0x82
    { 0, 0 }, // 0x83
    { &Z80::opcode_dd_84,  9 }, // ADD A, IXH
    { &Z80::opcode_dd_85,  9 }, // ADD A, IXL
    { &Z80::opcode_dd_86, 19 }, // ADD A, (IX + d)
    { 0, 0 }, // 0x87
    { 0, 0 }, // 0x88
    { 0, 0 }, // 0x89
    { 0, 0 }, // 0x8A
    { 0, 0 }, // 0x8B
    { &Z80::opcode_dd_8c,  9 }, // ADC A, IXH
    { &Z80::opcode_dd_8d,  9 }, // ADC A, IXL
    { &Z80::opcode_dd_8e, 19 }, // ADC A, (IX + d)
    { 0, 0 }, // 0x8F
    { 0, 0 }, // 0x90
    { 0, 0 }, // 0x91
    { 0, 0 }, // 0x92
    { 0, 0 }, // 0x93
    { &Z80::opcode_dd_94,  9 }, // SUB IXH
    { &Z80::opcode_dd_95,  9 }, // SUB IXL
    { &Z80::opcode_dd_96, 19 }, // SUB (IX + d)
    { 0, 0 }, // 0x97
    { 0, 0 }, // 0x98
    { 0, 0 }, // 0x99
    { 0, 0 }, // 0x9A
    { 0, 0 }, // 0x9B
    { &Z80::opcode_dd_9c,  9 }, // SBC A, IXH
    { &Z80::opcode_dd_9d,  9 }, // SBC A, IXL
    { &Z80::opcode_dd_9e, 19 }, // SBC A, (IX + d)
    { 0, 0 }, // 0x9F
    { 0, 0 }, // 0xA0
    { 0, 0 }, // 0xA1
    { 0, 0 }, // 0xA2
    { 0, 0 }, // 0xA3
    { &Z80::opcode_dd_a4,  9 }, // AND IXH
    { &Z80::opcode_dd_a5,  9 }, // AND IXL
    { &Z80::opcode_dd_a6, 19 }, // AND (IX + d)
    { 0, 0 }, // 0xA7
    { 0, 0 }, // 0xA8
    { 0, 0 }, // 0xA9
    { 0, 0 }, // 0xAA
    { 0, 0 }, // 0xAB
    { &Z80::opcode_dd_ac,  9 }, // XOR IXH
    { &Z80::opcode_dd_ad,  9 }, // XOR IXL
    { &Z80::opcode_dd_ae, 19 }, // XOR (IX + d)
    { 0, 0 }, // 0xAF
    { 0, 0 }, // 0xB0
    { 0, 0 }, // 0xB1
    { 0, 0 }, // 0xB2
    { 0, 0 }, // 0xB3
    { &Z80::opcode_dd_b4,  9 }, // OR IXH
    { &Z80::opcode_dd_b5,  9 }, // OR IXL
    { &Z80::opcode_dd_b6, 19 }, // OR (IX + d)
    { 0, 0 }, // 0xB7
    { 0, 0 }, // 0xB8
    { 0, 0 }, // 0xB9
    { 0, 0 }, // 0xBA
    { 0, 0 }, // 0xBB
    { &Z80::opcode_dd_bc,  9 }, // CP IXH
    { &Z80::opcode_dd_bd,  9 }, // CP IXL
    { &Z80::opcode_dd_be, 19 }, // CP (IX + d)
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
    { &Z80::opcode_dd_cb,  0 }, // 
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
    { &Z80::opcode_dd_e1, 14 }, // POP IX
    { 0, 0 }, // 0xE2
    { &Z80::opcode_dd_e3, 23 }, // EX (SP), IX
    { 0, 0 }, // 0xE4
    { &Z80::opcode_dd_e5, 15 }, // PUSH IX
    { 0, 0 }, // 0xE6
    { 0, 0 }, // 0xE7
    { 0, 0 }, // 0xE8
    { &Z80::opcode_dd_e9,  8 }, // JP (IX)
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
    { &Z80::opcode_dd_f9, 10 }, // LD SP, IX
    { 0, 0 }, // 0xFA
    { 0, 0 }, // 0xFB
    { 0, 0 }, // 0xFC
    { 0, 0 }, // 0xFD
    { 0, 0 }, // 0xFE
    { 0, 0 }  // 0xFF
};

void Z80::opcode_dd_09()    // ADD IX, BC
{
    unsigned rr = BC();

    F &= (Zero | Sign | Parity);
    if( ((IX & 0xFFF)+(rr & 0xFFF)) > 0xFFF ) F |= Halfcarry;
    IX += rr;
    if( IX & 0x10000 ) F |= Carry;
}

void Z80::opcode_dd_19()    // ADD IX, DE
{
    unsigned rr = DE();

    F &= (Zero | Sign | Parity);
    if( ((IX & 0xFFF)+(rr & 0xFFF)) > 0xFFF ) F |= Halfcarry;
    IX += rr;
    if( IX & 0x10000 ) F |= Carry;
}

void Z80::opcode_dd_21()    // LD IX, nn
{
    IX = fetchWord();
}

void Z80::opcode_dd_22()    // LD (nn), IX
{
    writeWord( fetchWord(), IX );
}

void Z80::opcode_dd_23()    // INC IX
{
    IX++;
}

void Z80::opcode_dd_24()    // INC IXH
{
    IX = (IX & 0xFF) | ((unsigned)incByte( IX >> 8 ) << 8);
}

void Z80::opcode_dd_25()    // DEC IXH
{
    IX = (IX & 0xFF) | ((unsigned)decByte( IX >> 8 ) << 8);
}

void Z80::opcode_dd_26()    // LD IXH, n
{
    IX = (IX & 0xFF) | ((unsigned)fetchByte() << 8);
}

void Z80::opcode_dd_29()    // ADD IX, IX
{
    F &= (Zero | Sign | Parity);
    if( IX & 0x800 ) F |= Halfcarry;
    IX += IX;
    if( IX & 0x10000 ) F |= Carry;
}

void Z80::opcode_dd_2a()    // LD IX, (nn)
{
    IX = readWord( fetchWord() );
}

void Z80::opcode_dd_2b()    // DEC IX
{
    IX--;
}

void Z80::opcode_dd_2c()    // INC IXL
{
    IX = (IX & 0xFF00) | incByte( IX & 0xFF );
}

void Z80::opcode_dd_2d()    // DEC IXL
{
    IX = (IX & 0xFF00) | decByte( IX & 0xFF );
}

void Z80::opcode_dd_2e()    // LD IXL, n
{
    IX = (IX & 0xFF00) | fetchByte();
}

void Z80::opcode_dd_34()    // INC (IX + d)
{
    unsigned    addr = addDispl( IX, fetchByte() );

    env_.writeByte( addr, incByte( env_.readByte( addr ) ) );
}

void Z80::opcode_dd_35()    // DEC (IX + d)
{
    unsigned    addr = addDispl( IX, fetchByte() );

    env_.writeByte( addr, decByte( env_.readByte( addr ) ) );
}

void Z80::opcode_dd_36()    // LD (IX + d), n
{
    unsigned    addr = addDispl( IX, fetchByte() );

    env_.writeByte( addr, fetchByte() );
}

void Z80::opcode_dd_39()    // ADD IX, SP
{
    F &= (Zero | Sign | Parity);
    if( ((IX & 0xFFF)+(SP & 0xFFF)) > 0xFFF ) F |= Halfcarry;
    IX += SP;
    if( IX & 0x10000 ) F |= Carry;
}

void Z80::opcode_dd_44()    // LD B, IXH
{
    B = IX >> 8;
}

void Z80::opcode_dd_45()    // LD B, IXL
{
    B = IX & 0xFF;
}

void Z80::opcode_dd_46()    // LD B, (IX + d)
{
    B = env_.readByte( addDispl(IX,fetchByte()) );
}

void Z80::opcode_dd_4c()    // LD C, IXH
{
    C = IX >> 8;
}

void Z80::opcode_dd_4d()    // LD C, IXL
{
    C = IX & 0xFF;
}

void Z80::opcode_dd_4e()    // LD C, (IX + d)
{
    C = env_.readByte( addDispl(IX,fetchByte()) );
}

void Z80::opcode_dd_54()    // LD D, IXH
{
    D = IX >> 8;
}

void Z80::opcode_dd_55()    // LD D, IXL
{
    D = IX & 0xFF;
}

void Z80::opcode_dd_56()    // LD D, (IX + d)
{
    D = env_.readByte( addDispl(IX,fetchByte()) );
}

void Z80::opcode_dd_5c()    // LD E, IXH
{
    E = IX >> 8;
}

void Z80::opcode_dd_5d()    // LD E, IXL
{
    E = IX & 0xFF;
}

void Z80::opcode_dd_5e()    // LD E, (IX + d)
{
    E = env_.readByte( addDispl(IX,fetchByte()) );
}

void Z80::opcode_dd_60()    // LD IXH, B
{
    IX = (IX & 0xFF) | ((unsigned)B << 8);
}

void Z80::opcode_dd_61()    // LD IXH, C
{
    IX = (IX & 0xFF) | ((unsigned)C << 8);
}

void Z80::opcode_dd_62()    // LD IXH, D
{
    IX = (IX & 0xFF) | ((unsigned)D << 8);
}

void Z80::opcode_dd_63()    // LD IXH, E
{
    IX = (IX & 0xFF) | ((unsigned)E << 8);
}

void Z80::opcode_dd_64()    // LD IXH, IXH
{
}

void Z80::opcode_dd_65()    // LD IXH, IXL
{
    IX = (IX & 0xFF) | ((IX << 8) & 0xFF00);
}

void Z80::opcode_dd_66()    // LD H, (IX + d)
{
    H = env_.readByte( addDispl(IX,fetchByte()) );
}

void Z80::opcode_dd_67()    // LD IXH, A
{
    IX = (IX & 0xFF) | ((unsigned)A << 8);
}

void Z80::opcode_dd_68()    // LD IXL, B
{
    IX = (IX & 0xFF00) | B;
}

void Z80::opcode_dd_69()    // LD IXL, C
{
    IX = (IX & 0xFF00) | C;
}

void Z80::opcode_dd_6a()    // LD IXL, D
{
    IX = (IX & 0xFF00) | D;
}

void Z80::opcode_dd_6b()    // LD IXL, E
{
    IX = (IX & 0xFF00) | E;
}

void Z80::opcode_dd_6c()    // LD IXL, IXH
{
    IX = (IX & 0xFF00) | ((IX >> 8) & 0xFF);
}

void Z80::opcode_dd_6d()    // LD IXL, IXL
{
}

void Z80::opcode_dd_6e()    // LD L, (IX + d)
{
    L = env_.readByte( addDispl(IX,fetchByte()) );
}

void Z80::opcode_dd_6f()    // LD IXL, A
{
    IX = (IX & 0xFF00) | A;
}

void Z80::opcode_dd_70()    // LD (IX + d), B
{
    env_.writeByte( addDispl(IX,fetchByte()), B );
}

void Z80::opcode_dd_71()    // LD (IX + d), C
{
    env_.writeByte( addDispl(IX,fetchByte()), C );
}

void Z80::opcode_dd_72()    // LD (IX + d), D
{
    env_.writeByte( addDispl(IX,fetchByte()), D );
}

void Z80::opcode_dd_73()    // LD (IX + d), E
{
    env_.writeByte( addDispl(IX,fetchByte()), E );
}

void Z80::opcode_dd_74()    // LD (IX + d), H
{
    env_.writeByte( addDispl(IX,fetchByte()), H );
}

void Z80::opcode_dd_75()    // LD (IX + d), L
{
    env_.writeByte( addDispl(IX,fetchByte()), L );
}

void Z80::opcode_dd_77()    // LD (IX + d), A
{
    env_.writeByte( addDispl(IX,fetchByte()), A );
}

void Z80::opcode_dd_7c()    // LD A, IXH
{
    A = IX >> 8;
}

void Z80::opcode_dd_7d()    // LD A, IXL
{
    A = IX & 0xFF;
}

void Z80::opcode_dd_7e()    // LD A, (IX + d)
{
    A = env_.readByte( addDispl(IX,fetchByte()) );
}

void Z80::opcode_dd_84()    // ADD A, IXH
{
    addByte( IX >> 8, 0 );
}

void Z80::opcode_dd_85()    // ADD A, IXL
{
    addByte( IX & 0xFF, 0 );
}

void Z80::opcode_dd_86()    // ADD A, (IX + d)
{
    addByte( env_.readByte( addDispl(IX,fetchByte()) ), 0 );
}

void Z80::opcode_dd_8c()    // ADC A, IXH
{
    addByte( IX >> 8, F & Carry );
}

void Z80::opcode_dd_8d()    // ADC A, IXL
{
    addByte( IX & 0xFF, F & Carry );
}

void Z80::opcode_dd_8e()    // ADC A, (IX + d)
{
    addByte( env_.readByte( addDispl(IX,fetchByte()) ), F & Carry );
}

void Z80::opcode_dd_94()    // SUB IXH
{
    A = subByte( IX >> 8, 0 );
}

void Z80::opcode_dd_95()    // SUB IXL
{
    A = subByte( IX & 0xFF, 0 );
}

void Z80::opcode_dd_96()    // SUB (IX + d)
{
    A = subByte( env_.readByte( addDispl(IX,fetchByte()) ), 0 );
}

void Z80::opcode_dd_9c()    // SBC A, IXH
{
    A = subByte( IX >> 8, F & Carry );
}

void Z80::opcode_dd_9d()    // SBC A, IXL
{
    A = subByte( IX & 0xFF, F & Carry );
}

void Z80::opcode_dd_9e()    // SBC A, (IX + d)
{
    A = subByte( env_.readByte( addDispl(IX,fetchByte()) ), F & Carry );
}

void Z80::opcode_dd_a4()    // AND IXH
{
    A &= IX >> 8;
    setFlags35PSZ000();
    F |= Halfcarry;
}

void Z80::opcode_dd_a5()    // AND IXL
{
    A &= IX & 0xFF;
    setFlags35PSZ000();
    F |= Halfcarry;
}

void Z80::opcode_dd_a6()    // AND (IX + d)
{
    A &= env_.readByte( addDispl(IX,fetchByte()) );
    setFlags35PSZ000();
    F |= Halfcarry;
}

void Z80::opcode_dd_ac()    // XOR IXH
{
    A ^= IX >> 8;
    setFlags35PSZ000();
}

void Z80::opcode_dd_ad()    // XOR IXL
{
    A ^= IX & 0xFF;
    setFlags35PSZ000();
}

void Z80::opcode_dd_ae()    // XOR (IX + d)
{
    A ^= env_.readByte( addDispl(IX,fetchByte()) );
    setFlags35PSZ000();
}

void Z80::opcode_dd_b4()    // OR IXH
{
    A |= IX >> 8;
    setFlags35PSZ000();
}

void Z80::opcode_dd_b5()    // OR IXL
{
    A |= IX & 0xFF;
    setFlags35PSZ000();
}

void Z80::opcode_dd_b6()    // OR (IX + d)
{
    A |= env_.readByte( addDispl(IX,fetchByte()) );
    setFlags35PSZ000();
}

void Z80::opcode_dd_bc()    // CP IXH
{
    cmpByte( IX >> 8 );
}

void Z80::opcode_dd_bd()    // CP IXL
{
    cmpByte( IX & 0xFF );
}

void Z80::opcode_dd_be()    // CP (IX + d)
{
    cmpByte( env_.readByte( addDispl(IX,fetchByte()) ) );
}

void Z80::opcode_dd_cb()    // 
{
    do_opcode_xycb( IX );
}

void Z80::opcode_dd_e1()    // POP IX
{
    IX = readWord( SP );
    SP += 2;
}

void Z80::opcode_dd_e3()    // EX (SP), IX
{
    unsigned    ix = IX;

    IX = readWord( SP );
    writeWord( SP, ix );
}

void Z80::opcode_dd_e5()    // PUSH IX
{
    SP -= 2;
    writeWord( SP, IX );
}

void Z80::opcode_dd_e9()    // JP (IX)
{
    PC = IX;
}

void Z80::opcode_dd_f9()    // LD SP, IX
{
    SP = IX;
}
