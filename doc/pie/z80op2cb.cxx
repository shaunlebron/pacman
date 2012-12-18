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

Z80::OpcodeInfo Z80::OpInfoCB_[256] = {
    { &Z80::opcode_cb_00,  8 }, // RLC B
    { &Z80::opcode_cb_01,  8 }, // RLC C
    { &Z80::opcode_cb_02,  8 }, // RLC D
    { &Z80::opcode_cb_03,  8 }, // RLC E
    { &Z80::opcode_cb_04,  8 }, // RLC H
    { &Z80::opcode_cb_05,  8 }, // RLC L
    { &Z80::opcode_cb_06, 15 }, // RLC (HL)
    { &Z80::opcode_cb_07,  8 }, // RLC A
    { &Z80::opcode_cb_08,  8 }, // RRC B
    { &Z80::opcode_cb_09,  8 }, // RRC C
    { &Z80::opcode_cb_0a,  8 }, // RRC D
    { &Z80::opcode_cb_0b,  8 }, // RRC E
    { &Z80::opcode_cb_0c,  8 }, // RRC H
    { &Z80::opcode_cb_0d,  8 }, // RRC L
    { &Z80::opcode_cb_0e, 15 }, // RRC (HL)
    { &Z80::opcode_cb_0f,  8 }, // RRC A
    { &Z80::opcode_cb_10,  8 }, // RL B
    { &Z80::opcode_cb_11,  8 }, // RL C
    { &Z80::opcode_cb_12,  8 }, // RL D
    { &Z80::opcode_cb_13,  8 }, // RL E
    { &Z80::opcode_cb_14,  8 }, // RL H
    { &Z80::opcode_cb_15,  8 }, // RL L
    { &Z80::opcode_cb_16, 15 }, // RL (HL)
    { &Z80::opcode_cb_17,  8 }, // RL A
    { &Z80::opcode_cb_18,  8 }, // RR B
    { &Z80::opcode_cb_19,  8 }, // RR C
    { &Z80::opcode_cb_1a,  8 }, // RR D
    { &Z80::opcode_cb_1b,  8 }, // RR E
    { &Z80::opcode_cb_1c,  8 }, // RR H
    { &Z80::opcode_cb_1d,  8 }, // RR L
    { &Z80::opcode_cb_1e, 15 }, // RR (HL)
    { &Z80::opcode_cb_1f,  8 }, // RR A
    { &Z80::opcode_cb_20,  8 }, // SLA B
    { &Z80::opcode_cb_21,  8 }, // SLA C
    { &Z80::opcode_cb_22,  8 }, // SLA D
    { &Z80::opcode_cb_23,  8 }, // SLA E
    { &Z80::opcode_cb_24,  8 }, // SLA H
    { &Z80::opcode_cb_25,  8 }, // SLA L
    { &Z80::opcode_cb_26, 15 }, // SLA (HL)
    { &Z80::opcode_cb_27,  8 }, // SLA A
    { &Z80::opcode_cb_28,  8 }, // SRA B
    { &Z80::opcode_cb_29,  8 }, // SRA C
    { &Z80::opcode_cb_2a,  8 }, // SRA D
    { &Z80::opcode_cb_2b,  8 }, // SRA E
    { &Z80::opcode_cb_2c,  8 }, // SRA H
    { &Z80::opcode_cb_2d,  8 }, // SRA L
    { &Z80::opcode_cb_2e, 15 }, // SRA (HL)
    { &Z80::opcode_cb_2f,  8 }, // SRA A
    { &Z80::opcode_cb_30,  8 }, // SLL B 
    { &Z80::opcode_cb_31,  8 }, // SLL C 
    { &Z80::opcode_cb_32,  8 }, // SLL D 
    { &Z80::opcode_cb_33,  8 }, // SLL E 
    { &Z80::opcode_cb_34,  8 }, // SLL H 
    { &Z80::opcode_cb_35,  8 }, // SLL L 
    { &Z80::opcode_cb_36, 15 }, // SLL (HL)
    { &Z80::opcode_cb_37,  8 }, // SLL A
    { &Z80::opcode_cb_38,  8 }, // SRL B
    { &Z80::opcode_cb_39,  8 }, // SRL C
    { &Z80::opcode_cb_3a,  8 }, // SRL D
    { &Z80::opcode_cb_3b,  8 }, // SRL E
    { &Z80::opcode_cb_3c,  8 }, // SRL H
    { &Z80::opcode_cb_3d,  8 }, // SRL L
    { &Z80::opcode_cb_3e, 15 }, // SRL (HL)
    { &Z80::opcode_cb_3f,  8 }, // SRL A
    { &Z80::opcode_cb_40,  8 }, // BIT 0, B
    { &Z80::opcode_cb_41,  8 }, // BIT 0, C
    { &Z80::opcode_cb_42,  8 }, // BIT 0, D
    { &Z80::opcode_cb_43,  8 }, // BIT 0, E
    { &Z80::opcode_cb_44,  8 }, // BIT 0, H
    { &Z80::opcode_cb_45,  8 }, // BIT 0, L
    { &Z80::opcode_cb_46, 12 }, // BIT 0, (HL)
    { &Z80::opcode_cb_47,  8 }, // BIT 0, A
    { &Z80::opcode_cb_48,  8 }, // BIT 1, B
    { &Z80::opcode_cb_49,  8 }, // BIT 1, C
    { &Z80::opcode_cb_4a,  8 }, // BIT 1, D
    { &Z80::opcode_cb_4b,  8 }, // BIT 1, E
    { &Z80::opcode_cb_4c,  8 }, // BIT 1, H
    { &Z80::opcode_cb_4d,  8 }, // BIT 1, L
    { &Z80::opcode_cb_4e, 12 }, // BIT 1, (HL)
    { &Z80::opcode_cb_4f,  8 }, // BIT 1, A
    { &Z80::opcode_cb_50,  8 }, // BIT 2, B
    { &Z80::opcode_cb_51,  8 }, // BIT 2, C
    { &Z80::opcode_cb_52,  8 }, // BIT 2, D
    { &Z80::opcode_cb_53,  8 }, // BIT 2, E
    { &Z80::opcode_cb_54,  8 }, // BIT 2, H
    { &Z80::opcode_cb_55,  8 }, // BIT 2, L
    { &Z80::opcode_cb_56, 12 }, // BIT 2, (HL)
    { &Z80::opcode_cb_57,  8 }, // BIT 2, A
    { &Z80::opcode_cb_58,  8 }, // BIT 3, B
    { &Z80::opcode_cb_59,  8 }, // BIT 3, C
    { &Z80::opcode_cb_5a,  8 }, // BIT 3, D
    { &Z80::opcode_cb_5b,  8 }, // BIT 3, E
    { &Z80::opcode_cb_5c,  8 }, // BIT 3, H
    { &Z80::opcode_cb_5d,  8 }, // BIT 3, L
    { &Z80::opcode_cb_5e, 12 }, // BIT 3, (HL)
    { &Z80::opcode_cb_5f,  8 }, // BIT 3, A
    { &Z80::opcode_cb_60,  8 }, // BIT 4, B
    { &Z80::opcode_cb_61,  8 }, // BIT 4, C
    { &Z80::opcode_cb_62,  8 }, // BIT 4, D
    { &Z80::opcode_cb_63,  8 }, // BIT 4, E
    { &Z80::opcode_cb_64,  8 }, // BIT 4, H
    { &Z80::opcode_cb_65,  8 }, // BIT 4, L
    { &Z80::opcode_cb_66, 12 }, // BIT 4, (HL)
    { &Z80::opcode_cb_67,  8 }, // BIT 4, A
    { &Z80::opcode_cb_68,  8 }, // BIT 5, B
    { &Z80::opcode_cb_69,  8 }, // BIT 5, C
    { &Z80::opcode_cb_6a,  8 }, // BIT 5, D
    { &Z80::opcode_cb_6b,  8 }, // BIT 5, E
    { &Z80::opcode_cb_6c,  8 }, // BIT 5, H
    { &Z80::opcode_cb_6d,  8 }, // BIT 5, L
    { &Z80::opcode_cb_6e, 12 }, // BIT 5, (HL)
    { &Z80::opcode_cb_6f,  8 }, // BIT 5, A
    { &Z80::opcode_cb_70,  8 }, // BIT 6, B
    { &Z80::opcode_cb_71,  8 }, // BIT 6, C
    { &Z80::opcode_cb_72,  8 }, // BIT 6, D
    { &Z80::opcode_cb_73,  8 }, // BIT 6, E
    { &Z80::opcode_cb_74,  8 }, // BIT 6, H
    { &Z80::opcode_cb_75,  8 }, // BIT 6, L
    { &Z80::opcode_cb_76, 12 }, // BIT 6, (HL)
    { &Z80::opcode_cb_77,  8 }, // BIT 6, A
    { &Z80::opcode_cb_78,  8 }, // BIT 7, B
    { &Z80::opcode_cb_79,  8 }, // BIT 7, C
    { &Z80::opcode_cb_7a,  8 }, // BIT 7, D
    { &Z80::opcode_cb_7b,  8 }, // BIT 7, E
    { &Z80::opcode_cb_7c,  8 }, // BIT 7, H
    { &Z80::opcode_cb_7d,  8 }, // BIT 7, L
    { &Z80::opcode_cb_7e, 12 }, // BIT 7, (HL)
    { &Z80::opcode_cb_7f,  8 }, // BIT 7, A
    { &Z80::opcode_cb_80,  8 }, // RES 0, B
    { &Z80::opcode_cb_81,  8 }, // RES 0, C
    { &Z80::opcode_cb_82,  8 }, // RES 0, D
    { &Z80::opcode_cb_83,  8 }, // RES 0, E
    { &Z80::opcode_cb_84,  8 }, // RES 0, H
    { &Z80::opcode_cb_85,  8 }, // RES 0, L
    { &Z80::opcode_cb_86, 15 }, // RES 0, (HL)
    { &Z80::opcode_cb_87,  8 }, // RES 0, A
    { &Z80::opcode_cb_88,  8 }, // RES 1, B
    { &Z80::opcode_cb_89,  8 }, // RES 1, C
    { &Z80::opcode_cb_8a,  8 }, // RES 1, D
    { &Z80::opcode_cb_8b,  8 }, // RES 1, E
    { &Z80::opcode_cb_8c,  8 }, // RES 1, H
    { &Z80::opcode_cb_8d,  8 }, // RES 1, L
    { &Z80::opcode_cb_8e, 15 }, // RES 1, (HL)
    { &Z80::opcode_cb_8f,  8 }, // RES 1, A
    { &Z80::opcode_cb_90,  8 }, // RES 2, B
    { &Z80::opcode_cb_91,  8 }, // RES 2, C
    { &Z80::opcode_cb_92,  8 }, // RES 2, D
    { &Z80::opcode_cb_93,  8 }, // RES 2, E
    { &Z80::opcode_cb_94,  8 }, // RES 2, H
    { &Z80::opcode_cb_95,  8 }, // RES 2, L
    { &Z80::opcode_cb_96, 15 }, // RES 2, (HL)
    { &Z80::opcode_cb_97,  8 }, // RES 2, A
    { &Z80::opcode_cb_98,  8 }, // RES 3, B
    { &Z80::opcode_cb_99,  8 }, // RES 3, C
    { &Z80::opcode_cb_9a,  8 }, // RES 3, D
    { &Z80::opcode_cb_9b,  8 }, // RES 3, E
    { &Z80::opcode_cb_9c,  8 }, // RES 3, H
    { &Z80::opcode_cb_9d,  8 }, // RES 3, L
    { &Z80::opcode_cb_9e, 15 }, // RES 3, (HL)
    { &Z80::opcode_cb_9f,  8 }, // RES 3, A
    { &Z80::opcode_cb_a0,  8 }, // RES 4, B
    { &Z80::opcode_cb_a1,  8 }, // RES 4, C
    { &Z80::opcode_cb_a2,  8 }, // RES 4, D
    { &Z80::opcode_cb_a3,  8 }, // RES 4, E
    { &Z80::opcode_cb_a4,  8 }, // RES 4, H
    { &Z80::opcode_cb_a5,  8 }, // RES 4, L
    { &Z80::opcode_cb_a6, 15 }, // RES 4, (HL)
    { &Z80::opcode_cb_a7,  8 }, // RES 4, A
    { &Z80::opcode_cb_a8,  8 }, // RES 5, B
    { &Z80::opcode_cb_a9,  8 }, // RES 5, C
    { &Z80::opcode_cb_aa,  8 }, // RES 5, D
    { &Z80::opcode_cb_ab,  8 }, // RES 5, E
    { &Z80::opcode_cb_ac,  8 }, // RES 5, H
    { &Z80::opcode_cb_ad,  8 }, // RES 5, L
    { &Z80::opcode_cb_ae, 15 }, // RES 5, (HL)
    { &Z80::opcode_cb_af,  8 }, // RES 5, A
    { &Z80::opcode_cb_b0,  8 }, // RES 6, B
    { &Z80::opcode_cb_b1,  8 }, // RES 6, C
    { &Z80::opcode_cb_b2,  8 }, // RES 6, D
    { &Z80::opcode_cb_b3,  8 }, // RES 6, E
    { &Z80::opcode_cb_b4,  8 }, // RES 6, H
    { &Z80::opcode_cb_b5,  8 }, // RES 6, L
    { &Z80::opcode_cb_b6, 15 }, // RES 6, (HL)
    { &Z80::opcode_cb_b7,  8 }, // RES 6, A
    { &Z80::opcode_cb_b8,  8 }, // RES 7, B
    { &Z80::opcode_cb_b9,  8 }, // RES 7, C
    { &Z80::opcode_cb_ba,  8 }, // RES 7, D
    { &Z80::opcode_cb_bb,  8 }, // RES 7, E
    { &Z80::opcode_cb_bc,  8 }, // RES 7, H
    { &Z80::opcode_cb_bd,  8 }, // RES 7, L
    { &Z80::opcode_cb_be, 15 }, // RES 7, (HL)
    { &Z80::opcode_cb_bf,  8 }, // RES 7, A
    { &Z80::opcode_cb_c0,  8 }, // SET 0, B
    { &Z80::opcode_cb_c1,  8 }, // SET 0, C
    { &Z80::opcode_cb_c2,  8 }, // SET 0, D
    { &Z80::opcode_cb_c3,  8 }, // SET 0, E
    { &Z80::opcode_cb_c4,  8 }, // SET 0, H
    { &Z80::opcode_cb_c5,  8 }, // SET 0, L
    { &Z80::opcode_cb_c6, 15 }, // SET 0, (HL)
    { &Z80::opcode_cb_c7,  8 }, // SET 0, A
    { &Z80::opcode_cb_c8,  8 }, // SET 1, B
    { &Z80::opcode_cb_c9,  8 }, // SET 1, C
    { &Z80::opcode_cb_ca,  8 }, // SET 1, D
    { &Z80::opcode_cb_cb,  8 }, // SET 1, E
    { &Z80::opcode_cb_cc,  8 }, // SET 1, H
    { &Z80::opcode_cb_cd,  8 }, // SET 1, L
    { &Z80::opcode_cb_ce, 15 }, // SET 1, (HL)
    { &Z80::opcode_cb_cf,  8 }, // SET 1, A
    { &Z80::opcode_cb_d0,  8 }, // SET 2, B
    { &Z80::opcode_cb_d1,  8 }, // SET 2, C
    { &Z80::opcode_cb_d2,  8 }, // SET 2, D
    { &Z80::opcode_cb_d3,  8 }, // SET 2, E
    { &Z80::opcode_cb_d4,  8 }, // SET 2, H
    { &Z80::opcode_cb_d5,  8 }, // SET 2, L
    { &Z80::opcode_cb_d6, 15 }, // SET 2, (HL)
    { &Z80::opcode_cb_d7,  8 }, // SET 2, A
    { &Z80::opcode_cb_d8,  8 }, // SET 3, B
    { &Z80::opcode_cb_d9,  8 }, // SET 3, C
    { &Z80::opcode_cb_da,  8 }, // SET 3, D
    { &Z80::opcode_cb_db,  8 }, // SET 3, E
    { &Z80::opcode_cb_dc,  8 }, // SET 3, H
    { &Z80::opcode_cb_dd,  8 }, // SET 3, L
    { &Z80::opcode_cb_de, 15 }, // SET 3, (HL)
    { &Z80::opcode_cb_df,  8 }, // SET 3, A
    { &Z80::opcode_cb_e0,  8 }, // SET 4, B
    { &Z80::opcode_cb_e1,  8 }, // SET 4, C
    { &Z80::opcode_cb_e2,  8 }, // SET 4, D
    { &Z80::opcode_cb_e3,  8 }, // SET 4, E
    { &Z80::opcode_cb_e4,  8 }, // SET 4, H
    { &Z80::opcode_cb_e5,  8 }, // SET 4, L
    { &Z80::opcode_cb_e6, 15 }, // SET 4, (HL)
    { &Z80::opcode_cb_e7,  8 }, // SET 4, A
    { &Z80::opcode_cb_e8,  8 }, // SET 5, B
    { &Z80::opcode_cb_e9,  8 }, // SET 5, C
    { &Z80::opcode_cb_ea,  8 }, // SET 5, D
    { &Z80::opcode_cb_eb,  8 }, // SET 5, E
    { &Z80::opcode_cb_ec,  8 }, // SET 5, H
    { &Z80::opcode_cb_ed,  8 }, // SET 5, L
    { &Z80::opcode_cb_ee, 15 }, // SET 5, (HL)
    { &Z80::opcode_cb_ef,  8 }, // SET 5, A
    { &Z80::opcode_cb_f0,  8 }, // SET 6, B
    { &Z80::opcode_cb_f1,  8 }, // SET 6, C
    { &Z80::opcode_cb_f2,  8 }, // SET 6, D
    { &Z80::opcode_cb_f3,  8 }, // SET 6, E
    { &Z80::opcode_cb_f4,  8 }, // SET 6, H
    { &Z80::opcode_cb_f5,  8 }, // SET 6, L
    { &Z80::opcode_cb_f6, 15 }, // SET 6, (HL)
    { &Z80::opcode_cb_f7,  8 }, // SET 6, A
    { &Z80::opcode_cb_f8,  8 }, // SET 7, B
    { &Z80::opcode_cb_f9,  8 }, // SET 7, C
    { &Z80::opcode_cb_fa,  8 }, // SET 7, D
    { &Z80::opcode_cb_fb,  8 }, // SET 7, E
    { &Z80::opcode_cb_fc,  8 }, // SET 7, H
    { &Z80::opcode_cb_fd,  8 }, // SET 7, L
    { &Z80::opcode_cb_fe, 15 }, // SET 7, (HL)
    { &Z80::opcode_cb_ff,  8 }  // SET 7, A
};
    
