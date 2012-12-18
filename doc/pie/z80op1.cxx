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

Z80::OpcodeInfo Z80::OpInfo_[256] = {
    { &Z80::opcode_00,  4 }, // NOP
    { &Z80::opcode_01, 10 }, // LD   BC,nn
    { &Z80::opcode_02,  7 }, // LD   (BC),A
    { &Z80::opcode_03,  6 }, // INC  BC
    { &Z80::opcode_04,  4 }, // INC  B
    { &Z80::opcode_05,  4 }, // DEC  B
    { &Z80::opcode_06,  7 }, // LD   B,n
    { &Z80::opcode_07,  4 }, // RLCA
    { &Z80::opcode_08,  4 }, // EX   AF,AF'
    { &Z80::opcode_09, 11 }, // ADD  HL,BC
    { &Z80::opcode_0a,  7 }, // LD   A,(BC)
    { &Z80::opcode_0b,  6 }, // DEC  BC
    { &Z80::opcode_0c,  4 }, // INC  C
    { &Z80::opcode_0d,  4 }, // DEC  C
    { &Z80::opcode_0e,  7 }, // LD   C,n
    { &Z80::opcode_0f,  4 }, // RRCA
    { &Z80::opcode_10,  8 }, // DJNZ d
    { &Z80::opcode_11, 10 }, // LD   DE,nn
    { &Z80::opcode_12,  7 }, // LD   (DE),A
    { &Z80::opcode_13,  6 }, // INC  DE
    { &Z80::opcode_14,  4 }, // INC  D
    { &Z80::opcode_15,  4 }, // DEC  D
    { &Z80::opcode_16,  7 }, // LD   D,n
    { &Z80::opcode_17,  4 }, // RLA
    { &Z80::opcode_18, 12 }, // JR   d
    { &Z80::opcode_19, 11 }, // ADD  HL,DE
    { &Z80::opcode_1a,  7 }, // LD   A,(DE)
    { &Z80::opcode_1b,  6 }, // DEC  DE
    { &Z80::opcode_1c,  4 }, // INC  E
    { &Z80::opcode_1d,  4 }, // DEC  E
    { &Z80::opcode_1e,  7 }, // LD   E,n
    { &Z80::opcode_1f,  4 }, // RRA
    { &Z80::opcode_20,  7 }, // JR   NZ,d
    { &Z80::opcode_21, 10 }, // LD   HL,nn
    { &Z80::opcode_22, 16 }, // LD   (nn),HL
    { &Z80::opcode_23,  6 }, // INC  HL
    { &Z80::opcode_24,  4 }, // INC  H
    { &Z80::opcode_25,  4 }, // DEC  H
    { &Z80::opcode_26,  7 }, // LD   H,n
    { &Z80::opcode_27,  4 }, // DAA
    { &Z80::opcode_28,  7 }, // JR   Z,d
    { &Z80::opcode_29, 11 }, // ADD  HL,HL
    { &Z80::opcode_2a, 16 }, // LD   HL,(nn)
    { &Z80::opcode_2b,  6 }, // DEC  HL
    { &Z80::opcode_2c,  4 }, // INC  L
    { &Z80::opcode_2d,  4 }, // DEC  L
    { &Z80::opcode_2e,  7 }, // LD   L,n
    { &Z80::opcode_2f,  4 }, // CPL
    { &Z80::opcode_30,  7 }, // JR   NC,d
    { &Z80::opcode_31, 10 }, // LD   SP,nn
    { &Z80::opcode_32, 13 }, // LD   (nn),A
    { &Z80::opcode_33,  6 }, // INC  SP
    { &Z80::opcode_34, 11 }, // INC  (HL)
    { &Z80::opcode_35, 11 }, // DEC  (HL)
    { &Z80::opcode_36, 10 }, // LD   (HL),n
    { &Z80::opcode_37,  4 }, // SCF
    { &Z80::opcode_38,  7 }, // JR   C,d
    { &Z80::opcode_39, 11 }, // ADD  HL,SP
    { &Z80::opcode_3a, 13 }, // LD   A,(nn)
    { &Z80::opcode_3b,  6 }, // DEC  SP
    { &Z80::opcode_3c,  4 }, // INC  A
    { &Z80::opcode_3d,  4 }, // DEC  A
    { &Z80::opcode_3e,  7 }, // LD   A,n
    { &Z80::opcode_3f,  4 }, // CCF
    { &Z80::opcode_40,  4 }, // LD   B,B
    { &Z80::opcode_41,  4 }, // LD   B,C
    { &Z80::opcode_42,  4 }, // LD   B,D
    { &Z80::opcode_43,  4 }, // LD   B,E
    { &Z80::opcode_44,  4 }, // LD   B,H
    { &Z80::opcode_45,  4 }, // LD   B,L
    { &Z80::opcode_46,  7 }, // LD   B,(HL)
    { &Z80::opcode_47,  4 }, // LD   B,A
    { &Z80::opcode_48,  4 }, // LD   C,B
    { &Z80::opcode_49,  4 }, // LD   C,C
    { &Z80::opcode_4a,  4 }, // LD   C,D
    { &Z80::opcode_4b,  4 }, // LD   C,E
    { &Z80::opcode_4c,  4 }, // LD   C,H
    { &Z80::opcode_4d,  4 }, // LD   C,L
    { &Z80::opcode_4e,  7 }, // LD   C,(HL)
    { &Z80::opcode_4f,  4 }, // LD   C,A
    { &Z80::opcode_50,  4 }, // LD   D,B
    { &Z80::opcode_51,  4 }, // LD   D,C
    { &Z80::opcode_52,  4 }, // LD   D,D
    { &Z80::opcode_53,  4 }, // LD   D,E
    { &Z80::opcode_54,  4 }, // LD   D,H
    { &Z80::opcode_55,  4 }, // LD   D,L
    { &Z80::opcode_56,  7 }, // LD   D,(HL)
    { &Z80::opcode_57,  4 }, // LD   D,A
    { &Z80::opcode_58,  4 }, // LD   E,B
    { &Z80::opcode_59,  4 }, // LD   E,C
    { &Z80::opcode_5a,  4 }, // LD   E,D
    { &Z80::opcode_5b,  4 }, // LD   E,E
    { &Z80::opcode_5c,  4 }, // LD   E,H
    { &Z80::opcode_5d,  4 }, // LD   E,L
    { &Z80::opcode_5e,  7 }, // LD   E,(HL)
    { &Z80::opcode_5f,  4 }, // LD   E,A
    { &Z80::opcode_60,  4 }, // LD   H,B
    { &Z80::opcode_61,  4 }, // LD   H,C
    { &Z80::opcode_62,  4 }, // LD   H,D
    { &Z80::opcode_63,  4 }, // LD   H,E
    { &Z80::opcode_64,  4 }, // LD   H,H
    { &Z80::opcode_65,  4 }, // LD   H,L
    { &Z80::opcode_66,  7 }, // LD   H,(HL)
    { &Z80::opcode_67,  4 }, // LD   H,A
    { &Z80::opcode_68,  4 }, // LD   L,B
    { &Z80::opcode_69,  4 }, // LD   L,C
    { &Z80::opcode_6a,  4 }, // LD   L,D
    { &Z80::opcode_6b,  4 }, // LD   L,E
    { &Z80::opcode_6c,  4 }, // LD   L,H
    { &Z80::opcode_6d,  4 }, // LD   L,L
    { &Z80::opcode_6e,  7 }, // LD   L,(HL)
    { &Z80::opcode_6f,  4 }, // LD   L,A
    { &Z80::opcode_70,  7 }, // LD   (HL),B
    { &Z80::opcode_71,  7 }, // LD   (HL),C
    { &Z80::opcode_72,  7 }, // LD   (HL),D
    { &Z80::opcode_73,  7 }, // LD   (HL),E
    { &Z80::opcode_74,  7 }, // LD   (HL),H
    { &Z80::opcode_75,  7 }, // LD   (HL),L
    { &Z80::opcode_76,  4 }, // HALT
    { &Z80::opcode_77,  7 }, // LD   (HL),A
    { &Z80::opcode_78,  4 }, // LD   A,B
    { &Z80::opcode_79,  4 }, // LD   A,C
    { &Z80::opcode_7a,  4 }, // LD   A,D
    { &Z80::opcode_7b,  4 }, // LD   A,E
    { &Z80::opcode_7c,  4 }, // LD   A,H
    { &Z80::opcode_7d,  4 }, // LD   A,L
    { &Z80::opcode_7e,  7 }, // LD   A,(HL)
    { &Z80::opcode_7f,  4 }, // LD   A,A
    { &Z80::opcode_80,  4 }, // ADD  A,B
    { &Z80::opcode_81,  4 }, // ADD  A,C
    { &Z80::opcode_82,  4 }, // ADD  A,D
    { &Z80::opcode_83,  4 }, // ADD  A,E
    { &Z80::opcode_84,  4 }, // ADD  A,H
    { &Z80::opcode_85,  4 }, // ADD  A,L
    { &Z80::opcode_86,  7 }, // ADD  A,(HL)
    { &Z80::opcode_87,  4 }, // ADD  A,A
    { &Z80::opcode_88,  4 }, // ADC  A,B
    { &Z80::opcode_89,  4 }, // ADC  A,C
    { &Z80::opcode_8a,  4 }, // ADC  A,D
    { &Z80::opcode_8b,  4 }, // ADC  A,E
    { &Z80::opcode_8c,  4 }, // ADC  A,H
    { &Z80::opcode_8d,  4 }, // ADC  A,L
    { &Z80::opcode_8e,  7 }, // ADC  A,(HL)
    { &Z80::opcode_8f,  4 }, // ADC  A,A
    { &Z80::opcode_90,  4 }, // SUB  B
    { &Z80::opcode_91,  4 }, // SUB  C
    { &Z80::opcode_92,  4 }, // SUB  D
    { &Z80::opcode_93,  4 }, // SUB  E
    { &Z80::opcode_94,  4 }, // SUB  H
    { &Z80::opcode_95,  4 }, // SUB  L
    { &Z80::opcode_96,  7 }, // SUB  (HL)
    { &Z80::opcode_97,  4 }, // SUB  A
    { &Z80::opcode_98,  4 }, // SBC  A,B
    { &Z80::opcode_99,  4 }, // SBC  A,C
    { &Z80::opcode_9a,  4 }, // SBC  A,D
    { &Z80::opcode_9b,  4 }, // SBC  A,E
    { &Z80::opcode_9c,  4 }, // SBC  A,H
    { &Z80::opcode_9d,  4 }, // SBC  A,L
    { &Z80::opcode_9e,  7 }, // SBC  A,(HL)
    { &Z80::opcode_9f,  4 }, // SBC  A,A
    { &Z80::opcode_a0,  4 }, // AND  B
    { &Z80::opcode_a1,  4 }, // AND  C
    { &Z80::opcode_a2,  4 }, // AND  D
    { &Z80::opcode_a3,  4 }, // AND  E
    { &Z80::opcode_a4,  4 }, // AND  H
    { &Z80::opcode_a5,  4 }, // AND  L
    { &Z80::opcode_a6,  7 }, // AND  (HL)
    { &Z80::opcode_a7,  4 }, // AND  A
    { &Z80::opcode_a8,  4 }, // XOR  B
    { &Z80::opcode_a9,  4 }, // XOR  C
    { &Z80::opcode_aa,  4 }, // XOR  D
    { &Z80::opcode_ab,  4 }, // XOR  E
    { &Z80::opcode_ac,  4 }, // XOR  H
    { &Z80::opcode_ad,  4 }, // XOR  L
    { &Z80::opcode_ae,  7 }, // XOR  (HL)
    { &Z80::opcode_af,  4 }, // XOR  A
    { &Z80::opcode_b0,  4 }, // OR   B
    { &Z80::opcode_b1,  4 }, // OR   C
    { &Z80::opcode_b2,  4 }, // OR   D
    { &Z80::opcode_b3,  4 }, // OR   E
    { &Z80::opcode_b4,  4 }, // OR   H
    { &Z80::opcode_b5,  4 }, // OR   L
    { &Z80::opcode_b6,  7 }, // OR   (HL)
    { &Z80::opcode_b7,  4 }, // OR   A
    { &Z80::opcode_b8,  4 }, // CP   B
    { &Z80::opcode_b9,  4 }, // CP   C
    { &Z80::opcode_ba,  4 }, // CP   D
    { &Z80::opcode_bb,  4 }, // CP   E
    { &Z80::opcode_bc,  4 }, // CP   H
    { &Z80::opcode_bd,  4 }, // CP   L
    { &Z80::opcode_be,  7 }, // CP   (HL)
    { &Z80::opcode_bf,  4 }, // CP   A
    { &Z80::opcode_c0,  5 }, // RET  NZ
    { &Z80::opcode_c1, 10 }, // POP  BC
    { &Z80::opcode_c2, 10 }, // JP   NZ,nn
    { &Z80::opcode_c3, 10 }, // JP   nn
    { &Z80::opcode_c4, 10 }, // CALL NZ,nn
    { &Z80::opcode_c5, 11 }, // PUSH BC
    { &Z80::opcode_c6,  7 }, // ADD  A,n
    { &Z80::opcode_c7, 11 }, // RST  0
    { &Z80::opcode_c8,  5 }, // RET  Z
    { &Z80::opcode_c9, 10 }, // RET
    { &Z80::opcode_ca, 10 }, // JP   Z,nn
    { &Z80::opcode_cb,  0 }, // [Prefix]
    { &Z80::opcode_cc, 10 }, // CALL Z,nn
    { &Z80::opcode_cd, 17 }, // CALL nn
    { &Z80::opcode_ce,  7 }, // ADC  A,n
    { &Z80::opcode_cf, 11 }, // RST  8
    { &Z80::opcode_d0,  5 }, // RET  NC
    { &Z80::opcode_d1, 10 }, // POP  DE
    { &Z80::opcode_d2, 10 }, // JP   NC,nn
    { &Z80::opcode_d3, 11 }, // OUT  (n),A
    { &Z80::opcode_d4, 10 }, // CALL NC,nn
    { &Z80::opcode_d5, 11 }, // PUSH DE
    { &Z80::opcode_d6,  7 }, // SUB  n
    { &Z80::opcode_d7, 11 }, // RST  10H
    { &Z80::opcode_d8,  5 }, // RET  C
    { &Z80::opcode_d9,  4 }, // EXX
    { &Z80::opcode_da, 10 }, // JP   C,nn
    { &Z80::opcode_db, 11 }, // IN   A,(n)
    { &Z80::opcode_dc, 10 }, // CALL C,nn
    { &Z80::opcode_dd,  0 }, // [IX Prefix]
    { &Z80::opcode_de,  7 }, // SBC  A,n
    { &Z80::opcode_df, 11 }, // RST  18H
    { &Z80::opcode_e0,  5 }, // RET  PO
    { &Z80::opcode_e1, 10 }, // POP  HL
    { &Z80::opcode_e2, 10 }, // JP   PO,nn
    { &Z80::opcode_e3, 19 }, // EX   (SP),HL
    { &Z80::opcode_e4, 10 }, // CALL PO,nn
    { &Z80::opcode_e5, 11 }, // PUSH HL
    { &Z80::opcode_e6,  7 }, // AND  n
    { &Z80::opcode_e7, 11 }, // RST  20H
    { &Z80::opcode_e8,  5 }, // RET  PE
    { &Z80::opcode_e9,  4 }, // JP   (HL)
    { &Z80::opcode_ea, 10 }, // JP   PE,nn
    { &Z80::opcode_eb,  4 }, // EX   DE,HL
    { &Z80::opcode_ec, 10 }, // CALL PE,nn
    { &Z80::opcode_ed,  0 }, // [Prefix]
    { &Z80::opcode_ee,  7 }, // XOR  n
    { &Z80::opcode_ef, 11 }, // RST  28H
    { &Z80::opcode_f0,  5 }, // RET  P
    { &Z80::opcode_f1, 10 }, // POP  AF
    { &Z80::opcode_f2, 10 }, // JP   P,nn
    { &Z80::opcode_f3,  4 }, // DI
    { &Z80::opcode_f4, 10 }, // CALL P,nn
    { &Z80::opcode_f5, 11 }, // PUSH AF
    { &Z80::opcode_f6,  7 }, // OR   n
    { &Z80::opcode_f7, 11 }, // RST  30H
    { &Z80::opcode_f8,  5 }, // RET  M
    { &Z80::opcode_f9,  6 }, // LD   SP,HL
    { &Z80::opcode_fa, 10 }, // JP   M,nn
    { &Z80::opcode_fb,  4 }, // EI
    { &Z80::opcode_fc, 10 }, // CALL M,nn
    { &Z80::opcode_fd,  0 }, // [IY Prefix]
    { &Z80::opcode_fe,  7 }, // CP   n
    { &Z80::opcode_ff, 11 }  // RST  38H
};                          

