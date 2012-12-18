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

Z80::OpcodeInfo Z80::OpInfoED_[256] = {
    { 0, 0 }, // 0x00
    { 0, 0 }, // 0x01
    { 0, 0 }, // 0x02
    { 0, 0 }, // 0x03
    { 0, 0 }, // 0x04
    { 0, 0 }, // 0x05
    { 0, 0 }, // 0x06
    { 0, 0 }, // 0x07
    { 0, 0 }, // 0x08
    { 0, 0 }, // 0x09
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
    { 0, 0 }, // 0x19
    { 0, 0 }, // 0x1A
    { 0, 0 }, // 0x1B
    { 0, 0 }, // 0x1C
    { 0, 0 }, // 0x1D
    { 0, 0 }, // 0x1E
    { 0, 0 }, // 0x1F
    { 0, 0 }, // 0x20
    { 0, 0 }, // 0x21
    { 0, 0 }, // 0x22
    { 0, 0 }, // 0x23
    { 0, 0 }, // 0x24
    { 0, 0 }, // 0x25
    { 0, 0 }, // 0x26
    { 0, 0 }, // 0x27
    { 0, 0 }, // 0x28
    { 0, 0 }, // 0x29
    { 0, 0 }, // 0x2A
    { 0, 0 }, // 0x2B
    { 0, 0 }, // 0x2C
    { 0, 0 }, // 0x2D
    { 0, 0 }, // 0x2E
    { 0, 0 }, // 0x2F
    { 0, 0 }, // 0x30
    { 0, 0 }, // 0x31
    { 0, 0 }, // 0x32
    { 0, 0 }, // 0x33
    { 0, 0 }, // 0x34
    { 0, 0 }, // 0x35
    { 0, 0 }, // 0x36
    { 0, 0 }, // 0x37
    { 0, 0 }, // 0x38
    { 0, 0 }, // 0x39
    { 0, 0 }, // 0x3A
    { 0, 0 }, // 0x3B
    { 0, 0 }, // 0x3C
    { 0, 0 }, // 0x3D
    { 0, 0 }, // 0x3E
    { 0, 0 }, // 0x3F
    { &Z80::opcode_ed_40, 12 }, // IN B, (C)
    { &Z80::opcode_ed_41, 12 }, // OUT (C), B
    { &Z80::opcode_ed_42, 15 }, // SBC HL, BC
    { &Z80::opcode_ed_43, 20 }, // LD (nn), BC
    { &Z80::opcode_ed_44,  8 }, // NEG
    { &Z80::opcode_ed_45, 14 }, // RETN
    { &Z80::opcode_ed_46,  8 }, // IM 0
    { &Z80::opcode_ed_47,  9 }, // LD I, A
    { &Z80::opcode_ed_48, 12 }, // IN C, (C)
    { &Z80::opcode_ed_49, 12 }, // OUT (C), C
    { &Z80::opcode_ed_4a, 15 }, // ADC HL, BC
    { &Z80::opcode_ed_4b, 20 }, // LD BC, (nn)
    { &Z80::opcode_ed_4c,  8 }, // NEG
    { &Z80::opcode_ed_4d, 14 }, // RETI
    { &Z80::opcode_ed_4e,  8 }, // IM 0/1
    { &Z80::opcode_ed_4f,  9 }, // LD R, A
    { &Z80::opcode_ed_50, 12 }, // IN D, (C)
    { &Z80::opcode_ed_51, 12 }, // OUT (C), D
    { &Z80::opcode_ed_52, 15 }, // SBC HL, DE
    { &Z80::opcode_ed_53, 20 }, // LD (nn), DE
    { &Z80::opcode_ed_54,  8 }, // NEG
    { &Z80::opcode_ed_55, 14 }, // RETN
    { &Z80::opcode_ed_56,  8 }, // IM 1
    { &Z80::opcode_ed_57,  9 }, // LD A, I
    { &Z80::opcode_ed_58, 12 }, // IN E, (C)
    { &Z80::opcode_ed_59, 12 }, // OUT (C), E
    { &Z80::opcode_ed_5a, 15 }, // ADC HL, DE
    { &Z80::opcode_ed_5b, 20 }, // LD DE, (nn)
    { &Z80::opcode_ed_5c,  8 }, // NEG
    { &Z80::opcode_ed_5d, 14 }, // RETN
    { &Z80::opcode_ed_5e,  8 }, // IM 2
    { &Z80::opcode_ed_5f,  9 }, // LD A, R
    { &Z80::opcode_ed_60, 12 }, // IN H, (C)
    { &Z80::opcode_ed_61, 12 }, // OUT (C), H
    { &Z80::opcode_ed_62, 15 }, // SBC HL, HL
    { &Z80::opcode_ed_63, 20 }, // LD (nn), HL
    { &Z80::opcode_ed_64,  8 }, // NEG
    { &Z80::opcode_ed_65, 14 }, // RETN
    { &Z80::opcode_ed_66,  8 }, // IM 0
    { &Z80::opcode_ed_67, 18 }, // RRD
    { &Z80::opcode_ed_68, 12 }, // IN L, (C)
    { &Z80::opcode_ed_69, 12 }, // OUT (C), L
    { &Z80::opcode_ed_6a, 15 }, // ADC HL, HL
    { &Z80::opcode_ed_6b, 20 }, // LD HL, (nn)
    { &Z80::opcode_ed_6c,  8 }, // NEG
    { &Z80::opcode_ed_6d, 14 }, // RETN
    { &Z80::opcode_ed_6e,  8 }, // IM 0/1
    { &Z80::opcode_ed_6f, 18 }, // RLD
    { &Z80::opcode_ed_70, 12 }, // IN (C) / IN F, (C)
    { &Z80::opcode_ed_71, 12 }, // OUT (C), 0
    { &Z80::opcode_ed_72, 15 }, // SBC HL, SP
    { &Z80::opcode_ed_73, 20 }, // LD (nn), SP
    { &Z80::opcode_ed_74,  8 }, // NEG
    { &Z80::opcode_ed_75, 14 }, // RETN
    { &Z80::opcode_ed_76,  8 }, // IM 1
    { 0, 0 }, // 0x77
    { &Z80::opcode_ed_78, 12 }, // IN A, (C)
    { &Z80::opcode_ed_79, 12 }, // OUT (C), A
    { &Z80::opcode_ed_7a, 15 }, // ADC HL, SP
    { &Z80::opcode_ed_7b, 20 }, // LD SP, (nn)
    { &Z80::opcode_ed_7c,  8 }, // NEG
    { &Z80::opcode_ed_7d, 14 }, // RETN
    { &Z80::opcode_ed_7e,  8 }, // IM 2
    { 0, 0 }, // 0x7F
    { 0, 0 }, // 0x80
    { 0, 0 }, // 0x81
    { 0, 0 }, // 0x82
    { 0, 0 }, // 0x83
    { 0, 0 }, // 0x84
    { 0, 0 }, // 0x85
    { 0, 0 }, // 0x86
    { 0, 0 }, // 0x87
    { 0, 0 }, // 0x88
    { 0, 0 }, // 0x89
    { 0, 0 }, // 0x8A
    { 0, 0 }, // 0x8B
    { 0, 0 }, // 0x8C
    { 0, 0 }, // 0x8D
    { 0, 0 }, // 0x8E
    { 0, 0 }, // 0x8F
    { 0, 0 }, // 0x90
    { 0, 0 }, // 0x91
    { 0, 0 }, // 0x92
    { 0, 0 }, // 0x93
    { 0, 0 }, // 0x94
    { 0, 0 }, // 0x95
    { 0, 0 }, // 0x96
    { 0, 0 }, // 0x97
    { 0, 0 }, // 0x98
    { 0, 0 }, // 0x99
    { 0, 0 }, // 0x9A
    { 0, 0 }, // 0x9B
    { 0, 0 }, // 0x9C
    { 0, 0 }, // 0x9D
    { 0, 0 }, // 0x9E
    { 0, 0 }, // 0x9F
    { &Z80::opcode_ed_a0, 16 }, // LDI
    { &Z80::opcode_ed_a1, 16 }, // CPI
    { &Z80::opcode_ed_a2, 16 }, // INI
    { &Z80::opcode_ed_a3, 16 }, // OUTI
    { 0, 0 }, // 0xA4
    { 0, 0 }, // 0xA5
    { 0, 0 }, // 0xA6
    { 0, 0 }, // 0xA7
    { &Z80::opcode_ed_a8, 16 }, // LDD
    { &Z80::opcode_ed_a9, 16 }, // CPD
    { &Z80::opcode_ed_aa, 16 }, // IND
    { &Z80::opcode_ed_ab, 16 }, // OUTD
    { 0, 0 }, // 0xAC
    { 0, 0 }, // 0xAD
    { 0, 0 }, // 0xAE
    { 0, 0 }, // 0xAF
    { &Z80::opcode_ed_b0,  0 }, // LDIR
    { &Z80::opcode_ed_b1,  0 }, // CPIR
    { &Z80::opcode_ed_b2,  0 }, // INIR
    { &Z80::opcode_ed_b3,  0 }, // OTIR
    { 0, 0 }, // 0xB4
    { 0, 0 }, // 0xB5
    { 0, 0 }, // 0xB6
    { 0, 0 }, // 0xB7
    { &Z80::opcode_ed_b8,  0 }, // LDDR
    { &Z80::opcode_ed_b9,  0 }, // CPDR
    { &Z80::opcode_ed_ba,  0 }, // INDR
    { &Z80::opcode_ed_bb,  0 }, // OTDR
    { 0, 0 }, // 0xBC
    { 0, 0 }, // 0xBD
    { 0, 0 }, // 0xBE
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
    { 0, 0 }, // 0xCB
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
    { 0, 0 }, // 0xE1
    { 0, 0 }, // 0xE2
    { 0, 0 }, // 0xE3
    { 0, 0 }, // 0xE4
    { 0, 0 }, // 0xE5
    { 0, 0 }, // 0xE6
    { 0, 0 }, // 0xE7
    { 0, 0 }, // 0xE8
    { 0, 0 }, // 0xE9
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
    { 0, 0 }, // 0xF9
    { 0, 0 }, // 0xFA
    { 0, 0 }, // 0xFB
    { 0, 0 }, // 0xFC
    { 0, 0 }, // 0xFD
    { 0, 0 }, // 0xFE
    { 0, 0 }  // 0xFF
};