void Z80::opcode_cb_00()    // RLC B
{
    B = rotateLeftCarry( B );    
}

void Z80::opcode_cb_01()    // RLC C
{
    C = rotateLeftCarry( C );    
}

void Z80::opcode_cb_02()    // RLC D
{
    D = rotateLeftCarry( D );    
}

void Z80::opcode_cb_03()    // RLC E
{
    E = rotateLeftCarry( E );    
}

void Z80::opcode_cb_04()    // RLC H
{
    H = rotateLeftCarry( H );    
}

void Z80::opcode_cb_05()    // RLC L
{
    L = rotateLeftCarry( L );
}

void Z80::opcode_cb_06()    // RLC (HL)
{
    env_.writeByte( HL(), rotateLeftCarry( env_.readByte( HL() ) ) );
}

void Z80::opcode_cb_07()    // RLC A
{
    A = rotateLeftCarry( A );
}

void Z80::opcode_cb_08()    // RRC B
{
    B = rotateRightCarry( B );
}

void Z80::opcode_cb_09()    // RRC C
{
    C = rotateLeftCarry( C );
}

void Z80::opcode_cb_0a()    // RRC D
{
    D = rotateLeftCarry( D );
}

void Z80::opcode_cb_0b()    // RRC E
{
    E = rotateLeftCarry( E );
}