void Z80::opcode_00()    // NOP
{
}

void Z80::opcode_01()    // LD   BC,nn
{
    C = fetchByte();
    B = fetchByte();
}

void Z80::opcode_02()    // LD   (BC),A
{
    env_.writeByte( BC(), A );
}

void Z80::opcode_03()    // INC  BC
{
    if( ++C == 0 ) ++B;
}

void Z80::opcode_04()    // INC  B
{
    B = incByte( B );
}

void Z80::opcode_05()    // DEC  B
{
    B = decByte( B );
}

void Z80::opcode_06()    // LD   B,n
{
    B = fetchByte();
}

void Z80::opcode_07()    // RLCA
{
    A = (A << 1) | (A >> 7);
    F = F & ~(AddSub | Halfcarry | Carry);
    if( A & 0x01 ) F |= Carry;
}

void Z80::opcode_08()    // EX   AF,AF'
{
    unsigned char x;

    x = A; A = A1; A1 = x;
    x = F; F = F1; F1 = x;
}

void Z80::opcode_09()    // ADD  HL,BC
{
    unsigned hl = HL();
    unsigned rp = BC();
    unsigned x  = hl + rp;

    F &= Sign | Zero | Parity;
    if( x > 0xFFFF ) F |= Carry;
    if( ((hl & 0xFFF) + (rp & 0xFFF)) > 0xFFF ) F |= Halfcarry;

    L = x & 0xFF;
    H = (x >> 8) & 0xFF;
}