void Z80::opcode_ed_40()    // IN B, (C)
{
    B = inpReg();
}

void Z80::opcode_ed_41()    // OUT (C), B
{
    env_.writePort( C, B );
}

void Z80::opcode_ed_42()    // SBC HL, BC
{
    unsigned char a;

    a = A;
    A = L; L = subByte( C, F & Carry );
    A = H; H = subByte( B, F & Carry );
    A = a;
    if( HL() == 0 ) F |= Zero; else F &= ~Zero;
}

void Z80::opcode_ed_43()    // LD (nn), BC
{
    unsigned addr = fetchWord();

    env_.writeByte( addr, C );
    env_.writeByte( addr+1, B );
}

void Z80::opcode_ed_44()    // NEG
{
    unsigned char   a = A;

    A = 0;
    A = subByte( a, 0 );
}

void Z80::opcode_ed_45()    // RETN
{
    retFromSub();
    iflags_ &= ~IFF1; 
    if( iflags_ & IFF2 ) iflags_ |= IFF1;
}

void Z80::opcode_ed_46()    // IM 0
{
    setInterruptMode( 0 );
}

void Z80::opcode_ed_47()    // LD I, A
{
    I = A;
}

void Z80::opcode_ed_48()    // IN C, (C)
{
    C = inpReg();
}