void Z80::opcode_cb_0c()    // RRC H
{
    H = rotateLeftCarry( H );
}

void Z80::opcode_cb_0d()    // RRC L
{
    L = rotateLeftCarry( L );
}

void Z80::opcode_cb_0e()    // RRC (HL)
{
    env_.writeByte( HL(), rotateRightCarry( env_.readByte( HL() ) ) );    
}

void Z80::opcode_cb_0f()    // RRC A
{
    A = rotateLeftCarry( A );
}

void Z80::opcode_cb_10()    // RL B
{
    B = rotateLeft( B );    
}

void Z80::opcode_cb_11()    // RL C
{
    C = rotateLeft( C );    
}

void Z80::opcode_cb_12()    // RL D
{
    D = rotateLeft( D );    
}

void Z80::opcode_cb_13()    // RL E
{
    E = rotateLeft( E );
}

void Z80::opcode_cb_14()    // RL H
{
    H = rotateLeft( H );    
}

void Z80::opcode_cb_15()    // RL L
{
    L = rotateLeft( L );    
}

void Z80::opcode_cb_16()    // RL (HL)
{
    env_.writeByte( HL(), rotateLeft( env_.readByte( HL() ) ) );    
}

void Z80::opcode_cb_17()    // RL A
{
    A = rotateLeft( A ); 
}