void Z80::opcode_0a()    // LD   A,(BC)
{
    A = env_.readByte( BC() );
}

void Z80::opcode_0b()    // DEC  BC
{
    if( C-- == 0 ) --B;
}

void Z80::opcode_0c()    // INC  C
{
    C = incByte( C );
}

void Z80::opcode_0d()    // DEC  C
{
    C = decByte( C );
}

void Z80::opcode_0e()    // LD   C,n
{
    C = fetchByte();
}

void Z80::opcode_0f()    // RRCA
{
    A = (A >> 1) | (A << 7);
    F = F & ~(AddSub | Halfcarry | Carry);
    if( A & 0x80 ) F |= Carry;
}

void Z80::opcode_10()    // DJNZ d
{
    unsigned char o = fetchByte();
    
    if( --B != 0 ) relJump( o ); 
}

void Z80::opcode_11()    // LD   DE,nn
{
    E = fetchByte();
    D = fetchByte();
}

void Z80::opcode_12()    // LD   (DE),A
{
    env_.writeByte( DE(), A );
}

void Z80::opcode_13()    // INC  DE
{
    if( ++E == 0 ) ++D;
}

void Z80::opcode_14()    // INC  D
{
    D = incByte( D );
}

void Z80::opcode_15()    // DEC  D
{
    D = decByte( D );
}