void Z80::opcode_ed_49()    // OUT (C), C
{
    env_.writePort( C, C );
}

void Z80::opcode_ed_4a()    // ADC HL, BC
{
    unsigned char a;

    a = A;
    A = L; addByte( C, F & Carry ); L = A;
    A = H; addByte( B, F & Carry ); H = A;
    A = a;
    if( HL() == 0 ) F |= Zero; else F &= ~Zero;
}

void Z80::opcode_ed_4b()    // LD BC, (nn)
{
    unsigned    addr = fetchWord();

    C = env_.readByte( addr );
    B = env_.readByte( addr+1 );
}

void Z80::opcode_ed_4c()    // NEG
{
    opcode_ed_44();
}

void Z80::opcode_ed_4d()    // RETI
{
    retFromSub();
    env_.onReturnFromInterrupt();
}

void Z80::opcode_ed_4e()    // IM 0/1
{
    setInterruptMode( 0 );
}

void Z80::opcode_ed_4f()    // LD R, A
{
    R = A;
}

void Z80::opcode_ed_50()    // IN D, (C)
{
    D = inpReg();
}

void Z80::opcode_ed_51()    // OUT (C), D
{
    env_.writePort( C, D );
}

void Z80::opcode_ed_52()    // SBC HL, DE
{
    unsigned char a;

    a = A;
    A = L; L = subByte( E, F & Carry );
    A = H; H = subByte( D, F & Carry );
    A = a;
    if( HL() == 0 ) F |= Zero; else F &= ~Zero;
}