void Z80::opcode_cb_18()    // RR B
{
    B = rotateRight( B ); 
}

void Z80::opcode_cb_19()    // RR C
{
    C = rotateRight( C ); 
}

void Z80::opcode_cb_1a()    // RR D
{
    D = rotateRight( D ); 
}

void Z80::opcode_cb_1b()    // RR E
{
    E = rotateRight( E ); 
}

void Z80::opcode_cb_1c()    // RR H
{
    H = rotateRight( H ); 
}

void Z80::opcode_cb_1d()    // RR L
{
    L = rotateRight( L ); 
}

void Z80::opcode_cb_1e()    // RR (HL)
{
    env_.writeByte( HL(), rotateRight( env_.readByte( HL() ) ) );    
}

void Z80::opcode_cb_1f()    // RR A
{
    A = rotateRight( A ); 
}

void Z80::opcode_cb_20()    // SLA B
{
    B = shiftLeft( B );
}

void Z80::opcode_cb_21()    // SLA C
{
    C = shiftLeft( C );
}

void Z80::opcode_cb_22()    // SLA D
{
    D = shiftLeft( D );
}

void Z80::opcode_cb_23()    // SLA E
{
    E = shiftLeft( E );
}

void Z80::opcode_cb_24()    // SLA H
{
    H = shiftLeft( H );
}

void Z80::opcode_cb_25()    // SLA L
{
    L = shiftLeft( L );
}

void Z80::opcode_cb_26()    // SLA (HL)
{
    env_.writeByte( HL(), shiftLeft( env_.readByte( HL() ) ) );
}

void Z80::opcode_cb_27()    // SLA A
{
    A = shiftLeft( A );
}

void Z80::opcode_cb_28()    // SRA B
{
    B = shiftRightArith( B );
}

void Z80::opcode_cb_29()    // SRA C
{
    C = shiftRightArith( C );
}

void Z80::opcode_cb_2a()    // SRA D
{
    D = shiftRightArith( D );
}

void Z80::opcode_cb_2b()    // SRA E
{
    E = shiftRightArith( E );
}

void Z80::opcode_cb_2c()    // SRA H
{
    H = shiftRightArith( H );
}

void Z80::opcode_cb_2d()    // SRA L
{
    L = shiftRightArith( L );
}

void Z80::opcode_cb_2e()    // SRA (HL)
{
    env_.writeByte( HL(), shiftRightArith( env_.readByte( HL() ) ) );
}

void Z80::opcode_cb_2f()    // SRA A
{
    A = shiftRightArith( A );
}

void Z80::opcode_cb_30()    // SLL B
{
    B = shiftLeft( B ) | 0x01;
}

void Z80::opcode_cb_31()    // SLL C
{
    C = shiftLeft( C ) | 0x01;
}

void Z80::opcode_cb_32()    // SLL D
{
    D = shiftLeft( D ) | 0x01;
}