void Z80::opcode_16()    // LD   D,n
{
    D = fetchByte();
}

void Z80::opcode_17()    // RLA
{
    unsigned char a = A;

    A <<= 1;
    if( F & Carry ) A |= 0x01;
    F = F & ~(AddSub | Halfcarry | Carry);
    if( a & 0x80 ) F |= Carry;
}

void Z80::opcode_18()    // JR   d
{
    relJump( fetchByte() );
}

void Z80::opcode_19()    // ADD  HL,DE
{
    unsigned hl = HL();
    unsigned rp = DE();
    unsigned x  = hl + rp;

    F &= Sign | Zero | Parity;
    if( x > 0xFFFF ) F |= Carry;
    if( ((hl & 0xFFF) + (rp & 0xFFF)) > 0xFFF ) F |= Halfcarry;

    L = x & 0xFF;
    H = (x >> 8) & 0xFF;
}

void Z80::opcode_1a()    // LD   A,(DE)
{
    A = env_.readByte( DE() );
}

void Z80::opcode_1b()    // DEC  DE
{
    if( E-- == 0 ) --D;
}

void Z80::opcode_1c()    // INC  E
{
    E = incByte( E );
}

void Z80::opcode_1d()    // DEC  E
{
    E = decByte( E );
}

void Z80::opcode_1e()    // LD   E,n
{
    E = fetchByte();
}

void Z80::opcode_1f()    // RRA
{
    unsigned char a = A;

    A >>= 1;
    if( F & Carry ) A |= 0x80;
    F = F & ~(AddSub | Halfcarry | Carry);
    if( a & 0x01 ) F |= Carry;
}

void Z80::opcode_20()    // JR   NZ,d
{
    unsigned char o = fetchByte();
    
    if( ! (F & Zero) ) relJump( o );
}

void Z80::opcode_21()    // LD   HL,nn
{
    L = fetchByte();
    H = fetchByte();
}

void Z80::opcode_22()    // LD   (nn),HL
{
    unsigned x = fetchWord();

    env_.writeByte( x  , L );
    env_.writeByte( x+1, H );
}

void Z80::opcode_23()    // INC  HL
{
    if( ++L == 0 ) ++H;
}

void Z80::opcode_24()    // INC  H
{
    H = incByte( H );
}

void Z80::opcode_25()    // DEC  H
{
    H = decByte( H );
}

void Z80::opcode_26()    // LD   H,n
{
    H = fetchByte();
}

/*
    DAA is computed using the following table to get a diff value
    that is added to or subtracted (according to the N flag) from A:

        C Upper H Lower Diff
        -+-----+-+-----+----
        1   *   0  0-9   60
        1   *   1  0-9   66
        1   *   *  A-F   66
        0  0-9  0  0-9   00
        0  0-9  1  0-9   06
        0  0-8  *  A-F   06
        0  A-F  0  0-9   60
        0  9-F  *  A-F   66
        0  A-F  1  0-9   66

    The carry and halfcarry flags are then updated using similar tables.

    These tables were found by Stefano Donati of Ramsoft and are
    published in the "Undocumented Z80 Documented" paper by Sean Young,
    the following is an algorithmical implementation with no lookups.
*/
void Z80::opcode_27()    // DAA
{
    unsigned char diff;
    unsigned char hf = F & Halfcarry;
    unsigned char cf = F & Carry;
    unsigned char lower = A & 0x0F;

    if( cf ) {
        diff = (lower >= 0x0A) || hf ? 0x66 : 0x60;
    }
    else {
        diff = (A >= 0x9A) ? 0x60 : 0x00;

        if( hf || (lower >= 0x0A) ) diff += 0x06;
    }

    if( A >= 0x9A ) cf = Carry;

    if( F & Subtraction ) {
        A -= diff;
        F = PSZ_[A] | Subtraction | cf;
        if( hf && (lower <= 0x05) ) F |= Halfcarry;
    }
    else {
        A += diff;
        F = PSZ_[A] | cf;
        if( lower >= 0x0A ) F |= Halfcarry;
    }
}

void Z80::opcode_28()    // JR   Z,d
{
    unsigned char   o = fetchByte();
    
    if( F & Zero ) relJump( o );
}

void Z80::opcode_29()    // ADD  HL,HL
{
    unsigned hl = HL();
    unsigned rp = hl;
    unsigned x  = hl + rp;

    F &= Sign | Zero | Parity;
    if( x > 0xFFFF ) F |= Carry;
    if( ((hl & 0xFFF) + (rp & 0xFFF)) > 0xFFF ) F |= Halfcarry;

    L = x & 0xFF;
    H = (x >> 8) & 0xFF;
}

void Z80::opcode_2a()    // LD   HL,(nn)
{
    unsigned x = fetchWord();

    L = env_.readByte( x );
    H = env_.readByte( x+1 );
}