void Z80::opcode_ed_53()    // LD (nn), DE
{
    unsigned addr = fetchWord();

    env_.writeByte( addr, E );
    env_.writeByte( addr+1, D );
}

void Z80::opcode_ed_54()    // NEG
{
    opcode_ed_44();
}

void Z80::opcode_ed_55()    // RETN
{
    opcode_ed_45();
}

void Z80::opcode_ed_56()    // IM 1
{
    setInterruptMode( 1 );
}

void Z80::opcode_ed_57()    // LD A, I
{
    A = I;
    setFlags35PSZ();
    F &= ~(Halfcarry | Parity | AddSub);
    if( iflags_ & IFF2 ) F |= Parity;
}

void Z80::opcode_ed_58()    // IN E, (C)
{
    E = inpReg();
}

void Z80::opcode_ed_59()    // OUT (C), E
{
    env_.writePort( C, E );
}

void Z80::opcode_ed_5a()    // ADC HL, DE
{
    unsigned char a;

    a = A;
    A = L; addByte( E, F & Carry ); L = A;
    A = H; addByte( D, F & Carry ); H = A;
    A = a;
    if( HL() == 0 ) F |= Zero; else F &= ~Zero;
}

void Z80::opcode_ed_5b()    // LD DE, (nn)
{
    unsigned    addr = fetchWord();

    E = env_.readByte( addr );
    D = env_.readByte( addr+1 );
}

void Z80::opcode_ed_5c()    // NEG
{
    opcode_ed_44();
}

void Z80::opcode_ed_5d()    // RETN
{
    opcode_ed_45();
}

void Z80::opcode_ed_5e()    // IM 2
{
    setInterruptMode( 2 );
}

void Z80::opcode_ed_5f()    // LD A, R
{
    A = R;
    setFlags35PSZ();
    F &= ~(Halfcarry | Parity | AddSub);
    if( iflags_ & IFF2 ) F |= Parity;
}

void Z80::opcode_ed_60()    // IN H, (C)
{
    H = inpReg();
}

void Z80::opcode_ed_61()    // OUT (C), H
{
    env_.writePort( C, H );
}

void Z80::opcode_ed_62()    // SBC HL, HL
{
    unsigned char a;

    a = A;
    A = L; L = subByte( L, F & Carry );
    A = H; H = subByte( H, F & Carry );
    A = a;
    if( HL() == 0 ) F |= Zero; else F &= ~Zero;
}

void Z80::opcode_ed_63()    // LD (nn), HL
{
    unsigned addr = fetchWord();

    env_.writeByte( addr, L );
    env_.writeByte( addr+1, H );
}

void Z80::opcode_ed_64()    // NEG
{
    opcode_ed_44();
}

void Z80::opcode_ed_65()    // RETN
{
    opcode_ed_45();
}

void Z80::opcode_ed_66()    // IM 0
{
    setInterruptMode( 0 );
}