void Z80::opcode_cb_33()    // SLL E
{
    E = shiftLeft( E ) | 0x01;
}

void Z80::opcode_cb_34()    // SLL H
{
    H = shiftLeft( H ) | 0x01;
}

void Z80::opcode_cb_35()    // SLL L
{
    L = shiftLeft( L ) | 0x01;
}

void Z80::opcode_cb_36()    // SLL (HL)
{
    env_.writeByte( HL(), shiftLeft( env_.readByte( HL() ) ) | 0x01 );
}

void Z80::opcode_cb_37()    // SLL A
{
    A = shiftLeft( A ) | 0x01;
}

void Z80::opcode_cb_38()    // SRL B
{
    B = shiftRightLogical( B );
}

void Z80::opcode_cb_39()    // SRL C
{
    C = shiftRightLogical( C );
}

void Z80::opcode_cb_3a()    // SRL D
{
    D = shiftRightLogical( D );
}

void Z80::opcode_cb_3b()    // SRL E
{
    E = shiftRightLogical( E );
}

void Z80::opcode_cb_3c()    // SRL H
{
    H = shiftRightLogical( H );
}

void Z80::opcode_cb_3d()    // SRL L
{
    L = shiftRightLogical( L );
}

void Z80::opcode_cb_3e()    // SRL (HL)
{
    env_.writeByte( HL(), shiftRightLogical( env_.readByte( HL() ) ) );
}

void Z80::opcode_cb_3f()    // SRL A
{
    A = shiftRightLogical( A );
}

void Z80::opcode_cb_40()    // BIT 0, B
{
    testBit( 0, B );
}

void Z80::opcode_cb_41()    // BIT 0, C
{
    testBit( 0, C );
}

void Z80::opcode_cb_42()    // BIT 0, D
{
    testBit( 0, D );
}

void Z80::opcode_cb_43()    // BIT 0, E
{
    testBit( 0, E );
}

void Z80::opcode_cb_44()    // BIT 0, H
{
    testBit( 0, H );
}

void Z80::opcode_cb_45()    // BIT 0, L
{
    testBit( 0, L );
}

void Z80::opcode_cb_46()    // BIT 0, (HL)
{
    testBit( 0, env_.readByte( HL() ) );
}

void Z80::opcode_cb_47()    // BIT 0, A
{
    testBit( 0, A );
}

void Z80::opcode_cb_48()    // BIT 1, B
{
    testBit( 1, B );
}

void Z80::opcode_cb_49()    // BIT 1, C
{
    testBit( 1, C );
}

void Z80::opcode_cb_4a()    // BIT 1, D
{
    testBit( 1, D );
}

void Z80::opcode_cb_4b()    // BIT 1, E
{
    testBit( 1, E );
}

void Z80::opcode_cb_4c()    // BIT 1, H
{
    testBit( 1, H );
}

void Z80::opcode_cb_4d()    // BIT 1, L
{
    testBit( 1, L );
}

void Z80::opcode_cb_4e()    // BIT 1, (HL)
{
    testBit( 1, env_.readByte( HL() ) );
}

void Z80::opcode_cb_4f()    // BIT 1, A
{
    testBit( 1, A );
}

void Z80::opcode_cb_50()    // BIT 2, B
{
    testBit( 2, B );
}

void Z80::opcode_cb_51()    // BIT 2, C
{
    testBit( 2, C );
}

void Z80::opcode_cb_52()    // BIT 2, D
{
    testBit( 2, D );
}

void Z80::opcode_cb_53()    // BIT 2, E
{
    testBit( 2, E );
}

void Z80::opcode_cb_54()    // BIT 2, H
{
    testBit( 2, H );
}

void Z80::opcode_cb_55()    // BIT 2, L
{
    testBit( 2, L );
}

void Z80::opcode_cb_56()    // BIT 2, (HL)
{
    testBit( 2, env_.readByte( HL() ) );
}

void Z80::opcode_cb_57()    // BIT 2, A
{
    testBit( 2, A );
}

void Z80::opcode_cb_58()    // BIT 3, B
{
    testBit( 3, B );
}

void Z80::opcode_cb_59()    // BIT 3, C
{
    testBit( 3, C );
}

void Z80::opcode_cb_5a()    // BIT 3, D
{
    testBit( 3, D );
}

void Z80::opcode_cb_5b()    // BIT 3, E
{
    testBit( 3, E );
}

void Z80::opcode_cb_5c()    // BIT 3, H
{
    testBit( 3, H );
}

void Z80::opcode_cb_5d()    // BIT 3, L
{
    testBit( 3, L );
}

void Z80::opcode_cb_5e()    // BIT 3, (HL)
{
    testBit( 3, env_.readByte( HL() ) );
}

void Z80::opcode_cb_5f()    // BIT 3, A
{
    testBit( 3, A );
}

void Z80::opcode_cb_60()    // BIT 4, B
{
    testBit( 4, B );
}

void Z80::opcode_cb_61()    // BIT 4, C
{
    testBit( 4, C );
}

void Z80::opcode_cb_62()    // BIT 4, D
{
    testBit( 4, D );
}

void Z80::opcode_cb_63()    // BIT 4, E
{
    testBit( 4, E );
}

void Z80::opcode_cb_64()    // BIT 4, H
{
    testBit( 4, H );
}

void Z80::opcode_cb_65()    // BIT 4, L
{
    testBit( 4, L );
}

void Z80::opcode_cb_66()    // BIT 4, (HL)
{
    testBit( 4, env_.readByte( HL() ) );
}

void Z80::opcode_cb_67()    // BIT 4, A
{
    testBit( 4, A );
}

void Z80::opcode_cb_68()    // BIT 5, B
{
    testBit( 5, B );
}

void Z80::opcode_cb_69()    // BIT 5, C
{
    testBit( 5, C );
}

void Z80::opcode_cb_6a()    // BIT 5, D
{
    testBit( 5, D );
}

void Z80::opcode_cb_6b()    // BIT 5, E
{
    testBit( 5, E );
}

void Z80::opcode_cb_6c()    // BIT 5, H
{
    testBit( 5, H );
}