void Z80::opcode_2b()    // DEC  HL
{
    if( L-- == 0 ) --H;
}

void Z80::opcode_2c()    // INC  L
{
    L = incByte( L );
}

void Z80::opcode_2d()    // DEC  L
{
    L = decByte( L );
}

void Z80::opcode_2e()    // LD   L,n
{
    L = fetchByte();
}

void Z80::opcode_2f()    // CPL
{
    A ^= 0xFF;
    F |= AddSub | Halfcarry;
}

void Z80::opcode_30()    // JR   NC,d
{
    unsigned char o = fetchByte();
    
    if( ! (F & Carry) ) relJump( o );
}

void Z80::opcode_31()    // LD   SP,nn
{
    SP = fetchWord();
}

void Z80::opcode_32()    // LD   (nn),A
{
    env_.writeByte( fetchWord(), A );
}

void Z80::opcode_33()    // INC  SP
{
    SP = (SP + 1) & 0xFFFF;
}

void Z80::opcode_34()    // INC  (HL)
{
    env_.writeByte( HL(), incByte( env_.readByte( HL() ) ) );
}

void Z80::opcode_35()    // DEC  (HL)
{
    env_.writeByte( HL(), decByte( env_.readByte( HL() ) ) );
}

void Z80::opcode_36()    // LD   (HL),n
{
    env_.writeByte( HL(), fetchByte() );
}

void Z80::opcode_37()    // SCF
{
    F = (F & (Parity | Sign | Zero)) | Carry;
}

void Z80::opcode_38()    // JR   C,d
{
    unsigned char o = fetchByte();
    
    if( F & Carry ) relJump( o );
}

void Z80::opcode_39()    // ADD  HL,SP
{
    unsigned hl = HL();
    unsigned rp = SP;
    unsigned x  = hl + rp;

    F &= Sign | Zero | Parity;
    if( x > 0xFFFF ) F |= Carry;
    if( ((hl & 0xFFF) + (rp & 0xFFF)) > 0xFFF ) F |= Halfcarry;

    L = x & 0xFF;
    H = (x >> 8) & 0xFF;
}

void Z80::opcode_3a()    // LD   A,(nn)
{
    A = env_.readByte( fetchWord() );
}

void Z80::opcode_3b()    // DEC  SP
{
    SP = (SP - 1) & 0xFFFF;
}

void Z80::opcode_3c()    // INC  A
{
    A = incByte( A );
}

void Z80::opcode_3d()    // DEC  A
{
    A = decByte( A );
}

void Z80::opcode_3e()    // LD   A,n
{
    A = fetchByte();
}

void Z80::opcode_3f()    // CCF
{
    if( F & Carry ) {
        F = (F & (Parity | Sign | Zero)) | Halfcarry; // Halfcarry holds previous carry
    }
    else {
        F = (F & (Parity | Sign | Zero)) | Carry;
    }
}

void Z80::opcode_40()    // LD   B,B
{
}

void Z80::opcode_41()    // LD   B,C
{
    B = C;
}

void Z80::opcode_42()    // LD   B,D
{
    B = D;
}

void Z80::opcode_43()    // LD   B,E
{
    B = E;
}

void Z80::opcode_44()    // LD   B,H
{
    B = H;
}

void Z80::opcode_45()    // LD   B,L
{
    B = L;
}

void Z80::opcode_46()    // LD   B,(HL)
{
    B = env_.readByte( HL() );
}

void Z80::opcode_47()    // LD   B,A
{
    B = A;
}

void Z80::opcode_48()    // LD   C,B
{
    C = B;
}

void Z80::opcode_49()    // LD   C,C
{
}

void Z80::opcode_4a()    // LD   C,D
{
    C = D;
}

void Z80::opcode_4b()    // LD   C,E
{
    C = E;
}

void Z80::opcode_4c()    // LD   C,H
{
    C = H;
}

void Z80::opcode_4d()    // LD   C,L
{
    C = L;
}

void Z80::opcode_4e()    // LD   C,(HL)
{
    C = env_.readByte( HL() );
}

void Z80::opcode_4f()    // LD   C,A
{
    C = A;
}

void Z80::opcode_50()    // LD   D,B
{
    D = B;
}

void Z80::opcode_51()    // LD   D,C
{
    D = C;
}

void Z80::opcode_52()    // LD   D,D
{
}

void Z80::opcode_53()    // LD   D,E
{
    D = E;
}

void Z80::opcode_54()    // LD   D,H
{
    D = H;
}

void Z80::opcode_55()    // LD   D,L
{
    D = L;
}

void Z80::opcode_56()    // LD   D,(HL)
{
    D = env_.readByte( HL() );
}

void Z80::opcode_57()    // LD   D,A
{
    D = A;
}

void Z80::opcode_58()    // LD   E,B
{
    E = B;
}

void Z80::opcode_59()    // LD   E,C
{
    E = C;
}

void Z80::opcode_5a()    // LD   E,D
{
    E = D;
}

void Z80::opcode_5b()    // LD   E,E
{
}

void Z80::opcode_5c()    // LD   E,H
{
    E = H;
}

void Z80::opcode_5d()    // LD   E,L
{
    E = L;
}

void Z80::opcode_5e()    // LD   E,(HL)
{
    E = env_.readByte( HL() );
}

void Z80::opcode_5f()    // LD   E,A
{
    E = A;
}

void Z80::opcode_60()    // LD   H,B
{
    H = B;
}

void Z80::opcode_61()    // LD   H,C
{
    H = C;
}

void Z80::opcode_62()    // LD   H,D
{
    H = D;
}

void Z80::opcode_63()    // LD   H,E
{
    H = E;
}

void Z80::opcode_64()    // LD   H,H
{
}

void Z80::opcode_65()    // LD   H,L
{
    H = L;
}

void Z80::opcode_66()    // LD   H,(HL)
{
    H = env_.readByte( HL() );
}

void Z80::opcode_67()    // LD   H,A
{
    H = A;
}

void Z80::opcode_68()    // LD   L,B
{
    L = B;
}

void Z80::opcode_69()    // LD   L,C
{
    L = C;
}

void Z80::opcode_6a()    // LD   L,D
{
    L = D;
}

