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

Z80::OpcodeInfoXY Z80::OpInfoXYCB_[256] = {
    { &Z80::opcode_xycb_00, 20 }, // LD B, RLC (IX + d)
    { &Z80::opcode_xycb_01, 20 }, // LD C, RLC (IX + d)
    { &Z80::opcode_xycb_02, 20 }, // LD D, RLC (IX + d)
    { &Z80::opcode_xycb_03, 20 }, // LD E, RLC (IX + d)
    { &Z80::opcode_xycb_04, 20 }, // LD H, RLC (IX + d)
    { &Z80::opcode_xycb_05, 20 }, // LD L, RLC (IX + d)
    { &Z80::opcode_xycb_06, 20 }, // RLC (IX + d)
    { &Z80::opcode_xycb_07, 20 }, // LD A, RLC (IX + d)
    { &Z80::opcode_xycb_08, 20 }, // LD B, RRC (IX + d)
    { &Z80::opcode_xycb_09, 20 }, // LD C, RRC (IX + d)
    { &Z80::opcode_xycb_0a, 20 }, // LD D, RRC (IX + d)
    { &Z80::opcode_xycb_0b, 20 }, // LD E, RRC (IX + d)
    { &Z80::opcode_xycb_0c, 20 }, // LD H, RRC (IX + d)
    { &Z80::opcode_xycb_0d, 20 }, // LD L, RRC (IX + d)
    { &Z80::opcode_xycb_0e, 20 }, // RRC (IX + d)
    { &Z80::opcode_xycb_0f, 20 }, // LD A, RRC (IX + d)
    { &Z80::opcode_xycb_10, 20 }, // LD B, RL (IX + d)
    { &Z80::opcode_xycb_11, 20 }, // LD C, RL (IX + d)
    { &Z80::opcode_xycb_12, 20 }, // LD D, RL (IX + d)
    { &Z80::opcode_xycb_13, 20 }, // LD E, RL (IX + d)
    { &Z80::opcode_xycb_14, 20 }, // LD H, RL (IX + d)
    { &Z80::opcode_xycb_15, 20 }, // LD L, RL (IX + d)
    { &Z80::opcode_xycb_16, 20 }, // RL (IX + d)
    { &Z80::opcode_xycb_17, 20 }, // LD A, RL (IX + d)
    { &Z80::opcode_xycb_18, 20 }, // LD B, RR (IX + d)
    { &Z80::opcode_xycb_19, 20 }, // LD C, RR (IX + d)
    { &Z80::opcode_xycb_1a, 20 }, // LD D, RR (IX + d)
    { &Z80::opcode_xycb_1b, 20 }, // LD E, RR (IX + d)
    { &Z80::opcode_xycb_1c, 20 }, // LD H, RR (IX + d)
    { &Z80::opcode_xycb_1d, 20 }, // LD L, RR (IX + d)
    { &Z80::opcode_xycb_1e, 20 }, // RR (IX + d)
    { &Z80::opcode_xycb_1f, 20 }, // LD A, RR (IX + d)
    { &Z80::opcode_xycb_20, 20 }, // LD B, SLA (IX + d)
    { &Z80::opcode_xycb_21, 20 }, // LD C, SLA (IX + d)
    { &Z80::opcode_xycb_22, 20 }, // LD D, SLA (IX + d)
    { &Z80::opcode_xycb_23, 20 }, // LD E, SLA (IX + d)
    { &Z80::opcode_xycb_24, 20 }, // LD H, SLA (IX + d)
    { &Z80::opcode_xycb_25, 20 }, // LD L, SLA (IX + d)
    { &Z80::opcode_xycb_26, 20 }, // SLA (IX + d)
    { &Z80::opcode_xycb_27, 20 }, // LD A, SLA (IX + d)
    { &Z80::opcode_xycb_28, 20 }, // LD B, SRA (IX + d)
    { &Z80::opcode_xycb_29, 20 }, // LD C, SRA (IX + d)
    { &Z80::opcode_xycb_2a, 20 }, // LD D, SRA (IX + d)
    { &Z80::opcode_xycb_2b, 20 }, // LD E, SRA (IX + d)
    { &Z80::opcode_xycb_2c, 20 }, // LD H, SRA (IX + d)
    { &Z80::opcode_xycb_2d, 20 }, // LD L, SRA (IX + d)
    { &Z80::opcode_xycb_2e, 20 }, // SRA (IX + d)
    { &Z80::opcode_xycb_2f, 20 }, // LD A, SRA (IX + d)
    { &Z80::opcode_xycb_30, 20 }, // LD B, SLL (IX + d)
    { &Z80::opcode_xycb_31, 20 }, // LD C, SLL (IX + d)
    { &Z80::opcode_xycb_32, 20 }, // LD D, SLL (IX + d)
    { &Z80::opcode_xycb_33, 20 }, // LD E, SLL (IX + d)
    { &Z80::opcode_xycb_34, 20 }, // LD H, SLL (IX + d)
    { &Z80::opcode_xycb_35, 20 }, // LD L, SLL (IX + d)
    { &Z80::opcode_xycb_36, 20 }, // SLL (IX + d)
    { &Z80::opcode_xycb_37, 20 }, // LD A, SLL (IX + d)
    { &Z80::opcode_xycb_38, 20 }, // LD B, SRL (IX + d)
    { &Z80::opcode_xycb_39, 20 }, // LD C, SRL (IX + d)
    { &Z80::opcode_xycb_3a, 20 }, // LD D, SRL (IX + d)
    { &Z80::opcode_xycb_3b, 20 }, // LD E, SRL (IX + d)
    { &Z80::opcode_xycb_3c, 20 }, // LD H, SRL (IX + d)
    { &Z80::opcode_xycb_3d, 20 }, // LD L, SRL (IX + d)
    { &Z80::opcode_xycb_3e, 20 }, // SRL (IX + d)
    { &Z80::opcode_xycb_3f, 20 }, // LD A, SRL (IX + d)
    { &Z80::opcode_xycb_40, 20 }, // BIT 0, (IX + d)
    { &Z80::opcode_xycb_41, 20 }, // BIT 0, (IX + d)
    { &Z80::opcode_xycb_42, 20 }, // BIT 0, (IX + d)
    { &Z80::opcode_xycb_43, 20 }, // BIT 0, (IX + d)
    { &Z80::opcode_xycb_44, 20 }, // BIT 0, (IX + d)
    { &Z80::opcode_xycb_45, 20 }, // BIT 0, (IX + d)
    { &Z80::opcode_xycb_46, 20 }, // BIT 0, (IX + d)
    { &Z80::opcode_xycb_47, 20 }, // BIT 0, (IX + d)
    { &Z80::opcode_xycb_48, 20 }, // BIT 1, (IX + d)
    { &Z80::opcode_xycb_49, 20 }, // BIT 1, (IX + d)
    { &Z80::opcode_xycb_4a, 20 }, // BIT 1, (IX + d)
    { &Z80::opcode_xycb_4b, 20 }, // BIT 1, (IX + d)
    { &Z80::opcode_xycb_4c, 20 }, // BIT 1, (IX + d)
    { &Z80::opcode_xycb_4d, 20 }, // BIT 1, (IX + d)
    { &Z80::opcode_xycb_4e, 20 }, // BIT 1, (IX + d)
    { &Z80::opcode_xycb_4f, 20 }, // BIT 1, (IX + d)
    { &Z80::opcode_xycb_50, 20 }, // BIT 2, (IX + d)
    { &Z80::opcode_xycb_51, 20 }, // BIT 2, (IX + d)
    { &Z80::opcode_xycb_52, 20 }, // BIT 2, (IX + d)
    { &Z80::opcode_xycb_53, 20 }, // BIT 2, (IX + d)
    { &Z80::opcode_xycb_54, 20 }, // BIT 2, (IX + d)
    { &Z80::opcode_xycb_55, 20 }, // BIT 2, (IX + d)
    { &Z80::opcode_xycb_56, 20 }, // BIT 2, (IX + d)
    { &Z80::opcode_xycb_57, 20 }, // BIT 2, (IX + d)
    { &Z80::opcode_xycb_58, 20 }, // BIT 3, (IX + d)
    { &Z80::opcode_xycb_59, 20 }, // BIT 3, (IX + d)
    { &Z80::opcode_xycb_5a, 20 }, // BIT 3, (IX + d)
    { &Z80::opcode_xycb_5b, 20 }, // BIT 3, (IX + d)
    { &Z80::opcode_xycb_5c, 20 }, // BIT 3, (IX + d)
    { &Z80::opcode_xycb_5d, 20 }, // BIT 3, (IX + d)
    { &Z80::opcode_xycb_5e, 20 }, // BIT 3, (IX + d)
    { &Z80::opcode_xycb_5f, 20 }, // BIT 3, (IX + d)
    { &Z80::opcode_xycb_60, 20 }, // BIT 4, (IX + d)
    { &Z80::opcode_xycb_61, 20 }, // BIT 4, (IX + d)
    { &Z80::opcode_xycb_62, 20 }, // BIT 4, (IX + d)
    { &Z80::opcode_xycb_63, 20 }, // BIT 4, (IX + d)
    { &Z80::opcode_xycb_64, 20 }, // BIT 4, (IX + d)
    { &Z80::opcode_xycb_65, 20 }, // BIT 4, (IX + d)
    { &Z80::opcode_xycb_66, 20 }, // BIT 4, (IX + d)
    { &Z80::opcode_xycb_67, 20 }, // BIT 4, (IX + d)
    { &Z80::opcode_xycb_68, 20 }, // BIT 5, (IX + d)
    { &Z80::opcode_xycb_69, 20 }, // BIT 5, (IX + d)
    { &Z80::opcode_xycb_6a, 20 }, // BIT 5, (IX + d)
    { &Z80::opcode_xycb_6b, 20 }, // BIT 5, (IX + d)
    { &Z80::opcode_xycb_6c, 20 }, // BIT 5, (IX + d)
    { &Z80::opcode_xycb_6d, 20 }, // BIT 5, (IX + d)
    { &Z80::opcode_xycb_6e, 20 }, // BIT 5, (IX + d)
    { &Z80::opcode_xycb_6f, 20 }, // BIT 5, (IX + d)
    { &Z80::opcode_xycb_70, 20 }, // BIT 6, (IX + d)
    { &Z80::opcode_xycb_71, 20 }, // BIT 6, (IX + d)
    { &Z80::opcode_xycb_72, 20 }, // BIT 6, (IX + d)
    { &Z80::opcode_xycb_73, 20 }, // BIT 6, (IX + d)
    { &Z80::opcode_xycb_74, 20 }, // BIT 6, (IX + d)
    { &Z80::opcode_xycb_75, 20 }, // BIT 6, (IX + d)
    { &Z80::opcode_xycb_76, 20 }, // BIT 6, (IX + d)
    { &Z80::opcode_xycb_77, 20 }, // BIT 6, (IX + d)
    { &Z80::opcode_xycb_78, 20 }, // BIT 7, (IX + d)
    { &Z80::opcode_xycb_79, 20 }, // BIT 7, (IX + d)
    { &Z80::opcode_xycb_7a, 20 }, // BIT 7, (IX + d)
    { &Z80::opcode_xycb_7b, 20 }, // BIT 7, (IX + d)
    { &Z80::opcode_xycb_7c, 20 }, // BIT 7, (IX + d)
    { &Z80::opcode_xycb_7d, 20 }, // BIT 7, (IX + d)
    { &Z80::opcode_xycb_7e, 20 }, // BIT 7, (IX + d)
    { &Z80::opcode_xycb_7f, 20 }, // BIT 7, (IX + d)
    { &Z80::opcode_xycb_80, 20 }, // LD B, RES 0, (IX + d)
    { &Z80::opcode_xycb_81, 20 }, // LD C, RES 0, (IX + d)
    { &Z80::opcode_xycb_82, 20 }, // LD D, RES 0, (IX + d)
    { &Z80::opcode_xycb_83, 20 }, // LD E, RES 0, (IX + d)
    { &Z80::opcode_xycb_84, 20 }, // LD H, RES 0, (IX + d)
    { &Z80::opcode_xycb_85, 20 }, // LD L, RES 0, (IX + d)
    { &Z80::opcode_xycb_86, 20 }, // RES 0, (IX + d)
    { &Z80::opcode_xycb_87, 20 }, // LD A, RES 0, (IX + d)
    { &Z80::opcode_xycb_88, 20 }, // LD B, RES 1, (IX + d)
    { &Z80::opcode_xycb_89, 20 }, // LD C, RES 1, (IX + d)
    { &Z80::opcode_xycb_8a, 20 }, // LD D, RES 1, (IX + d)
    { &Z80::opcode_xycb_8b, 20 }, // LD E, RES 1, (IX + d)
    { &Z80::opcode_xycb_8c, 20 }, // LD H, RES 1, (IX + d)
    { &Z80::opcode_xycb_8d, 20 }, // LD L, RES 1, (IX + d)
    { &Z80::opcode_xycb_8e, 20 }, // RES 1, (IX + d)
    { &Z80::opcode_xycb_8f, 20 }, // LD A, RES 1, (IX + d)
    { &Z80::opcode_xycb_90, 20 }, // LD B, RES 2, (IX + d)
    { &Z80::opcode_xycb_91, 20 }, // LD C, RES 2, (IX + d)
    { &Z80::opcode_xycb_92, 20 }, // LD D, RES 2, (IX + d)
    { &Z80::opcode_xycb_93, 20 }, // LD E, RES 2, (IX + d)
    { &Z80::opcode_xycb_94, 20 }, // LD H, RES 2, (IX + d)
    { &Z80::opcode_xycb_95, 20 }, // LD L, RES 2, (IX + d)
    { &Z80::opcode_xycb_96, 20 }, // RES 2, (IX + d)
    { &Z80::opcode_xycb_97, 20 }, // LD A, RES 2, (IX + d)
    { &Z80::opcode_xycb_98, 20 }, // LD B, RES 3, (IX + d)
    { &Z80::opcode_xycb_99, 20 }, // LD C, RES 3, (IX + d)
    { &Z80::opcode_xycb_9a, 20 }, // LD D, RES 3, (IX + d)
    { &Z80::opcode_xycb_9b, 20 }, // LD E, RES 3, (IX + d)
    { &Z80::opcode_xycb_9c, 20 }, // LD H, RES 3, (IX + d)
    { &Z80::opcode_xycb_9d, 20 }, // LD L, RES 3, (IX + d)
    { &Z80::opcode_xycb_9e, 20 }, // RES 3, (IX + d)
    { &Z80::opcode_xycb_9f, 20 }, // LD A, RES 3, (IX + d)
    { &Z80::opcode_xycb_a0, 20 }, // LD B, RES 4, (IX + d)
    { &Z80::opcode_xycb_a1, 20 }, // LD C, RES 4, (IX + d)
    { &Z80::opcode_xycb_a2, 20 }, // LD D, RES 4, (IX + d)
    { &Z80::opcode_xycb_a3, 20 }, // LD E, RES 4, (IX + d)
    { &Z80::opcode_xycb_a4, 20 }, // LD H, RES 4, (IX + d)
    { &Z80::opcode_xycb_a5, 20 }, // LD L, RES 4, (IX + d)
    { &Z80::opcode_xycb_a6, 20 }, // RES 4, (IX + d)
    { &Z80::opcode_xycb_a7, 20 }, // LD A, RES 4, (IX + d)
    { &Z80::opcode_xycb_a8, 20 }, // LD B, RES 5, (IX + d)
    { &Z80::opcode_xycb_a9, 20 }, // LD C, RES 5, (IX + d)
    { &Z80::opcode_xycb_aa, 20 }, // LD D, RES 5, (IX + d)
    { &Z80::opcode_xycb_ab, 20 }, // LD E, RES 5, (IX + d)
    { &Z80::opcode_xycb_ac, 20 }, // LD H, RES 5, (IX + d)
    { &Z80::opcode_xycb_ad, 20 }, // LD L, RES 5, (IX + d)
    { &Z80::opcode_xycb_ae, 20 }, // RES 5, (IX + d)
    { &Z80::opcode_xycb_af, 20 }, // LD A, RES 5, (IX + d)
    { &Z80::opcode_xycb_b0, 20 }, // LD B, RES 6, (IX + d)
    { &Z80::opcode_xycb_b1, 20 }, // LD C, RES 6, (IX + d)
    { &Z80::opcode_xycb_b2, 20 }, // LD D, RES 6, (IX + d)
    { &Z80::opcode_xycb_b3, 20 }, // LD E, RES 6, (IX + d)
    { &Z80::opcode_xycb_b4, 20 }, // LD H, RES 6, (IX + d)
    { &Z80::opcode_xycb_b5, 20 }, // LD L, RES 6, (IX + d)
    { &Z80::opcode_xycb_b6, 20 }, // RES 6, (IX + d)
    { &Z80::opcode_xycb_b7, 20 }, // LD A, RES 6, (IX + d)
    { &Z80::opcode_xycb_b8, 20 }, // LD B, RES 7, (IX + d)
    { &Z80::opcode_xycb_b9, 20 }, // LD C, RES 7, (IX + d)
    { &Z80::opcode_xycb_ba, 20 }, // LD D, RES 7, (IX + d)
    { &Z80::opcode_xycb_bb, 20 }, // LD E, RES 7, (IX + d)
    { &Z80::opcode_xycb_bc, 20 }, // LD H, RES 7, (IX + d)
    { &Z80::opcode_xycb_bd, 20 }, // LD L, RES 7, (IX + d)
    { &Z80::opcode_xycb_be, 20 }, // RES 7, (IX + d)
    { &Z80::opcode_xycb_bf, 20 }, // LD A, RES 7, (IX + d)
    { &Z80::opcode_xycb_c0, 20 }, // LD B, SET 0, (IX + d)
    { &Z80::opcode_xycb_c1, 20 }, // LD C, SET 0, (IX + d)
    { &Z80::opcode_xycb_c2, 20 }, // LD D, SET 0, (IX + d)
    { &Z80::opcode_xycb_c3, 20 }, // LD E, SET 0, (IX + d)
    { &Z80::opcode_xycb_c4, 20 }, // LD H, SET 0, (IX + d)
    { &Z80::opcode_xycb_c5, 20 }, // LD L, SET 0, (IX + d)
    { &Z80::opcode_xycb_c6, 20 }, // SET 0, (IX + d)
    { &Z80::opcode_xycb_c7, 20 }, // LD A, SET 0, (IX + d)
    { &Z80::opcode_xycb_c8, 20 }, // LD B, SET 1, (IX + d)
    { &Z80::opcode_xycb_c9, 20 }, // LD C, SET 1, (IX + d)
    { &Z80::opcode_xycb_ca, 20 }, // LD D, SET 1, (IX + d)
    { &Z80::opcode_xycb_cb, 20 }, // LD E, SET 1, (IX + d)
    { &Z80::opcode_xycb_cc, 20 }, // LD H, SET 1, (IX + d)
    { &Z80::opcode_xycb_cd, 20 }, // LD L, SET 1, (IX + d)
    { &Z80::opcode_xycb_ce, 20 }, // SET 1, (IX + d)
    { &Z80::opcode_xycb_cf, 20 }, // LD A, SET 1, (IX + d)
    { &Z80::opcode_xycb_d0, 20 }, // LD B, SET 2, (IX + d)
    { &Z80::opcode_xycb_d1, 20 }, // LD C, SET 2, (IX + d)
    { &Z80::opcode_xycb_d2, 20 }, // LD D, SET 2, (IX + d)
    { &Z80::opcode_xycb_d3, 20 }, // LD E, SET 2, (IX + d)
    { &Z80::opcode_xycb_d4, 20 }, // LD H, SET 2, (IX + d)
    { &Z80::opcode_xycb_d5, 20 }, // LD L, SET 2, (IX + d)
    { &Z80::opcode_xycb_d6, 20 }, // SET 2, (IX + d)
    { &Z80::opcode_xycb_d7, 20 }, // LD A, SET 2, (IX + d)
    { &Z80::opcode_xycb_d8, 20 }, // LD B, SET 3, (IX + d)
    { &Z80::opcode_xycb_d9, 20 }, // LD C, SET 3, (IX + d)
    { &Z80::opcode_xycb_da, 20 }, // LD D, SET 3, (IX + d)
    { &Z80::opcode_xycb_db, 20 }, // LD E, SET 3, (IX + d)
    { &Z80::opcode_xycb_dc, 20 }, // LD H, SET 3, (IX + d)
    { &Z80::opcode_xycb_dd, 20 }, // LD L, SET 3, (IX + d)
    { &Z80::opcode_xycb_de, 20 }, // SET 3, (IX + d)
    { &Z80::opcode_xycb_df, 20 }, // LD A, SET 3, (IX + d)
    { &Z80::opcode_xycb_e0, 20 }, // LD B, SET 4, (IX + d)
    { &Z80::opcode_xycb_e1, 20 }, // LD C, SET 4, (IX + d)
    { &Z80::opcode_xycb_e2, 20 }, // LD D, SET 4, (IX + d)
    { &Z80::opcode_xycb_e3, 20 }, // LD E, SET 4, (IX + d)
    { &Z80::opcode_xycb_e4, 20 }, // LD H, SET 4, (IX + d)
    { &Z80::opcode_xycb_e5, 20 }, // LD L, SET 4, (IX + d)
    { &Z80::opcode_xycb_e6, 20 }, // SET 4, (IX + d)
    { &Z80::opcode_xycb_e7, 20 }, // LD A, SET 4, (IX + d)
    { &Z80::opcode_xycb_e8, 20 }, // LD B, SET 5, (IX + d)
    { &Z80::opcode_xycb_e9, 20 }, // LD C, SET 5, (IX + d)
    { &Z80::opcode_xycb_ea, 20 }, // LD D, SET 5, (IX + d)
    { &Z80::opcode_xycb_eb, 20 }, // LD E, SET 5, (IX + d)
    { &Z80::opcode_xycb_ec, 20 }, // LD H, SET 5, (IX + d)
    { &Z80::opcode_xycb_ed, 20 }, // LD L, SET 5, (IX + d)
    { &Z80::opcode_xycb_ee, 20 }, // SET 5, (IX + d)
    { &Z80::opcode_xycb_ef, 20 }, // LD A, SET 5, (IX + d)
    { &Z80::opcode_xycb_f0, 20 }, // LD B, SET 6, (IX + d)
    { &Z80::opcode_xycb_f1, 20 }, // LD C, SET 6, (IX + d)
    { &Z80::opcode_xycb_f2, 20 }, // LD D, SET 6, (IX + d)
    { &Z80::opcode_xycb_f3, 20 }, // LD E, SET 6, (IX + d)
    { &Z80::opcode_xycb_f4, 20 }, // LD H, SET 6, (IX + d)
    { &Z80::opcode_xycb_f5, 20 }, // LD L, SET 6, (IX + d)
    { &Z80::opcode_xycb_f6, 20 }, // SET 6, (IX + d)
    { &Z80::opcode_xycb_f7, 20 }, // LD A, SET 6, (IX + d)
    { &Z80::opcode_xycb_f8, 20 }, // LD B, SET 7, (IX + d)
    { &Z80::opcode_xycb_f9, 20 }, // LD C, SET 7, (IX + d)
    { &Z80::opcode_xycb_fa, 20 }, // LD D, SET 7, (IX + d)
    { &Z80::opcode_xycb_fb, 20 }, // LD E, SET 7, (IX + d)
    { &Z80::opcode_xycb_fc, 20 }, // LD H, SET 7, (IX + d)
    { &Z80::opcode_xycb_fd, 20 }, // LD L, SET 7, (IX + d)
    { &Z80::opcode_xycb_fe, 20 }, // SET 7, (IX + d)
    { &Z80::opcode_xycb_ff, 20 }  // LD A, SET 7, (IX + d)
};