void Z80::opcode_ed_67()    // RRD
{
    unsigned char   x = env_.readByte( HL() );

    env_.writeByte( HL(), (A << 4) | (x >> 4) );
    A = (A & 0xF0) | (x & 0x0F);
    setFlags35PSZ();
    F &= ~(Halfcarry | AddSub);
}

void Z80::opcode_ed_68()    // IN L, (C)
{
    L = inpReg();
}

void Z80::opcode_ed_69()    // OUT (C), L
{
    env_.writePort( C, L );
}

void Z80::opcode_ed_6a()    // ADC HL, HL
{
    unsigned char a;

    a = A;
    A = L; addByte( L, F & Carry ); L = A;
    A = H; addByte( H, F & Carry ); H = A;
    A = a;
    if( HL() == 0 ) F |= Zero; else F &= ~Zero;
}

void Z80::opcode_ed_6b()    // LD HL, (nn)
{
    unsigned    addr = fetchWord();

    L = env_.readByte( addr );
    H = env_.readByte( addr+1 );
}

void Z80::opcode_ed_6c()    // NEG
{
    opcode_ed_44();
}

void Z80::opcode_ed_6d()    // RETN
{
    opcode_ed_45();
}

void Z80::opcode_ed_6e()    // IM 0/1
{
    setInterruptMode( 0 );
}

void Z80::opcode_ed_6f()    // RLD
{
    unsigned char   x = env_.readByte( HL() );

    env_.writeByte( HL(), (x << 4) | (A & 0x0F) );
    A = (A & 0xF0) | (x >> 4);
    setFlags35PSZ();
    F &= ~(Halfcarry | AddSub);
}

void Z80::opcode_ed_70()    // IN (C) / IN F, (C)
{
    inpReg();
}

void Z80::opcode_ed_71()    // OUT (C), 0
{
    env_.writePort( C, 0 );
}

void Z80::opcode_ed_72()    // SBC HL, SP
{
    unsigned char a;

    a = A;
    A = L; L = subByte( SP & 0xFF, F & Carry );
    A = H; H = subByte( (SP >> 8) & 0xFF, F & Carry );
    A = a;
    if( HL() == 0 ) F |= Zero; else F &= ~Zero;
}

void Z80::opcode_ed_73()    // LD (nn), SP
{
    writeWord( fetchWord(), SP );
}

void Z80::opcode_ed_74()    // NEG
{
    opcode_ed_44();
}

void Z80::opcode_ed_75()    // RETN
{
    opcode_ed_45();
}

void Z80::opcode_ed_76()    // IM 1
{
    setInterruptMode( 1 );
}

void Z80::opcode_ed_78()    // IN A, (C)
{
    A = inpReg();
}

void Z80::opcode_ed_79()    // OUT (C), A
{
    env_.writePort( C, A );
}

void Z80::opcode_ed_7a()    // ADC HL, SP
{
    unsigned char a;

    a = A;
    A = L; addByte( SP & 0xFF, F & Carry ); L = A;
    A = H; addByte( (SP >> 8) & 0xFF, F & Carry ); H = A;
    A = a;
    if( HL() == 0 ) F |= Zero; else F &= ~Zero;
}

void Z80::opcode_ed_7b()    // LD SP, (nn)
{
    SP = readWord( fetchWord() );
}

void Z80::opcode_ed_7c()    // NEG
{
    opcode_ed_44();
}

void Z80::opcode_ed_7d()    // RETN
{
    opcode_ed_45();
}

void Z80::opcode_ed_7e()    // IM 2
{
    setInterruptMode( 2 );
}

void Z80::opcode_ed_a0()    // LDI
{
    env_.writeByte( DE(), env_.readByte( HL() ) );
    if( ++L == 0 ) ++H; // HL++
    if( ++E == 0 ) ++D; // DE++
    if( C-- == 0 ) --B; // BC--
    F &= ~(Halfcarry | Subtraction | Parity);
    if( BC() ) F |= Parity;
}

void Z80::opcode_ed_a1()    // CPI
{
    unsigned char f = F;

    cmpByte( env_.readByte( HL() ) );
    if( ++L == 0 ) ++H; // HL++
    if( C-- == 0 ) --B; // BC--
    F = (F & ~(Carry | Parity)) | (f & Carry);
    if( BC() ) F |= Parity;
}