void Z80::opcode_6b()    // LD   L,E
{
    L = E;
}

void Z80::opcode_6c()    // LD   L,H
{
    L = H;
}

void Z80::opcode_6d()    // LD   L,L
{
}

void Z80::opcode_6e()    // LD   L,(HL)
{
    L = env_.readByte( HL() );
}

void Z80::opcode_6f()    // LD   L,A
{
    L = A;
}

void Z80::opcode_70()    // LD   (HL),B
{
    env_.writeByte( HL(), B );
}

void Z80::opcode_71()    // LD   (HL),C
{
    env_.writeByte( HL(), C );
}

void Z80::opcode_72()    // LD   (HL),D
{
    env_.writeByte( HL(), D );
}

void Z80::opcode_73()    // LD   (HL),E
{
    env_.writeByte( HL(), E );
}

void Z80::opcode_74()    // LD   (HL),H
{
    env_.writeByte( HL(), H );
}

void Z80::opcode_75()    // LD   (HL),L
{
    env_.writeByte( HL(), L );
}

void Z80::opcode_76()    // HALT
{
    iflags_ |= Halted;
}

void Z80::opcode_77()    // LD   (HL),A
{
    env_.writeByte( HL(), A );
}

void Z80::opcode_78()    // LD   A,B
{
    A = B;
}

void Z80::opcode_79()    // LD   A,C
{
    A = C;
}

void Z80::opcode_7a()    // LD   A,D
{
    A = D;
}

void Z80::opcode_7b()    // LD   A,E
{
    A = E;
}

void Z80::opcode_7c()    // LD   A,H
{
    A = H;
}

void Z80::opcode_7d()    // LD   A,L
{
    A = L;
}

void Z80::opcode_7e()    // LD   A,(HL)
{
    A = env_.readByte( HL() );
}

void Z80::opcode_7f()    // LD   A,A
{
}

void Z80::opcode_80()    // ADD  A,B
{
    addByte( B, 0 );
}

void Z80::opcode_81()    // ADD  A,C
{
    addByte( C, 0 );
}

void Z80::opcode_82()    // ADD  A,D
{
    addByte( D, 0 );
}

void Z80::opcode_83()    // ADD  A,E
{
    addByte( E, 0 );
}

void Z80::opcode_84()    // ADD  A,H
{
    addByte( H, 0 );
}

void Z80::opcode_85()    // ADD  A,L
{
    addByte( L, 0 );
}

void Z80::opcode_86()    // ADD  A,(HL)
{
    addByte( env_.readByte( HL() ), 0 );
}

void Z80::opcode_87()    // ADD  A,A
{
    addByte( A, 0 );
}

void Z80::opcode_88()    // ADC  A,B
{
    addByte( B, F & Carry );
}

void Z80::opcode_89()    // ADC  A,C
{
    addByte( C, F & Carry );
}

void Z80::opcode_8a()    // ADC  A,D
{
    addByte( D, F & Carry );
}

void Z80::opcode_8b()    // ADC  A,E
{
    addByte( E, F & Carry );
}

void Z80::opcode_8c()    // ADC  A,H
{
    addByte( H, F & Carry );
}

void Z80::opcode_8d()    // ADC  A,L
{
    addByte( L, F & Carry );
}

void Z80::opcode_8e()    // ADC  A,(HL)
{
    addByte( env_.readByte( HL() ), F & Carry );
}

void Z80::opcode_8f()    // ADC  A,A
{
    addByte( A, F & Carry );
}

void Z80::opcode_90()    // SUB  B
{
    A = subByte( B, 0 );
}

void Z80::opcode_91()    // SUB  C
{
    A = subByte( C, 0 );
}

void Z80::opcode_92()    // SUB  D
{
    A = subByte( D, 0 );
}

void Z80::opcode_93()    // SUB  E
{
    A = subByte( E, 0 );
}

void Z80::opcode_94()    // SUB  H
{
    A = subByte( H, 0 );
}

void Z80::opcode_95()    // SUB  L
{
    A = subByte( L, 0 );
}

void Z80::opcode_96()    // SUB  (HL)
{
    A = subByte( env_.readByte( HL() ), 0 );
}

void Z80::opcode_97()    // SUB  A
{
    A = subByte( A, 0 );
}

void Z80::opcode_98()    // SBC  A,B
{
    A = subByte( B, F & Carry );
}

void Z80::opcode_99()    // SBC  A,C
{
    A = subByte( C, F & Carry );
}

void Z80::opcode_9a()    // SBC  A,D
{
    A = subByte( D, F & Carry );
}

void Z80::opcode_9b()    // SBC  A,E
{
    A = subByte( E, F & Carry );
}

void Z80::opcode_9c()    // SBC  A,H
{
    A = subByte( H, F & Carry );
}

void Z80::opcode_9d()    // SBC  A,L
{
    A = subByte( L, F & Carry );
}

void Z80::opcode_9e()    // SBC  A,(HL)
{
    A = subByte( env_.readByte( HL() ), F & Carry );
}

void Z80::opcode_9f()    // SBC  A,A
{
    A = subByte( A, F & Carry );
}

void Z80::opcode_a0()    // AND  B
{
    A &= B;
    setFlagsPSZ();
}

void Z80::opcode_a1()    // AND  C
{
    A &= C;
    setFlagsPSZ();
}

void Z80::opcode_a2()    // AND  D
{
    A &= D;
    setFlagsPSZ();
}

void Z80::opcode_a3()    // AND  E
{
    A &= E;
    setFlagsPSZ();
}

void Z80::opcode_a4()    // AND  H
{
    A &= H;
    setFlagsPSZ();
}

void Z80::opcode_a5()    // AND  L
{
    A &= L;
    setFlagsPSZ();
}

void Z80::opcode_a6()    // AND  (HL)
{
    A &= env_.readByte( HL() );
    setFlagsPSZ();
}

void Z80::opcode_a7()    // AND  A
{
    setFlagsPSZ();
}

void Z80::opcode_a8()    // XOR  B
{
    A ^= B;
    setFlags35PSZ000();
}

void Z80::opcode_a9()    // XOR  C
{
    A ^= C;
    setFlags35PSZ000();
}