void Z80::opcode_cb_6d()    // BIT 5, L
{
    testBit( 5, L );
}

void Z80::opcode_cb_6e()    // BIT 5, (HL)
{
    testBit( 5, env_.readByte( HL() ) );
}

void Z80::opcode_cb_6f()    // BIT 5, A
{
    testBit( 5, A );
}

void Z80::opcode_cb_70()    // BIT 6, B
{
    testBit( 6, B );
}

void Z80::opcode_cb_71()    // BIT 6, C
{
    testBit( 6, C );
}

void Z80::opcode_cb_72()    // BIT 6, D
{
    testBit( 6, D );
}

void Z80::opcode_cb_73()    // BIT 6, E
{
    testBit( 6, E );
}

void Z80::opcode_cb_74()    // BIT 6, H
{
    testBit( 6, H );
}

void Z80::opcode_cb_75()    // BIT 6, L
{
    testBit( 6, L );
}

void Z80::opcode_cb_76()    // BIT 6, (HL)
{
    testBit( 6, env_.readByte( HL() ) );
}

void Z80::opcode_cb_77()    // BIT 6, A
{
    testBit( 6, A );
}

void Z80::opcode_cb_78()    // BIT 7, B
{
    testBit( 7, B );
}

void Z80::opcode_cb_79()    // BIT 7, C
{
    testBit( 7, C );
}

void Z80::opcode_cb_7a()    // BIT 7, D
{
    testBit( 7, D );
}

void Z80::opcode_cb_7b()    // BIT 7, E
{
    testBit( 7, E );
}

void Z80::opcode_cb_7c()    // BIT 7, H
{
    testBit( 7, H );
}

void Z80::opcode_cb_7d()    // BIT 7, L
{
    testBit( 7, L );
}

void Z80::opcode_cb_7e()    // BIT 7, (HL)
{
    testBit( 7, env_.readByte( HL() ) );
}

void Z80::opcode_cb_7f()    // BIT 7, A
{
    testBit( 7, A );
}

void Z80::opcode_cb_80()    // RES 0, B
{
    B &= ~(unsigned char) (1 << 0);
}

void Z80::opcode_cb_81()    // RES 0, C
{
    C &= ~(unsigned char) (1 << 0);
}

void Z80::opcode_cb_82()    // RES 0, D
{
    D &= ~(unsigned char) (1 << 0);
}

void Z80::opcode_cb_83()    // RES 0, E
{
    E &= ~(unsigned char) (1 << 0);
}

void Z80::opcode_cb_84()    // RES 0, H
{
    H &= ~(unsigned char) (1 << 0);
}

void Z80::opcode_cb_85()    // RES 0, L
{
    L &= ~(unsigned char) (1 << 0);
}

void Z80::opcode_cb_86()    // RES 0, (HL)
{
    env_.writeByte( HL(), env_.readByte( HL() ) & (unsigned char) ~(unsigned char) (1 << 0) );
}

void Z80::opcode_cb_87()    // RES 0, A
{
    A &= ~(unsigned char) (1 << 0);
}

void Z80::opcode_cb_88()    // RES 1, B
{
    B &= ~(unsigned char) (1 << 1);
}

void Z80::opcode_cb_89()    // RES 1, C
{
    C &= ~(unsigned char) (1 << 1);
}

void Z80::opcode_cb_8a()    // RES 1, D
{
    D &= ~(unsigned char) (1 << 1);
}

void Z80::opcode_cb_8b()    // RES 1, E
{
    E &= ~(unsigned char) (1 << 1);
}

void Z80::opcode_cb_8c()    // RES 1, H
{
    H &= ~(unsigned char) (1 << 1);
}

void Z80::opcode_cb_8d()    // RES 1, L
{
    L &= ~(unsigned char) (1 << 1);
}

void Z80::opcode_cb_8e()    // RES 1, (HL)
{
    env_.writeByte( HL(), env_.readByte( HL() ) & (unsigned char) ~(unsigned char) (1 << 1) );
}

void Z80::opcode_cb_8f()    // RES 1, A
{
    A &= ~(unsigned char) (1 << 1);
}

void Z80::opcode_cb_90()    // RES 2, B
{
    B &= ~(unsigned char) (1 << 2);
}

void Z80::opcode_cb_91()    // RES 2, C
{
    C &= ~(unsigned char) (1 << 2);
}

void Z80::opcode_cb_92()    // RES 2, D
{
    D &= ~(unsigned char) (1 << 2);
}

void Z80::opcode_cb_93()    // RES 2, E
{
    E &= ~(unsigned char) (1 << 2);
}

void Z80::opcode_cb_94()    // RES 2, H
{
    H &= ~(unsigned char) (1 << 2);
}

void Z80::opcode_cb_95()    // RES 2, L
{
    L &= ~(unsigned char) (1 << 2);
}

void Z80::opcode_cb_96()    // RES 2, (HL)
{
    env_.writeByte( HL(), env_.readByte( HL() ) & (unsigned char) ~(unsigned char) (1 << 2) );
}

void Z80::opcode_cb_97()    // RES 2, A
{
    A &= ~(unsigned char) (1 << 2);
}

void Z80::opcode_cb_98()    // RES 3, B
{
    B &= ~(unsigned char) (1 << 3);
}

void Z80::opcode_cb_99()    // RES 3, C
{
    C &= ~(unsigned char) (1 << 3);
}

void Z80::opcode_cb_9a()    // RES 3, D
{
    D &= ~(unsigned char) (1 << 3);
}

void Z80::opcode_cb_9b()    // RES 3, E
{
    E &= ~(unsigned char) (1 << 3);
}

void Z80::opcode_cb_9c()    // RES 3, H
{
    H &= ~(unsigned char) (1 << 3);
}

void Z80::opcode_cb_9d()    // RES 3, L
{
    L &= ~(unsigned char) (1 << 3);
}

void Z80::opcode_cb_9e()    // RES 3, (HL)
{
    env_.writeByte( HL(), env_.readByte( HL() ) & (unsigned char) ~(unsigned char) (1 << 3) );
}

void Z80::opcode_cb_9f()    // RES 3, A
{
    A &= ~(unsigned char) (1 << 3);
}