unsigned Z80::do_opcode_xycb( unsigned xy )
{
    xy = addDispl( xy, fetchByte() );

    unsigned    op = fetchByte();

    cycles_ += OpInfoXYCB_[ op ].cycles;

    (this->*(OpInfoXYCB_[ op ].handler))( xy );

    return xy;
}

void Z80::opcode_xycb_00( unsigned xy ) // LD B, RLC (IX + d)
{
    B = rotateLeftCarry( env_.readByte(xy) );
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_01( unsigned xy ) // LD C, RLC (IX + d)
{
    C = rotateLeftCarry( env_.readByte(xy) );
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_02( unsigned xy ) // LD D, RLC (IX + d)
{
    D = rotateLeftCarry( env_.readByte(xy) );
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_03( unsigned xy ) // LD E, RLC (IX + d)
{
    E = rotateLeftCarry( env_.readByte(xy) );
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_04( unsigned xy ) // LD H, RLC (IX + d)
{
    H = rotateLeftCarry( env_.readByte(xy) );
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_05( unsigned xy ) // LD L, RLC (IX + d)
{
    L = rotateLeftCarry( env_.readByte(xy) );
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_06( unsigned xy ) // RLC (IX + d)
{
    env_.writeByte( xy, rotateLeftCarry( env_.readByte(xy) ) );
}

void Z80::opcode_xycb_07( unsigned xy ) // LD A, RLC (IX + d)
{
    A = rotateLeftCarry( env_.readByte(xy) );
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_08( unsigned xy ) // LD B, RRC (IX + d)
{
    B = rotateRightCarry( env_.readByte(xy) );
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_09( unsigned xy ) // LD C, RRC (IX + d)
{
    C = rotateRightCarry( env_.readByte(xy) );
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_0a( unsigned xy ) // LD D, RRC (IX + d)
{
    D = rotateRightCarry( env_.readByte(xy) );
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_0b( unsigned xy ) // LD E, RRC (IX + d)
{
    E = rotateRightCarry( env_.readByte(xy) );
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_0c( unsigned xy ) // LD H, RRC (IX + d)
{
    H = rotateRightCarry( env_.readByte(xy) );
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_0d( unsigned xy ) // LD L, RRC (IX + d)
{
    L = rotateRightCarry( env_.readByte(xy) );
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_0e( unsigned xy ) // RRC (IX + d)
{
    env_.writeByte( xy, rotateRightCarry( env_.readByte(xy) ) );
}

void Z80::opcode_xycb_0f( unsigned xy ) // LD A, RRC (IX + d)
{
    A = rotateRightCarry( env_.readByte(xy) );
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_10( unsigned xy ) // LD B, RL (IX + d)
{
    B = rotateLeft( env_.readByte(xy) );
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_11( unsigned xy ) // LD C, RL (IX + d)
{
    C = rotateLeft( env_.readByte(xy) );
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_12( unsigned xy ) // LD D, RL (IX + d)
{
    D = rotateLeft( env_.readByte(xy) );
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_13( unsigned xy ) // LD E, RL (IX + d)
{
    E = rotateLeft( env_.readByte(xy) );
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_14( unsigned xy ) // LD H, RL (IX + d)
{
    H = rotateLeft( env_.readByte(xy) );
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_15( unsigned xy ) // LD L, RL (IX + d)
{
    L = rotateLeft( env_.readByte(xy) );
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_16( unsigned xy ) // RL (IX + d)
{
    env_.writeByte( xy, rotateLeft( env_.readByte(xy) ) );
}

void Z80::opcode_xycb_17( unsigned xy ) // LD A, RL (IX + d)
{
    A = rotateLeft( env_.readByte(xy) );
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_18( unsigned xy ) // LD B, RR (IX + d)
{
    B = rotateRight( env_.readByte(xy) );
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_19( unsigned xy ) // LD C, RR (IX + d)
{
    C = rotateRight( env_.readByte(xy) );
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_1a( unsigned xy ) // LD D, RR (IX + d)
{
    D = rotateRight( env_.readByte(xy) );
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_1b( unsigned xy ) // LD E, RR (IX + d)
{
    E = rotateRight( env_.readByte(xy) );
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_1c( unsigned xy ) // LD H, RR (IX + d)
{
    H = rotateRight( env_.readByte(xy) );
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_1d( unsigned xy ) // LD L, RR (IX + d)
{
    L = rotateRight( env_.readByte(xy) );
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_1e( unsigned xy ) // RR (IX + d)
{
    env_.writeByte( xy, rotateRight( env_.readByte(xy) ) );
}

void Z80::opcode_xycb_1f( unsigned xy ) // LD A, RR (IX + d)
{
    A = rotateRight( env_.readByte(xy) );
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_20( unsigned xy ) // LD B, SLA (IX + d)
{
    B = shiftLeft( env_.readByte(xy) );
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_21( unsigned xy ) // LD C, SLA (IX + d)
{
    C = shiftLeft( env_.readByte(xy) );
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_22( unsigned xy ) // LD D, SLA (IX + d)
{
    D = shiftLeft( env_.readByte(xy) );
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_23( unsigned xy ) // LD E, SLA (IX + d)
{
    E = shiftLeft( env_.readByte(xy) );
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_24( unsigned xy ) // LD H, SLA (IX + d)
{
    H = shiftLeft( env_.readByte(xy) );
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_25( unsigned xy ) // LD L, SLA (IX + d)
{
    L = shiftLeft( env_.readByte(xy) );
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_26( unsigned xy ) // SLA (IX + d)
{
    env_.writeByte( xy, shiftLeft( env_.readByte(xy) ) );
}

void Z80::opcode_xycb_27( unsigned xy ) // LD A, SLA (IX + d)
{
    A = shiftLeft( env_.readByte(xy) );
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_28( unsigned xy ) // LD B, SRA (IX + d)
{
    B = shiftRightArith( env_.readByte(xy) );
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_29( unsigned xy ) // LD C, SRA (IX + d)
{
    C = shiftRightArith( env_.readByte(xy) );
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_2a( unsigned xy ) // LD D, SRA (IX + d)
{
    D = shiftRightArith( env_.readByte(xy) );
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_2b( unsigned xy ) // LD E, SRA (IX + d)
{
    E = shiftRightArith( env_.readByte(xy) );
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_2c( unsigned xy ) // LD H, SRA (IX + d)
{
    H = shiftRightArith( env_.readByte(xy) );
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_2d( unsigned xy ) // LD L, SRA (IX + d)
{
    L = shiftRightArith( env_.readByte(xy) );
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_2e( unsigned xy ) // SRA (IX + d)
{
    env_.writeByte( xy, shiftRightArith( env_.readByte(xy) ) );
}

void Z80::opcode_xycb_2f( unsigned xy ) // LD A, SRA (IX + d)
{
    A = shiftRightArith( env_.readByte(xy) );
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_30( unsigned xy ) // LD B, SLL (IX + d)
{
    B = shiftLeft( env_.readByte(xy) ) | 0x01;
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_31( unsigned xy ) // LD C, SLL (IX + d)
{
    C = shiftLeft( env_.readByte(xy) ) | 0x01;
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_32( unsigned xy ) // LD D, SLL (IX + d)
{
    D = shiftLeft( env_.readByte(xy) ) | 0x01;
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_33( unsigned xy ) // LD E, SLL (IX + d)
{
    E = shiftLeft( env_.readByte(xy) ) | 0x01;
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_34( unsigned xy ) // LD H, SLL (IX + d)
{
    H = shiftLeft( env_.readByte(xy) ) | 0x01;
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_35( unsigned xy ) // LD L, SLL (IX + d)
{
    L = shiftLeft( env_.readByte(xy) ) | 0x01;
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_36( unsigned xy ) // SLL (IX + d)
{
    env_.writeByte( xy, shiftLeft( env_.readByte(xy) ) | 0x01 );
}

void Z80::opcode_xycb_37( unsigned xy ) // LD A, SLL (IX + d)
{
    A = shiftLeft( env_.readByte(xy) ) | 0x01;
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_38( unsigned xy ) // LD B, SRL (IX + d)
{
    B = shiftRightLogical( env_.readByte(xy) );
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_39( unsigned xy ) // LD C, SRL (IX + d)
{
    C = shiftRightLogical( env_.readByte(xy) );
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_3a( unsigned xy ) // LD D, SRL (IX + d)
{
    D = shiftRightLogical( env_.readByte(xy) );
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_3b( unsigned xy ) // LD E, SRL (IX + d)
{
    E = shiftRightLogical( env_.readByte(xy) );
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_3c( unsigned xy ) // LD H, SRL (IX + d)
{
    H = shiftRightLogical( env_.readByte(xy) );
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_3d( unsigned xy ) // LD L, SRL (IX + d)
{
    L = shiftRightLogical( env_.readByte(xy) );
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_3e( unsigned xy ) // SRL (IX + d)
{
    env_.writeByte( xy, shiftRightLogical( env_.readByte(xy) ) );
}

void Z80::opcode_xycb_3f( unsigned xy ) // LD A, SRL (IX + d)
{
    A = shiftRightLogical( env_.readByte(xy) );
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_40( unsigned xy ) // BIT 0, (IX + d)
{
    testBit( 0, env_.readByte( xy ) );
}

void Z80::opcode_xycb_41( unsigned xy ) // BIT 0, (IX + d)
{
    testBit( 0, env_.readByte( xy ) );
}

void Z80::opcode_xycb_42( unsigned xy ) // BIT 0, (IX + d)
{
    testBit( 0, env_.readByte( xy ) );
}

void Z80::opcode_xycb_43( unsigned xy ) // BIT 0, (IX + d)
{
    testBit( 0, env_.readByte( xy ) );
}

void Z80::opcode_xycb_44( unsigned xy ) // BIT 0, (IX + d)
{
    testBit( 0, env_.readByte( xy ) );
}

void Z80::opcode_xycb_45( unsigned xy ) // BIT 0, (IX + d)
{
    testBit( 0, env_.readByte( xy ) );
}

void Z80::opcode_xycb_46( unsigned xy ) // BIT 0, (IX + d)
{
    testBit( 0, env_.readByte( xy ) );
}

void Z80::opcode_xycb_47( unsigned xy ) // BIT 0, (IX + d)
{
    testBit( 0, env_.readByte( xy ) );
}

void Z80::opcode_xycb_48( unsigned xy ) // BIT 1, (IX + d)
{
    testBit( 1, env_.readByte( xy ) );
}

void Z80::opcode_xycb_49( unsigned xy ) // BIT 1, (IX + d)
{
    testBit( 1, env_.readByte( xy ) );
}

void Z80::opcode_xycb_4a( unsigned xy ) // BIT 1, (IX + d)
{
    testBit( 1, env_.readByte( xy ) );
}

void Z80::opcode_xycb_4b( unsigned xy ) // BIT 1, (IX + d)
{
    testBit( 1, env_.readByte( xy ) );
}

void Z80::opcode_xycb_4c( unsigned xy ) // BIT 1, (IX + d)
{
    testBit( 1, env_.readByte( xy ) );
}

void Z80::opcode_xycb_4d( unsigned xy ) // BIT 1, (IX + d)
{
    testBit( 1, env_.readByte( xy ) );
}

void Z80::opcode_xycb_4e( unsigned xy ) // BIT 1, (IX + d)
{
    testBit( 1, env_.readByte( xy ) );
}

void Z80::opcode_xycb_4f( unsigned xy ) // BIT 1, (IX + d)
{
    testBit( 1, env_.readByte( xy ) );
}

void Z80::opcode_xycb_50( unsigned xy ) // BIT 2, (IX + d)
{
    testBit( 2, env_.readByte( xy ) );
}

void Z80::opcode_xycb_51( unsigned xy ) // BIT 2, (IX + d)
{
    testBit( 2, env_.readByte( xy ) );
}

void Z80::opcode_xycb_52( unsigned xy ) // BIT 2, (IX + d)
{
    testBit( 2, env_.readByte( xy ) );
}

void Z80::opcode_xycb_53( unsigned xy ) // BIT 2, (IX + d)
{
    testBit( 2, env_.readByte( xy ) );
}

void Z80::opcode_xycb_54( unsigned xy ) // BIT 2, (IX + d)
{
    testBit( 2, env_.readByte( xy ) );
}

void Z80::opcode_xycb_55( unsigned xy ) // BIT 2, (IX + d)
{
    testBit( 2, env_.readByte( xy ) );
}

void Z80::opcode_xycb_56( unsigned xy ) // BIT 2, (IX + d)
{
    testBit( 2, env_.readByte( xy ) );
}

void Z80::opcode_xycb_57( unsigned xy ) // BIT 2, (IX + d)
{
    testBit( 2, env_.readByte( xy ) );
}

void Z80::opcode_xycb_58( unsigned xy ) // BIT 3, (IX + d)
{
    testBit( 3, env_.readByte( xy ) );
}

void Z80::opcode_xycb_59( unsigned xy ) // BIT 3, (IX + d)
{
    testBit( 3, env_.readByte( xy ) );
}

void Z80::opcode_xycb_5a( unsigned xy ) // BIT 3, (IX + d)
{
    testBit( 3, env_.readByte( xy ) );
}

void Z80::opcode_xycb_5b( unsigned xy ) // BIT 3, (IX + d)
{
    testBit( 3, env_.readByte( xy ) );
}

void Z80::opcode_xycb_5c( unsigned xy ) // BIT 3, (IX + d)
{
    testBit( 3, env_.readByte( xy ) );
}

void Z80::opcode_xycb_5d( unsigned xy ) // BIT 3, (IX + d)
{
    testBit( 3, env_.readByte( xy ) );
}

void Z80::opcode_xycb_5e( unsigned xy ) // BIT 3, (IX + d)
{
    testBit( 3, env_.readByte( xy ) );
}

void Z80::opcode_xycb_5f( unsigned xy ) // BIT 3, (IX + d)
{
    testBit( 3, env_.readByte( xy ) );
}

void Z80::opcode_xycb_60( unsigned xy ) // BIT 4, (IX + d)
{
    testBit( 4, env_.readByte( xy ) );
}

void Z80::opcode_xycb_61( unsigned xy ) // BIT 4, (IX + d)
{
    testBit( 4, env_.readByte( xy ) );
}

void Z80::opcode_xycb_62( unsigned xy ) // BIT 4, (IX + d)
{
    testBit( 4, env_.readByte( xy ) );
}

void Z80::opcode_xycb_63( unsigned xy ) // BIT 4, (IX + d)
{
    testBit( 4, env_.readByte( xy ) );
}

void Z80::opcode_xycb_64( unsigned xy ) // BIT 4, (IX + d)
{
    testBit( 4, env_.readByte( xy ) );
}

void Z80::opcode_xycb_65( unsigned xy ) // BIT 4, (IX + d)
{
    testBit( 4, env_.readByte( xy ) );
}

void Z80::opcode_xycb_66( unsigned xy ) // BIT 4, (IX + d)
{
    testBit( 4, env_.readByte( xy ) );
}

void Z80::opcode_xycb_67( unsigned xy ) // BIT 4, (IX + d)
{
    testBit( 4, env_.readByte( xy ) );
}

void Z80::opcode_xycb_68( unsigned xy ) // BIT 5, (IX + d)
{
    testBit( 5, env_.readByte( xy ) );
}

void Z80::opcode_xycb_69( unsigned xy ) // BIT 5, (IX + d)
{
    testBit( 5, env_.readByte( xy ) );
}

void Z80::opcode_xycb_6a( unsigned xy ) // BIT 5, (IX + d)
{
    testBit( 5, env_.readByte( xy ) );
}

void Z80::opcode_xycb_6b( unsigned xy ) // BIT 5, (IX + d)
{
    testBit( 5, env_.readByte( xy ) );
}

void Z80::opcode_xycb_6c( unsigned xy ) // BIT 5, (IX + d)
{
    testBit( 5, env_.readByte( xy ) );
}

void Z80::opcode_xycb_6d( unsigned xy ) // BIT 5, (IX + d)
{
    testBit( 5, env_.readByte( xy ) );
}

void Z80::opcode_xycb_6e( unsigned xy ) // BIT 5, (IX + d)
{
    testBit( 5, env_.readByte( xy ) );
}

void Z80::opcode_xycb_6f( unsigned xy ) // BIT 5, (IX + d)
{
    testBit( 5, env_.readByte( xy ) );
}

void Z80::opcode_xycb_70( unsigned xy ) // BIT 6, (IX + d)
{
    testBit( 6, env_.readByte( xy ) );
}

void Z80::opcode_xycb_71( unsigned xy ) // BIT 6, (IX + d)
{
    testBit( 6, env_.readByte( xy ) );
}

void Z80::opcode_xycb_72( unsigned xy ) // BIT 6, (IX + d)
{
    testBit( 6, env_.readByte( xy ) );
}

void Z80::opcode_xycb_73( unsigned xy ) // BIT 6, (IX + d)
{
    testBit( 6, env_.readByte( xy ) );
}

void Z80::opcode_xycb_74( unsigned xy ) // BIT 6, (IX + d)
{
    testBit( 6, env_.readByte( xy ) );
}

void Z80::opcode_xycb_75( unsigned xy ) // BIT 6, (IX + d)
{
    testBit( 6, env_.readByte( xy ) );
}

void Z80::opcode_xycb_76( unsigned xy ) // BIT 6, (IX + d)
{
    testBit( 6, env_.readByte( xy ) );
}

void Z80::opcode_xycb_77( unsigned xy ) // BIT 6, (IX + d)
{
    testBit( 6, env_.readByte( xy ) );
}

void Z80::opcode_xycb_78( unsigned xy ) // BIT 7, (IX + d)
{
    testBit( 7, env_.readByte( xy ) );
}

void Z80::opcode_xycb_79( unsigned xy ) // BIT 7, (IX + d)
{
    testBit( 7, env_.readByte( xy ) );
}

void Z80::opcode_xycb_7a( unsigned xy ) // BIT 7, (IX + d)
{
    testBit( 7, env_.readByte( xy ) );
}

void Z80::opcode_xycb_7b( unsigned xy ) // BIT 7, (IX + d)
{
    testBit( 7, env_.readByte( xy ) );
}

void Z80::opcode_xycb_7c( unsigned xy ) // BIT 7, (IX + d)
{
    testBit( 7, env_.readByte( xy ) );
}

void Z80::opcode_xycb_7d( unsigned xy ) // BIT 7, (IX + d)
{
    testBit( 7, env_.readByte( xy ) );
}

void Z80::opcode_xycb_7e( unsigned xy ) // BIT 7, (IX + d)
{
    testBit( 7, env_.readByte( xy ) );
}

void Z80::opcode_xycb_7f( unsigned xy ) // BIT 7, (IX + d)
{
    testBit( 7, env_.readByte( xy ) );
}

void Z80::opcode_xycb_80( unsigned xy ) // LD B, RES 0, (IX + d)
{
    B = env_.readByte(xy) & (unsigned char) ~(1 << 0);
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_81( unsigned xy ) // LD C, RES 0, (IX + d)
{
    C = env_.readByte(xy) & (unsigned char) ~(1 << 0);
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_82( unsigned xy ) // LD D, RES 0, (IX + d)
{
    D = env_.readByte(xy) & (unsigned char) ~(1 << 0);
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_83( unsigned xy ) // LD E, RES 0, (IX + d)
{
    E = env_.readByte(xy) & (unsigned char) ~(1 << 0);
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_84( unsigned xy ) // LD H, RES 0, (IX + d)
{
    H = env_.readByte(xy) & (unsigned char) ~(1 << 0);
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_85( unsigned xy ) // LD L, RES 0, (IX + d)
{
    L = env_.readByte(xy) & (unsigned char) ~(1 << 0);
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_86( unsigned xy ) // RES 0, (IX + d)
{
    env_.writeByte( xy, env_.readByte(xy) & (unsigned char) ~(1 << 0) );
}

void Z80::opcode_xycb_87( unsigned xy ) // LD A, RES 0, (IX + d)
{
    A = env_.readByte(xy) & (unsigned char) ~(1 << 0);
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_88( unsigned xy ) // LD B, RES 1, (IX + d)
{
    B = env_.readByte(xy) & (unsigned char) ~(1 << 1);
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_89( unsigned xy ) // LD C, RES 1, (IX + d)
{
    C = env_.readByte(xy) & (unsigned char) ~(1 << 1);
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_8a( unsigned xy ) // LD D, RES 1, (IX + d)
{
    D = env_.readByte(xy) & (unsigned char) ~(1 << 1);
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_8b( unsigned xy ) // LD E, RES 1, (IX + d)
{
    E = env_.readByte(xy) & (unsigned char) ~(1 << 1);
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_8c( unsigned xy ) // LD H, RES 1, (IX + d)
{
    H = env_.readByte(xy) & (unsigned char) ~(1 << 1);
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_8d( unsigned xy ) // LD L, RES 1, (IX + d)
{
    L = env_.readByte(xy) & (unsigned char) ~(1 << 1);
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_8e( unsigned xy ) // RES 1, (IX + d)
{
    env_.writeByte( xy, env_.readByte(xy) & (unsigned char) ~(1 << 1) );
}

void Z80::opcode_xycb_8f( unsigned xy ) // LD A, RES 1, (IX + d)
{
    A = env_.readByte(xy) & (unsigned char) ~(1 << 1);
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_90( unsigned xy ) // LD B, RES 2, (IX + d)
{
    B = env_.readByte(xy) & (unsigned char) ~(1 << 2);
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_91( unsigned xy ) // LD C, RES 2, (IX + d)
{
    C = env_.readByte(xy) & (unsigned char) ~(1 << 2);
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_92( unsigned xy ) // LD D, RES 2, (IX + d)
{
    D = env_.readByte(xy) & (unsigned char) ~(1 << 2);
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_93( unsigned xy ) // LD E, RES 2, (IX + d)
{
    E = env_.readByte(xy) & (unsigned char) ~(1 << 2);
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_94( unsigned xy ) // LD H, RES 2, (IX + d)
{
    H = env_.readByte(xy) & (unsigned char) ~(1 << 2);
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_95( unsigned xy ) // LD L, RES 2, (IX + d)
{
    L = env_.readByte(xy) & (unsigned char) ~(1 << 2);
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_96( unsigned xy ) // RES 2, (IX + d)
{
    env_.writeByte( xy, env_.readByte(xy) & (unsigned char) ~(1 << 2) );
}

void Z80::opcode_xycb_97( unsigned xy ) // LD A, RES 2, (IX + d)
{
    A = env_.readByte(xy) & (unsigned char) ~(1 << 2);
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_98( unsigned xy ) // LD B, RES 3, (IX + d)
{
    B = env_.readByte(xy) & (unsigned char) ~(1 << 3);
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_99( unsigned xy ) // LD C, RES 3, (IX + d)
{
    C = env_.readByte(xy) & (unsigned char) ~(1 << 3);
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_9a( unsigned xy ) // LD D, RES 3, (IX + d)
{
    D = env_.readByte(xy) & (unsigned char) ~(1 << 3);
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_9b( unsigned xy ) // LD E, RES 3, (IX + d)
{
    E = env_.readByte(xy) & (unsigned char) ~(1 << 3);
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_9c( unsigned xy ) // LD H, RES 3, (IX + d)
{
    H = env_.readByte(xy) & (unsigned char) ~(1 << 3);
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_9d( unsigned xy ) // LD L, RES 3, (IX + d)
{
    L = env_.readByte(xy) & (unsigned char) ~(1 << 3);
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_9e( unsigned xy ) // RES 3, (IX + d)
{
    env_.writeByte( xy, env_.readByte(xy) & (unsigned char) ~(1 << 3) );
}

void Z80::opcode_xycb_9f( unsigned xy ) // LD A, RES 3, (IX + d)
{
    A = env_.readByte(xy) & (unsigned char) ~(1 << 3);
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_a0( unsigned xy ) // LD B, RES 4, (IX + d)
{
    B = env_.readByte(xy) & (unsigned char) ~(1 << 4);
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_a1( unsigned xy ) // LD C, RES 4, (IX + d)
{
    C = env_.readByte(xy) & (unsigned char) ~(1 << 4);
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_a2( unsigned xy ) // LD D, RES 4, (IX + d)
{
    D = env_.readByte(xy) & (unsigned char) ~(1 << 4);
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_a3( unsigned xy ) // LD E, RES 4, (IX + d)
{
    E = env_.readByte(xy) & (unsigned char) ~(1 << 4);
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_a4( unsigned xy ) // LD H, RES 4, (IX + d)
{
    H = env_.readByte(xy) & (unsigned char) ~(1 << 4);
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_a5( unsigned xy ) // LD L, RES 4, (IX + d)
{
    L = env_.readByte(xy) & (unsigned char) ~(1 << 4);
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_a6( unsigned xy ) // RES 4, (IX + d)
{
    env_.writeByte( xy, env_.readByte(xy) & (unsigned char) ~(1 << 4) );
}

void Z80::opcode_xycb_a7( unsigned xy ) // LD A, RES 4, (IX + d)
{
    A = env_.readByte(xy) & (unsigned char) ~(1 << 4);
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_a8( unsigned xy ) // LD B, RES 5, (IX + d)
{
    B = env_.readByte(xy) & (unsigned char) ~(1 << 5);
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_a9( unsigned xy ) // LD C, RES 5, (IX + d)
{
    C = env_.readByte(xy) & (unsigned char) ~(1 << 5);
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_aa( unsigned xy ) // LD D, RES 5, (IX + d)
{
    D = env_.readByte(xy) & (unsigned char) ~(1 << 5);
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_ab( unsigned xy ) // LD E, RES 5, (IX + d)
{
    E = env_.readByte(xy) & (unsigned char) ~(1 << 5);
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_ac( unsigned xy ) // LD H, RES 5, (IX + d)
{
    H = env_.readByte(xy) & (unsigned char) ~(1 << 5);
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_ad( unsigned xy ) // LD L, RES 5, (IX + d)
{
    L = env_.readByte(xy) & (unsigned char) ~(1 << 5);
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_ae( unsigned xy ) // RES 5, (IX + d)
{
    env_.writeByte( xy, env_.readByte(xy) & (unsigned char) ~(1 << 5) );
}

void Z80::opcode_xycb_af( unsigned xy ) // LD A, RES 5, (IX + d)
{
    A = env_.readByte(xy) & (unsigned char) ~(1 << 5);
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_b0( unsigned xy ) // LD B, RES 6, (IX + d)
{
    B = env_.readByte(xy) & (unsigned char) ~(1 << 6);
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_b1( unsigned xy ) // LD C, RES 6, (IX + d)
{
    C = env_.readByte(xy) & (unsigned char) ~(1 << 6);
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_b2( unsigned xy ) // LD D, RES 6, (IX + d)
{
    D = env_.readByte(xy) & (unsigned char) ~(1 << 6);
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_b3( unsigned xy ) // LD E, RES 6, (IX + d)
{
    E = env_.readByte(xy) & (unsigned char) ~(1 << 6);
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_b4( unsigned xy ) // LD H, RES 6, (IX + d)
{
    H = env_.readByte(xy) & (unsigned char) ~(1 << 6);
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_b5( unsigned xy ) // LD L, RES 6, (IX + d)
{
    L = env_.readByte(xy) & (unsigned char) ~(1 << 6);
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_b6( unsigned xy ) // RES 6, (IX + d)
{
    env_.writeByte( xy, env_.readByte(xy) & (unsigned char) ~(1 << 6) );
}

void Z80::opcode_xycb_b7( unsigned xy ) // LD A, RES 6, (IX + d)
{
    A = env_.readByte(xy) & (unsigned char) ~(1 << 6);
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_b8( unsigned xy ) // LD B, RES 7, (IX + d)
{
    B = env_.readByte(xy) & (unsigned char) ~(1 << 7);
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_b9( unsigned xy ) // LD C, RES 7, (IX + d)
{
    C = env_.readByte(xy) & (unsigned char) ~(1 << 7);
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_ba( unsigned xy ) // LD D, RES 7, (IX + d)
{
    D = env_.readByte(xy) & (unsigned char) ~(1 << 7);
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_bb( unsigned xy ) // LD E, RES 7, (IX + d)
{
    E = env_.readByte(xy) & (unsigned char) ~(1 << 7);
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_bc( unsigned xy ) // LD H, RES 7, (IX + d)
{
    H = env_.readByte(xy) & (unsigned char) ~(1 << 7);
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_bd( unsigned xy ) // LD L, RES 7, (IX + d)
{
    L = env_.readByte(xy) & (unsigned char) ~(1 << 7);
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_be( unsigned xy ) // RES 7, (IX + d)
{
    env_.writeByte( xy, env_.readByte(xy) & (unsigned char) ~(1 << 7) );
}

void Z80::opcode_xycb_bf( unsigned xy ) // LD A, RES 7, (IX + d)
{
    A = env_.readByte(xy) & (unsigned char) ~(1 << 7);
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_c0( unsigned xy ) // LD B, SET 0, (IX + d)
{
    B = env_.readByte(xy) | (unsigned char) (1 << 0);
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_c1( unsigned xy ) // LD C, SET 0, (IX + d)
{
    C = env_.readByte(xy) | (unsigned char) (1 << 0);
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_c2( unsigned xy ) // LD D, SET 0, (IX + d)
{
    D = env_.readByte(xy) | (unsigned char) (1 << 0);
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_c3( unsigned xy ) // LD E, SET 0, (IX + d)
{
    E = env_.readByte(xy) | (unsigned char) (1 << 0);
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_c4( unsigned xy ) // LD H, SET 0, (IX + d)
{
    H = env_.readByte(xy) | (unsigned char) (1 << 0);
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_c5( unsigned xy ) // LD L, SET 0, (IX + d)
{
    L = env_.readByte(xy) | (unsigned char) (1 << 0);
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_c6( unsigned xy ) // SET 0, (IX + d)
{
    env_.writeByte( xy, env_.readByte(xy) | (unsigned char) (1 << 0) );
}

void Z80::opcode_xycb_c7( unsigned xy ) // LD A, SET 0, (IX + d)
{
    A = env_.readByte(xy) | (unsigned char) (1 << 0);
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_c8( unsigned xy ) // LD B, SET 1, (IX + d)
{
    B = env_.readByte(xy) | (unsigned char) (1 << 1);
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_c9( unsigned xy ) // LD C, SET 1, (IX + d)
{
    C = env_.readByte(xy) | (unsigned char) (1 << 1);
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_ca( unsigned xy ) // LD D, SET 1, (IX + d)
{
    D = env_.readByte(xy) | (unsigned char) (1 << 1);
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_cb( unsigned xy ) // LD E, SET 1, (IX + d)
{
    E = env_.readByte(xy) | (unsigned char) (1 << 1);
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_cc( unsigned xy ) // LD H, SET 1, (IX + d)
{
    H = env_.readByte(xy) | (unsigned char) (1 << 1);
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_cd( unsigned xy ) // LD L, SET 1, (IX + d)
{
    L = env_.readByte(xy) | (unsigned char) (1 << 1);
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_ce( unsigned xy ) // SET 1, (IX + d)
{
    env_.writeByte( xy, env_.readByte(xy) | (unsigned char) (1 << 1) );
}

void Z80::opcode_xycb_cf( unsigned xy ) // LD A, SET 1, (IX + d)
{
    A = env_.readByte(xy) | (unsigned char) (1 << 1);
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_d0( unsigned xy ) // LD B, SET 2, (IX + d)
{
    B = env_.readByte(xy) | (unsigned char) (1 << 2);
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_d1( unsigned xy ) // LD C, SET 2, (IX + d)
{
    C = env_.readByte(xy) | (unsigned char) (1 << 2);
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_d2( unsigned xy ) // LD D, SET 2, (IX + d)
{
    D = env_.readByte(xy) | (unsigned char) (1 << 2);
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_d3( unsigned xy ) // LD E, SET 2, (IX + d)
{
    E = env_.readByte(xy) | (unsigned char) (1 << 2);
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_d4( unsigned xy ) // LD H, SET 2, (IX + d)
{
    H = env_.readByte(xy) | (unsigned char) (1 << 2);
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_d5( unsigned xy ) // LD L, SET 2, (IX + d)
{
    L = env_.readByte(xy) | (unsigned char) (1 << 2);
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_d6( unsigned xy ) // SET 2, (IX + d)
{
    env_.writeByte( xy, env_.readByte(xy) | (unsigned char) (1 << 2) );
}

void Z80::opcode_xycb_d7( unsigned xy ) // LD A, SET 2, (IX + d)
{
    A = env_.readByte(xy) | (unsigned char) (1 << 2);
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_d8( unsigned xy ) // LD B, SET 3, (IX + d)
{
    B = env_.readByte(xy) | (unsigned char) (1 << 3);
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_d9( unsigned xy ) // LD C, SET 3, (IX + d)
{
    C = env_.readByte(xy) | (unsigned char) (1 << 3);
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_da( unsigned xy ) // LD D, SET 3, (IX + d)
{
    D = env_.readByte(xy) | (unsigned char) (1 << 3);
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_db( unsigned xy ) // LD E, SET 3, (IX + d)
{
    E = env_.readByte(xy) | (unsigned char) (1 << 3);
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_dc( unsigned xy ) // LD H, SET 3, (IX + d)
{
    H = env_.readByte(xy) | (unsigned char) (1 << 3);
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_dd( unsigned xy ) // LD L, SET 3, (IX + d)
{
    L = env_.readByte(xy) | (unsigned char) (1 << 3);
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_de( unsigned xy ) // SET 3, (IX + d)
{
    env_.writeByte( xy, env_.readByte(xy) | (unsigned char) (1 << 3) );
}

void Z80::opcode_xycb_df( unsigned xy ) // LD A, SET 3, (IX + d)
{
    A = env_.readByte(xy) | (unsigned char) (1 << 3);
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_e0( unsigned xy ) // LD B, SET 4, (IX + d)
{
    B = env_.readByte(xy) | (unsigned char) (1 << 4);
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_e1( unsigned xy ) // LD C, SET 4, (IX + d)
{
    C = env_.readByte(xy) | (unsigned char) (1 << 4);
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_e2( unsigned xy ) // LD D, SET 4, (IX + d)
{
    D = env_.readByte(xy) | (unsigned char) (1 << 4);
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_e3( unsigned xy ) // LD E, SET 4, (IX + d)
{
    E = env_.readByte(xy) | (unsigned char) (1 << 4);
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_e4( unsigned xy ) // LD H, SET 4, (IX + d)
{
    H = env_.readByte(xy) | (unsigned char) (1 << 4);
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_e5( unsigned xy ) // LD L, SET 4, (IX + d)
{
    L = env_.readByte(xy) | (unsigned char) (1 << 4);
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_e6( unsigned xy ) // SET 4, (IX + d)
{
    env_.writeByte( xy, env_.readByte(xy) | (unsigned char) (1 << 4) );
}

void Z80::opcode_xycb_e7( unsigned xy ) // LD A, SET 4, (IX + d)
{
    A = env_.readByte(xy) | (unsigned char) (1 << 4);
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_e8( unsigned xy ) // LD B, SET 5, (IX + d)
{
    B = env_.readByte(xy) | (unsigned char) (1 << 5);
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_e9( unsigned xy ) // LD C, SET 5, (IX + d)
{
    C = env_.readByte(xy) | (unsigned char) (1 << 5);
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_ea( unsigned xy ) // LD D, SET 5, (IX + d)
{
    D = env_.readByte(xy) | (unsigned char) (1 << 5);
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_eb( unsigned xy ) // LD E, SET 5, (IX + d)
{
    E = env_.readByte(xy) | (unsigned char) (1 << 5);
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_ec( unsigned xy ) // LD H, SET 5, (IX + d)
{
    H = env_.readByte(xy) | (unsigned char) (1 << 5);
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_ed( unsigned xy ) // LD L, SET 5, (IX + d)
{
    L = env_.readByte(xy) | (unsigned char) (1 << 5);
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_ee( unsigned xy ) // SET 5, (IX + d)
{
    env_.writeByte( xy, env_.readByte(xy) | (unsigned char) (1 << 5) );
}

void Z80::opcode_xycb_ef( unsigned xy ) // LD A, SET 5, (IX + d)
{
    A = env_.readByte(xy) | (unsigned char) (1 << 5);
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_f0( unsigned xy ) // LD B, SET 6, (IX + d)
{
    B = env_.readByte(xy) | (unsigned char) (1 << 6);
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_f1( unsigned xy ) // LD C, SET 6, (IX + d)
{
    C = env_.readByte(xy) | (unsigned char) (1 << 6);
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_f2( unsigned xy ) // LD D, SET 6, (IX + d)
{
    D = env_.readByte(xy) | (unsigned char) (1 << 6);
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_f3( unsigned xy ) // LD E, SET 6, (IX + d)
{
    E = env_.readByte(xy) | (unsigned char) (1 << 6);
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_f4( unsigned xy ) // LD H, SET 6, (IX + d)
{
    H = env_.readByte(xy) | (unsigned char) (1 << 6);
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_f5( unsigned xy ) // LD L, SET 6, (IX + d)
{
    L = env_.readByte(xy) | (unsigned char) (1 << 6);
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_f6( unsigned xy ) // SET 6, (IX + d)
{
    env_.writeByte( xy, env_.readByte(xy) | (unsigned char) (1 << 6) );
}

void Z80::opcode_xycb_f7( unsigned xy ) // LD A, SET 6, (IX + d)
{
    A = env_.readByte(xy) | (unsigned char) (1 << 6);
    env_.writeByte( xy, A );
}

void Z80::opcode_xycb_f8( unsigned xy ) // LD B, SET 7, (IX + d)
{
    B = env_.readByte(xy) | (unsigned char) (1 << 7);
    env_.writeByte( xy, B );
}

void Z80::opcode_xycb_f9( unsigned xy ) // LD C, SET 7, (IX + d)
{
    C = env_.readByte(xy) | (unsigned char) (1 << 7);
    env_.writeByte( xy, C );
}

void Z80::opcode_xycb_fa( unsigned xy ) // LD D, SET 7, (IX + d)
{
    D = env_.readByte(xy) | (unsigned char) (1 << 7);
    env_.writeByte( xy, D );
}

void Z80::opcode_xycb_fb( unsigned xy ) // LD E, SET 7, (IX + d)
{
    E = env_.readByte(xy) | (unsigned char) (1 << 7);
    env_.writeByte( xy, E );
}

void Z80::opcode_xycb_fc( unsigned xy ) // LD H, SET 7, (IX + d)
{
    H = env_.readByte(xy) | (unsigned char) (1 << 7);
    env_.writeByte( xy, H );
}

void Z80::opcode_xycb_fd( unsigned xy ) // LD L, SET 7, (IX + d)
{
    L = env_.readByte(xy) | (unsigned char) (1 << 7);
    env_.writeByte( xy, L );
}

void Z80::opcode_xycb_fe( unsigned xy ) // SET 7, (IX + d)
{
    env_.writeByte( xy, env_.readByte(xy) | (unsigned char) (1 << 7) );
}

void Z80::opcode_xycb_ff( unsigned xy ) // LD A, SET 7, (IX + d)
{
    A = env_.readByte(xy) | (unsigned char) (1 << 7);
    env_.writeByte( xy, A );
}