void Z80::opcode_aa()    // XOR  D
{
    A ^= D;
    setFlags35PSZ000();
}

void Z80::opcode_ab()    // XOR  E
{
    A ^= E;
    setFlags35PSZ000();
}

void Z80::opcode_ac()    // XOR  H
{
    A ^= H;
    setFlags35PSZ000();
}

void Z80::opcode_ad()    // XOR  L
{
    A ^= L;
    setFlags35PSZ000();
}

void Z80::opcode_ae()    // XOR  (HL)
{
    A ^= env_.readByte( HL() );
    setFlags35PSZ000();
}

void Z80::opcode_af()    // XOR  A
{
    A = 0;
    setFlags35PSZ000();
}

void Z80::opcode_b0()    // OR   B
{
    A |= B;
    setFlags35PSZ000();
}

void Z80::opcode_b1()    // OR   C
{
    A |= C;
    setFlags35PSZ000();
}

void Z80::opcode_b2()    // OR   D
{
    A |= D;
    setFlags35PSZ000();
}

void Z80::opcode_b3()    // OR   E
{
    A |= E;
    setFlags35PSZ000();
}

void Z80::opcode_b4()    // OR   H
{
    A |= H;
    setFlags35PSZ000();
}

void Z80::opcode_b5()    // OR   L
{
    A |= L;
    setFlags35PSZ000();
}

void Z80::opcode_b6()    // OR   (HL)
{
    A |= env_.readByte( HL() );
    setFlags35PSZ000();
}

void Z80::opcode_b7()    // OR   A
{
    setFlags35PSZ000();
}

void Z80::opcode_b8()    // CP   B
{
    cmpByte( B );
}

void Z80::opcode_b9()    // CP   C
{
    cmpByte( C );
}

void Z80::opcode_ba()    // CP   D
{
    cmpByte( D );
}

void Z80::opcode_bb()    // CP   E
{
    cmpByte( E );
}

void Z80::opcode_bc()    // CP   H
{
    cmpByte( H );
}

void Z80::opcode_bd()    // CP   L
{
    cmpByte( L );
}

void Z80::opcode_be()    // CP   (HL)
{
    cmpByte( env_.readByte( HL() ) );
}

void Z80::opcode_bf()    // CP   A
{
    cmpByte( A );
}

void Z80::opcode_c0()    // RET  NZ
{
    if( ! (F & Zero) ) {
        retFromSub();
        cycles_ += 2;
    }
}

void Z80::opcode_c1()    // POP  BC
{
    C = env_.readByte( SP++ );
    B = env_.readByte( SP++ );
}

void Z80::opcode_c2()    // JP   NZ,nn
{
    if( ! (F & Zero) )
        PC = fetchWord();
    else
        PC += 2;
}

void Z80::opcode_c3()    // JP   nn
{
     PC = readWord( PC );
}

void Z80::opcode_c4()    // CALL NZ,nn
{
    if( ! (F & Zero) ) {
        callSub( fetchWord() );
        cycles_ += 2;
    }
    else {
        PC += 2;
    }
}

void Z80::opcode_c5()    // PUSH BC
{
    env_.writeByte( --SP, B );
    env_.writeByte( --SP, C );
}

void Z80::opcode_c6()    // ADD  A,n
{
    addByte( fetchByte(), 0 );
}

void Z80::opcode_c7()    // RST  0
{
    callSub( 0x00 );
}

void Z80::opcode_c8()    // RET  Z
{
    if( F & Zero ) {
        retFromSub();
        cycles_ += 2;
    }
}

void Z80::opcode_c9()    // RET
{
     retFromSub();
}

void Z80::opcode_ca()    // JP   Z,nn
{
    if( F & Zero )
        PC = fetchWord();
    else
        PC += 2;
}

void Z80::opcode_cb()    // [Prefix]
{
    unsigned op = fetchByte();

    cycles_ += OpInfoCB_[ op ].cycles;
    (this->*(OpInfoCB_[ op ].handler))();
}

void Z80::opcode_cc()    // CALL Z,nn
{
    if( F & Zero ) {
        callSub( fetchWord() );
        cycles_ += 2;
    }
    else {
        PC += 2;
    }
}

void Z80::opcode_cd()    // CALL nn
{
    callSub( fetchWord() );
}

void Z80::opcode_ce()    // ADC  A,n
{
    addByte( fetchByte(), F & Carry );
}

void Z80::opcode_cf()    // RST  8
{
    callSub( 0x08 );
}

void Z80::opcode_d0()    // RET  NC
{
    if( ! (F & Carry) ) {
        retFromSub();
        cycles_ += 2;
    }
}

void Z80::opcode_d1()    // POP  DE
{
    E = env_.readByte( SP++ );
    D = env_.readByte( SP++ );
}

void Z80::opcode_d2()    // JP   NC,nn
{
    if( ! (F & Carry) )
        PC = fetchWord();
    else
        PC += 2;
}

void Z80::opcode_d3()    // OUT  (n),A
{
    env_.writePort( fetchByte(), A );
}

void Z80::opcode_d4()    // CALL NC,nn
{
    if( ! (F & Carry) ) {
        callSub( fetchWord() );
        cycles_ += 2;
    }
    else {
        PC += 2;
    }
}

void Z80::opcode_d5()    // PUSH DE
{
    env_.writeByte( --SP, D );
    env_.writeByte( --SP, E );
}

void Z80::opcode_d6()    // SUB  n
{
    A = subByte( fetchByte(), 0 );
}

void Z80::opcode_d7()    // RST  10H
{
    callSub( 0x10 );
}

void Z80::opcode_d8()    // RET  C
{
    if( F & Carry ) {
        retFromSub();
        cycles_ += 2;
    }
}

void Z80::opcode_d9()    // EXX
{
    unsigned char x;

    x = B; B = B1; B1 = x;
    x = C; C = C1; C1 = x;
    x = D; D = D1; D1 = x;
    x = E; E = E1; E1 = x;
    x = H; H = H1; H1 = x;
    x = L; L = L1; L1 = x;
}

void Z80::opcode_da()    // JP   C,nn
{
    if( F & Carry )
        PC = fetchWord();
    else
        PC += 2;
}