void Z80::opcode_cb_a0()    // RES 4, B
{
    B &= ~(unsigned char) (1 << 4);
}

void Z80::opcode_cb_a1()    // RES 4, C
{
    C &= ~(unsigned char) (1 << 4);
}

void Z80::opcode_cb_a2()    // RES 4, D
{
    D &= ~(unsigned char) (1 << 4);
}

void Z80::opcode_cb_a3()    // RES 4, E
{
    E &= ~(unsigned char) (1 << 4);
}

void Z80::opcode_cb_a4()    // RES 4, H
{
    H &= ~(unsigned char) (1 << 4);
}

void Z80::opcode_cb_a5()    // RES 4, L
{
    L &= ~(unsigned char) (1 << 4);
}

void Z80::opcode_cb_a6()    // RES 4, (HL)
{
    env_.writeByte( HL(), env_.readByte( HL() ) & (unsigned char) ~(unsigned char) (1 << 4) );
}

void Z80::opcode_cb_a7()    // RES 4, A
{
    A &= ~(unsigned char) (1 << 4);
}

void Z80::opcode_cb_a8()    // RES 5, B
{
    B &= ~(unsigned char) (1 << 5);
}

void Z80::opcode_cb_a9()    // RES 5, C
{
    C &= ~(unsigned char) (1 << 5);
}

void Z80::opcode_cb_aa()    // RES 5, D
{
    D &= ~(unsigned char) (1 << 5);
}

void Z80::opcode_cb_ab()    // RES 5, E
{
    E &= ~(unsigned char) (1 << 5);
}

void Z80::opcode_cb_ac()    // RES 5, H
{
    H &= ~(unsigned char) (1 << 5);
}

void Z80::opcode_cb_ad()    // RES 5, L
{
    L &= ~(unsigned char) (1 << 5);
}

void Z80::opcode_cb_ae()    // RES 5, (HL)
{
    env_.writeByte( HL(), env_.readByte( HL() ) & (unsigned char) ~(unsigned char) (1 << 5) );
}

void Z80::opcode_cb_af()    // RES 5, A
{
    A &= ~(unsigned char) (1 << 5);
}

void Z80::opcode_cb_b0()    // RES 6, B
{
    B &= ~(unsigned char) (1 << 6);
}

void Z80::opcode_cb_b1()    // RES 6, C
{
    C &= ~(unsigned char) (1 << 6);
}

void Z80::opcode_cb_b2()    // RES 6, D
{
    D &= ~(unsigned char) (1 << 6);
}

void Z80::opcode_cb_b3()    // RES 6, E
{
    E &= ~(unsigned char) (1 << 6);
}

void Z80::opcode_cb_b4()    // RES 6, H
{
    H &= ~(unsigned char) (1 << 6);
}

void Z80::opcode_cb_b5()    // RES 6, L
{
    L &= ~(unsigned char) (1 << 6);
}

void Z80::opcode_cb_b6()    // RES 6, (HL)
{
    env_.writeByte( HL(), env_.readByte( HL() ) & (unsigned char) ~(unsigned char) (1 << 6) );
}

void Z80::opcode_cb_b7()    // RES 6, A
{
    A &= ~(unsigned char) (1 << 6);
}

void Z80::opcode_cb_b8()    // RES 7, B
{
    B &= ~(unsigned char) (1 << 7);
}

void Z80::opcode_cb_b9()    // RES 7, C
{
    C &= ~(unsigned char) (1 << 7);
}

void Z80::opcode_cb_ba()    // RES 7, D
{
    D &= ~(unsigned char) (1 << 7);
}

void Z80::opcode_cb_bb()    // RES 7, E
{
    E &= ~(unsigned char) (1 << 7);
}

void Z80::opcode_cb_bc()    // RES 7, H
{
    H &= ~(unsigned char) (1 << 7);
}

void Z80::opcode_cb_bd()    // RES 7, L
{
    L &= ~(unsigned char) (1 << 7);
}

void Z80::opcode_cb_be()    // RES 7, (HL)
{
    env_.writeByte( HL(), env_.readByte( HL() ) & (unsigned char) ~(unsigned char) (1 << 7) );
}

void Z80::opcode_cb_bf()    // RES 7, A
{
    A &= ~(unsigned char) (1 << 7);
}

void Z80::opcode_cb_c0()    // SET 0, B
{
    B |= (unsigned char) (1 << 0);
}

void Z80::opcode_cb_c1()    // SET 0, C
{
    C |= (unsigned char) (1 << 0);
}

void Z80::opcode_cb_c2()    // SET 0, D
{
    D |= (unsigned char) (1 << 0);
}

void Z80::opcode_cb_c3()    // SET 0, E
{
    E |= (unsigned char) (1 << 0);
}

void Z80::opcode_cb_c4()    // SET 0, H
{
    H |= (unsigned char) (1 << 0);
}

void Z80::opcode_cb_c5()    // SET 0, L
{
    L |= (unsigned char) (1 << 0);
}

void Z80::opcode_cb_c6()    // SET 0, (HL)
{
    env_.writeByte( HL(), env_.readByte( HL() ) | (unsigned char) (1 << 0) );
}

void Z80::opcode_cb_c7()    // SET 0, A
{
    A |= (unsigned char) (1 << 0);
}

void Z80::opcode_cb_c8()    // SET 1, B
{
    B |= (unsigned char) (1 << 1);
}

void Z80::opcode_cb_c9()    // SET 1, C
{
    C |= (unsigned char) (1 << 1);
}

void Z80::opcode_cb_ca()    // SET 1, D
{
    D |= (unsigned char) (1 << 1);
}

void Z80::opcode_cb_cb()    // SET 1, E
{
    E |= (unsigned char) (1 << 1);
}

void Z80::opcode_cb_cc()    // SET 1, H
{
    H |= (unsigned char) (1 << 1);
}

void Z80::opcode_cb_cd()    // SET 1, L
{
    L |= (unsigned char) (1 << 1);
}

void Z80::opcode_cb_ce()    // SET 1, (HL)
{
    env_.writeByte( HL(), env_.readByte( HL() ) | (unsigned char) (1 << 1) );
}