void Z80::opcode_ed_a2()    // INI
{
    env_.writeByte( HL(), env_.readPort( C ) );
    if( ++L == 0 ) ++H; // HL++
    B = decByte( B );
}

void Z80::opcode_ed_a3()    // OUTI
{
    env_.writePort( C, env_.readByte( HL() ) );
    if( ++L == 0 ) ++H; // HL++
    B = decByte( B );
}

void Z80::opcode_ed_a8()    // LDD
{
    env_.writeByte( DE(), env_.readByte( HL() ) );
    if( L-- == 0 ) --H; // HL--
    if( E-- == 0 ) --D; // DE--
    if( C-- == 0 ) --B; // BC--
    F &= ~(Halfcarry | Subtraction | Parity);
    if( BC() ) F |= Parity;
}

void Z80::opcode_ed_a9()    // CPD
{
    unsigned char f = F;

    cmpByte( env_.readByte( HL() ) );
    if( L-- == 0 ) --H; // HL--
    if( C-- == 0 ) --B; // BC--
    F = (F & ~(Carry | Parity)) | (f & Carry);
    if( BC() ) F |= Parity;
}

void Z80::opcode_ed_aa()    // IND
{
    env_.writeByte( HL(), env_.readPort( C ) );
    if( L-- == 0 ) --H; // HL--
    B = decByte( B );
}

void Z80::opcode_ed_ab()    // OUTD
{
    env_.writePort( C, env_.readByte( HL() ) );
    if( L-- == 0 ) --H; // HL--
    B = decByte( B );
}

void Z80::opcode_ed_b0()    // LDIR
{
    opcode_ed_a0(); // LDI
    if( F & Parity ) { // After LDI, the Parity flag will be zero when BC=0
        cycles_ += 5;
        PC -= 2; // Decrement PC so that instruction is re-executed at next step (this allows interrupts to occur)
    }
}

void Z80::opcode_ed_b1()    // CPIR
{
    opcode_ed_a1(); // CPI
    if( (F & Parity) && !(F & Zero) ) { // Parity clear when BC=0, Zero set when A=(HL)
        cycles_ += 5;
        PC -= 2; // Decrement PC so that instruction is re-executed at next step (this allows interrupts to occur)
    }
}

void Z80::opcode_ed_b2()    // INIR
{
    opcode_ed_a2(); // INI
    if( B != 0 ) {
        cycles_ += 5;
        PC -= 2; // Decrement PC so that instruction is re-executed at next step (this allows interrupts to occur)
    }
}

void Z80::opcode_ed_b3()    // OTIR
{
    opcode_ed_a3(); // OUTI
    if( B != 0 ) {
        cycles_ += 5;
        PC -= 2; // Decrement PC so that instruction is re-executed at next step (this allows interrupts to occur)
    }
}

void Z80::opcode_ed_b8()    // LDDR
{
    opcode_ed_a8(); // LDD
    if( F & Parity ) { // After LDD, the Parity flag will be zero when BC=0
        cycles_ += 5;
        PC -= 2; // Decrement PC so that instruction is re-executed at next step (this allows interrupts to occur)
    }
}

void Z80::opcode_ed_b9()    // CPDR
{
    opcode_ed_a9(); // CPD
    if( (F & Parity) && !(F & Zero) ) { // Parity clear when BC=0, Zero set when A=(HL)
        cycles_ += 5;
        PC -= 2; // Decrement PC so that instruction is re-executed at next step (this allows interrupts to occur)
    }
}

void Z80::opcode_ed_ba()    // INDR
{
    opcode_ed_aa(); // IND
    if( B != 0 ) {
        cycles_ += 5;
        PC -= 2; // Decrement PC so that instruction is re-executed at next step (this allows interrupts to occur)
    }
}
                            
void Z80::opcode_ed_bb()    // OTDR
{
    opcode_ed_ab(); // OUTD
    if( B != 0 ) {
        cycles_ += 5;
        PC -= 2; // Decrement PC so that instruction is re-executed at next step (this allows interrupts to occur)
    }
}