void Z80::opcode_db()    // IN   A,(n)
{
    A = env_.readPort( fetchByte() );
}

void Z80::opcode_dc()    // CALL C,nn
{
    if( F & Carry ) {
        callSub( fetchWord() );
        cycles_ += 2;
    }
    else {
        PC += 2;
    }
}

void Z80::opcode_dd()    // [IX Prefix]
{
    do_opcode_xy( OpInfoDD_ );
    IX &= 0xFFFF;
}

void Z80::opcode_de()    // SBC  A,n
{
    A = subByte( fetchByte(), F & Carry );
}

void Z80::opcode_df()    // RST  18H
{
    callSub( 0x18 );
}

void Z80::opcode_e0()    // RET  PO
{
    if( ! (F & Parity) ) {
        retFromSub();
        cycles_ += 2;
    }
}

void Z80::opcode_e1()    // POP  HL
{
    L = env_.readByte( SP++ );
    H = env_.readByte( SP++ );
}

void Z80::opcode_e2()    // JP   PO,nn
{
    if( ! (F & Parity) )
        PC = fetchWord();
    else
        PC += 2;
}

void Z80::opcode_e3()    // EX   (SP),HL
{
    unsigned char x;

    x = env_.readByte( SP   ); env_.writeByte( SP,   L ); L = x;
    x = env_.readByte( SP+1 ); env_.writeByte( SP+1, H ); H = x;
}

void Z80::opcode_e4()    // CALL PO,nn
{
    if( ! (F & Parity) ) {
        callSub( fetchWord() );
        cycles_ += 2;
    }
    else {
        PC += 2;
    }
}

void Z80::opcode_e5()    // PUSH HL
{
    env_.writeByte( --SP, H );
    env_.writeByte( --SP, L );
}

void Z80::opcode_e6()    // AND  n
{
    A &= fetchByte();
    setFlagsPSZ();
}

void Z80::opcode_e7()    // RST  20H
{
    callSub( 0x20 );
}

void Z80::opcode_e8()    // RET  PE
{
    if( F & Parity ) {
        retFromSub();
        cycles_ += 2;
    }
}

void Z80::opcode_e9()    // JP   (HL)
{
    PC = HL();
}

void Z80::opcode_ea()    // JP   PE,nn
{
    if( F & Parity )
        PC = fetchWord();
    else
        PC += 2;
}

void Z80::opcode_eb()    // EX   DE,HL
{
    unsigned char x;

    x = D; D = H; H = x;
    x = E; E = L; L = x;
}

void Z80::opcode_ec()    // CALL PE,nn
{
    if( F & Parity ) {
        callSub( fetchWord() );
        cycles_ += 2;
    }
    else {
        PC += 2;
    }
}

void Z80::opcode_ed()    // [Prefix]
{
    unsigned op = fetchByte();

    if( OpInfoED_[ op ].handler ) {
        (this->*(OpInfoED_[ op ].handler))();
        cycles_ += OpInfoED_[ op ].cycles;
    }
    else {
        cycles_ += OpInfo_[ 0 ].cycles; // NOP
    }
}

void Z80::opcode_ee()    // XOR  n
{
    A ^= fetchByte();
    setFlags35PSZ000();
}

void Z80::opcode_ef()    // RST  28H
{
    callSub( 0x28 );
}

void Z80::opcode_f0()    // RET  P
{
    if( ! (F & Sign) ) {
        retFromSub();
        cycles_ += 2;
    }
}

void Z80::opcode_f1()    // POP  AF
{
    F = env_.readByte( SP++ );
    A = env_.readByte( SP++ );
}

void Z80::opcode_f2()    // JP   P,nn
{
    if( ! (F & Sign) )
        PC = fetchWord();
    else
        PC += 2;
}

void Z80::opcode_f3()    // DI
{
    iflags_ &= ~(IFF1 | IFF2);
}

void Z80::opcode_f4()    // CALL P,nn
{
    if( ! (F & Sign) ) {
        callSub( fetchWord() );
        cycles_ += 2;
    }
    else {
        PC += 2;
    }
}

void Z80::opcode_f5()    // PUSH AF
{
    env_.writeByte( --SP, A );
    env_.writeByte( --SP, F );
}

void Z80::opcode_f6()    // OR   n
{
    A |= fetchByte();
    setFlags35PSZ000();
}

void Z80::opcode_f7()    // RST  30H
{
    callSub( 0x30 );
}

void Z80::opcode_f8()    // RET  M
{
    if( F & Sign ) {
        retFromSub();
        cycles_ += 2;
    }
}

void Z80::opcode_f9()    // LD   SP,HL
{
    SP = HL();
}

void Z80::opcode_fa()    // JP   M,nn
{
    if( F & Sign )
        PC = fetchWord();
    else
        PC += 2;
}

void Z80::opcode_fb()    // EI
{
    iflags_ |= IFF1 | IFF2;
}

void Z80::opcode_fc()    // CALL M,nn
{
    if( F & Sign ) {
        callSub( fetchWord() );
        cycles_ += 2;
    }
    else {
        PC += 2;
    }
}

void Z80::opcode_fd()    // [IY Prefix]
{
    do_opcode_xy( OpInfoFD_ );
    IY &= 0xFFFF;
}


void Z80::opcode_fe()    // CP   n
{
    subByte( fetchByte(), 0 );
}

void Z80::opcode_ff()    // RST  38H
{
    callSub( 0x38 );
}

void Z80::do_opcode_xy( OpcodeInfo * info )
{
    unsigned op = fetchByte();

    if( (op == 0xDD) || (op == 0xFD) ) {
        // Exit now, to avoid possible infinite loops
        PC--;
        cycles_ += OpInfo_[ 0 ].cycles; // NOP
    }
    else if( op == 0xED ) {
        // IX or IY prefix is ignored for this opcode
        opcode_ed();
    }
    else {
        // Handle IX or IY prefix if possible
        if( info[ op ].handler ) {
            // Extended opcode is valid
            cycles_ += info[ op ].cycles;
            (this->*(info[ op ].handler))();
        }
        else {
            // Extended opcode not valid, fall back to standard opcode
            cycles_ += OpInfo_[ op ].cycles;
            (this->*(OpInfo_[ op ].handler))();
        }
    }
}