void Z80::opcode_cb_cf()    // SET 1, A
{
    A |= (unsigned char) (1 << 1);
}

void Z80::opcode_cb_d0()    // SET 2, B
{
    B |= (unsigned char) (1 << 2);
}

void Z80::opcode_cb_d1()    // SET 2, C
{
    C |= (unsigned char) (1 << 2);
}

void Z80::opcode_cb_d2()    // SET 2, D
{
    D |= (unsigned char) (1 << 2);
}

void Z80::opcode_cb_d3()    // SET 2, E
{
    E |= (unsigned char) (1 << 2);
}

void Z80::opcode_cb_d4()    // SET 2, H
{
    H |= (unsigned char) (1 << 2);
}

void Z80::opcode_cb_d5()    // SET 2, L
{
    L |= (unsigned char) (1 << 2);
}

void Z80::opcode_cb_d6()    // SET 2, (HL)
{
    env_.writeByte( HL(), env_.readByte( HL() ) | (unsigned char) (1 << 2) );
}

void Z80::opcode_cb_d7()    // SET 2, A
{
    A |= (unsigned char) (1 << 2);
}

void Z80::opcode_cb_d8()    // SET 3, B
{
    B |= (unsigned char) (1 << 3);
}

void Z80::opcode_cb_d9()    // SET 3, C
{
    C |= (unsigned char) (1 << 3);
}

void Z80::opcode_cb_da()    // SET 3, D
{
    D |= (unsigned char) (1 << 3);
}

void Z80::opcode_cb_db()    // SET 3, E
{
    E |= (unsigned char) (1 << 3);
}

void Z80::opcode_cb_dc()    // SET 3, H
{
    H |= (unsigned char) (1 << 3);
}

void Z80::opcode_cb_dd()    // SET 3, L
{
    L |= (unsigned char) (1 << 3);
}

void Z80::opcode_cb_de()    // SET 3, (HL)
{
    env_.writeByte( HL(), env_.readByte( HL() ) | (unsigned char) (1 << 3) );
}

void Z80::opcode_cb_df()    // SET 3, A
{
    A |= (unsigned char) (1 << 3);
}

void Z80::opcode_cb_e0()    // SET 4, B
{
    B |= (unsigned char) (1 << 4);
}

void Z80::opcode_cb_e1()    // SET 4, C
{
    C |= (unsigned char) (1 << 4);
}

void Z80::opcode_cb_e2()    // SET 4, D
{
    D |= (unsigned char) (1 << 4);
}

void Z80::opcode_cb_e3()    // SET 4, E
{
    E |= (unsigned char) (1 << 4);
}

void Z80::opcode_cb_e4()    // SET 4, H
{
    H |= (unsigned char) (1 << 4);
}

void Z80::opcode_cb_e5()    // SET 4, L
{
    L |= (unsigned char) (1 << 4);
}

void Z80::opcode_cb_e6()    // SET 4, (HL)
{
    env_.writeByte( HL(), env_.readByte( HL() ) | (unsigned char) (1 << 4) );
}

void Z80::opcode_cb_e7()    // SET 4, A
{
    A |= (unsigned char) (1 << 4);
}

void Z80::opcode_cb_e8()    // SET 5, B
{
    B |= (unsigned char) (1 << 5);
}

void Z80::opcode_cb_e9()    // SET 5, C
{
    C |= (unsigned char) (1 << 5);
}

void Z80::opcode_cb_ea()    // SET 5, D
{
    D |= (unsigned char) (1 << 5);
}

void Z80::opcode_cb_eb()    // SET 5, E
{
    E |= (unsigned char) (1 << 5);
}

void Z80::opcode_cb_ec()    // SET 5, H
{
    H |= (unsigned char) (1 << 5);
}

void Z80::opcode_cb_ed()    // SET 5, L
{
    L |= (unsigned char) (1 << 5);
}

void Z80::opcode_cb_ee()    // SET 5, (HL)
{
    env_.writeByte( HL(), env_.readByte( HL() ) | (unsigned char) (1 << 5) );
}

void Z80::opcode_cb_ef()    // SET 5, A
{
    A |= (unsigned char) (1 << 5);
}

void Z80::opcode_cb_f0()    // SET 6, B
{
    B |= (unsigned char) (1 << 6);
}

void Z80::opcode_cb_f1()    // SET 6, C
{
    C |= (unsigned char) (1 << 6);
}

void Z80::opcode_cb_f2()    // SET 6, D
{
    D |= (unsigned char) (1 << 6);
}

void Z80::opcode_cb_f3()    // SET 6, E
{
    E |= (unsigned char) (1 << 6);
}

void Z80::opcode_cb_f4()    // SET 6, H
{
    H |= (unsigned char) (1 << 6);
}

void Z80::opcode_cb_f5()    // SET 6, L
{
    L |= (unsigned char) (1 << 6);
}

void Z80::opcode_cb_f6()    // SET 6, (HL)
{
    env_.writeByte( HL(), env_.readByte( HL() ) | (unsigned char) (1 << 6) );
}

void Z80::opcode_cb_f7()    // SET 6, A
{
    A |= (unsigned char) (1 << 6);
}

void Z80::opcode_cb_f8()    // SET 7, B
{
    B |= (unsigned char) (1 << 7);
}

void Z80::opcode_cb_f9()    // SET 7, C
{
    C |= (unsigned char) (1 << 7);
}

void Z80::opcode_cb_fa()    // SET 7, D
{
    D |= (unsigned char) (1 << 7);
}

void Z80::opcode_cb_fb()    // SET 7, E
{
    E |= (unsigned char) (1 << 7);
}

void Z80::opcode_cb_fc()    // SET 7, H
{
    H |= (unsigned char) (1 << 7);
}

void Z80::opcode_cb_fd()    // SET 7, L
{
    L |= (unsigned char) (1 << 7);
}

void Z80::opcode_cb_fe()    // SET 7, (HL)
{
    env_.writeByte( HL(), env_.readByte( HL() ) | (unsigned char) (1 << 7) );
}

void Z80::opcode_cb_ff()    // SET 7, A
{
    A |= (unsigned char) (1 << 7);
}
