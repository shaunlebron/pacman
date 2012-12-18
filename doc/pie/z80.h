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
#ifndef Z80_H_
#define Z80_H_

/**
    Environment for Z80 emulation.

    This class implements all input/output functions for the Z80 emulator class,
    that is it provides functions to access the system RAM, ROM and I/O ports.

    An object of this class corresponds to a system that has no RAM, ROM or ports:
    users of the Z80 emulator should provide the desired behaviour by writing a
    descendant of this class.

    @author Alessandro Scotti
    @version 1.0
*/
class Z80Environment
{
public:
    /** Constructor. */
    Z80Environment() {
    }

    /** Destructor. */
    virtual ~Z80Environment() {
    }

    /**
        Reads one byte from memory at the specified address.

        The address parameter may contain any value, including
        values greater than 0xFFFF (64k), so if necessary
        the implementation must check for illegal values and
        handle them according to the implemented system 
        specifications.
    */
    virtual unsigned char readByte( unsigned addr ) {
        return 0xFF;
    }

    /**
        Writes one byte to memory at the specified address.

        The address parameter may contain any value, including
        values greater than 0xFFFF (64k), so if necessary
        the implementation must check for illegal values and
        handle them according to the implemented system 
        specifications.
    */
    virtual void writeByte( unsigned addr, unsigned char value ) {
    }

    /**
        Reads one byte from the specified port.

        Note: the port value is always between 00h and FFh included.
    */
    virtual unsigned char readPort( unsigned port ) {
        return 0xFF;
    }

    /**
        Writes one byte from the specified port.

        Note: the port value is always between 00h and FFh included.
    */
    virtual void writePort( unsigned port, unsigned char value ) {
    }

    /**
        Called immediately after a RETI is executed.
    */
    virtual void onReturnFromInterrupt() {
    }
};

/**
    Z80 software emulator.

    @author Alessandro Scotti
    @version 1.1
*/
class Z80
{
public:
    /** CPU flags */
    enum {
        Carry     = 0x01,                       // C
        AddSub    = 0x02, Subtraction = AddSub, // N
        Parity    = 0x04, Overflow = Parity,    // P/V, same bit used for parity and overflow
        Flag3     = 0x08,                       // Aka XF, not used
        Halfcarry = 0x10,                       // H
        Flag5     = 0x20,                       // Aka YF, not used
        Zero      = 0x40,                       // Z
        Sign      = 0x80                        // S
    };

public:
    // Registers
    unsigned char   B;      //@- B register
    unsigned char   C;      //@- C register
    unsigned char   D;      //@- D register
    unsigned char   E;      //@- E register
    unsigned char   H;      //@- H register
    unsigned char   L;      //@- L register
    unsigned char   A;      //@- A register (accumulator)
    unsigned char   F;      //@- Flags register
    unsigned char   B1;     //@- Alternate B register (B')
    unsigned char   C1;     //@- Alternate C register (C')
    unsigned char   D1;     //@- Alternate D register (D')
    unsigned char   E1;     //@- Alternate E register (E')
    unsigned char   H1;     //@- Alternate H register (H')
    unsigned char   L1;     //@- Alternate L register (L')
    unsigned char   A1;     //@- Alternate A register (A')
    unsigned char   F1;     //@- Alternate flags register (F')
    unsigned        IX;     //@- Index register X
    unsigned        IY;     //@- Index register Y
    unsigned        PC;     //@- Program counter
    unsigned        SP;     //@- Stack pointer
    unsigned char   I;      //@- Interrupt register
    unsigned char   R;      //@- Refresh register

    /**
        Constructor: creates a Z80 object with the specified environment.
    */
    Z80( Z80Environment & );

    /**
        Copy constructor: creates a copy of the specified Z80 object.
    */
    Z80( const Z80 & );

    /** Destructor. */
    virtual ~Z80() {
    }

    /**
        Resets the CPU to its initial state.

        The stack pointer (SP) is set to F000h, all other registers are cleared.
    */
    virtual void reset();

    /**
        Runs the CPU for the specified number of cycles.

        Note that the number of CPU cycles performed by this function may be
        actually a little more than the value specified. If that happens then the
        function returns the number of extra cycles executed.

        @param cycles number of cycles the CPU must execute

        @return the number of extra cycles executed by the last instruction
    */
    virtual unsigned run( unsigned cycles );

    /**
        Executes one instruction.
    */
    virtual void step();

    /**
        Invokes an interrupt.

        If interrupts are enabled, the current program counter (PC) is saved on
        the stack and assigned the specified address. When the interrupt handler
        returns, execution resumes from the point where the interrupt occurred.

        The actual interrupt address depends on the current interrupt mode and 
        on the interrupt type. For maskable interrupts, data is as follows:
        - mode 0: data is an opcode that is executed (usually RST xxh);
        - mode 1: data is ignored and a call is made to address 0x38;
        - mode 2: a call is made to the 16 bit address given by (256*I + data).
    */
    void interrupt( unsigned char data );

    /** Forces a non-maskable interrupt. */
    void nmi();

    /** Returns the 16 bit register AF. */
    unsigned AF() const { 
        return ((unsigned)A << 8) | F; 
    }

    /** Returns the 16 bit register BC. */
    unsigned BC() const { 
        return ((unsigned)B << 8) | C; 
    }

    /** Returns the 16 bit register DE. */
    unsigned DE() const { 
        return ((unsigned)D << 8) | E; 
    }

    /** Returns the 16 bit register HL. */
    unsigned HL() const { 
        return ((unsigned)H << 8) | L; 
    }

    /** 
        Returns the number of Z80 CPU cycles elapsed so far. 

        The cycle count is reset to zero when reset() is called, or
        it can be set to any value with setCycles(). It is updated after
        a CPU instruction is executed, for example by calling step()
        or interrupt().
    */
    unsigned getCycles() const {
        return cycles_;
    }

    /** Sets the CPU cycle counter to the specified value. */
    void setCycles( unsigned value ) {
        cycles_ = value;
    }

    /** Returns the current interrupt mode. */
    unsigned getInterruptMode() const {
        return iflags_ & 0x03;
    }

    /** Sets the interrupt mode to the specified value. */
    void setInterruptMode( unsigned mode );

    /** Returns non-zero if the CPU is halted, otherwise zero. */
    int isHalted() const {
        return iflags_ & Halted;
    }

    /**
        Copies CPU register from one object to another.

        Note that the environment is not copied, only registers.
    */
    Z80 & operator = ( const Z80 & );

    /** Returns the size of the buffer needed to take a snapshot of the CPU. */
    unsigned getSizeOfSnapshotBuffer() const;

    /**         
        Takes a snapshot of the CPU.

        A snapshot saves all of the CPU registers and internals. It can be
        restored at any time to bring the CPU back to the exact status it
        had when the snapshot was taken.

        Note: the size of the snapshot buffer must be no less than the size
        returned by the getSizeOfSnapshotBuffer() function.

        @param buffer buffer where the snapshot data is stored

        @return the number of bytes written into the buffer
    */
    unsigned takeSnapshot( unsigned char * buffer );

    /**
        Restores a snapshot taken with takeSnapshot().

        This function uses the data saved in the snapshot buffer to restore the
        CPU status.

        @param buffer buffer where the snapshot data is stored

        @return the number of bytes read from the buffer
    */
    unsigned restoreSnapshot( unsigned char * buffer );

private:
    // Implementation of opcodes 0x00 to 0xFF
    void opcode_00();   // NOP
    void opcode_01();   // LD   BC,nn
    void opcode_02();   // LD   (BC),A
    void opcode_03();   // INC  BC
    void opcode_04();   // INC  B
    void opcode_05();   // DEC  B
    void opcode_06();   // LD   B,n
    void opcode_07();   // RLCA
    void opcode_08();   // EX   AF,AF'
    void opcode_09();   // ADD  HL,BC
    void opcode_0a();   // LD   A,(BC)
    void opcode_0b();   // DEC  BC
    void opcode_0c();   // INC  C
    void opcode_0d();   // DEC  C
    void opcode_0e();   // LD   C,n
    void opcode_0f();   // RRCA
    void opcode_10();   // DJNZ d
    void opcode_11();   // LD   DE,nn
    void opcode_12();   // LD   (DE),A
    void opcode_13();   // INC  DE
    void opcode_14();   // INC  D
    void opcode_15();   // DEC  D
    void opcode_16();   // LD   D,n
    void opcode_17();   // RLA
    void opcode_18();   // JR   d
    void opcode_19();   // ADD  HL,DE
    void opcode_1a();   // LD   A,(DE)
    void opcode_1b();   // DEC  DE
    void opcode_1c();   // INC  E
    void opcode_1d();   // DEC  E
    void opcode_1e();   // LD   E,n
    void opcode_1f();   // RRA
    void opcode_20();   // JR   NZ,d
    void opcode_21();   // LD   HL,nn
    void opcode_22();   // LD   (nn),HL
    void opcode_23();   // INC  HL
    void opcode_24();   // INC  H
    void opcode_25();   // DEC  H
    void opcode_26();   // LD   H,n
    void opcode_27();   // DAA
    void opcode_28();   // JR   Z,d
    void opcode_29();   // ADD  HL,HL
    void opcode_2a();   // LD   HL,(nn)
    void opcode_2b();   // DEC  HL
    void opcode_2c();   // INC  L
    void opcode_2d();   // DEC  L
    void opcode_2e();   // LD   L,n
    void opcode_2f();   // CPL
    void opcode_30();   // JR   NC,d
    void opcode_31();   // LD   SP,nn
    void opcode_32();   // LD   (nn),A
    void opcode_33();   // INC  SP
    void opcode_34();   // INC  (HL)
    void opcode_35();   // DEC  (HL)
    void opcode_36();   // LD   (HL),n
    void opcode_37();   // SCF
    void opcode_38();   // JR   C,d
    void opcode_39();   // ADD  HL,SP
    void opcode_3a();   // LD   A,(nn)
    void opcode_3b();   // DEC  SP
    void opcode_3c();   // INC  A
    void opcode_3d();   // DEC  A
    void opcode_3e();   // LD   A,n
    void opcode_3f();   // CCF
    void opcode_40();   // LD   B,B
    void opcode_41();   // LD   B,C
    void opcode_42();   // LD   B,D
    void opcode_43();   // LD   B,E
    void opcode_44();   // LD   B,H
    void opcode_45();   // LD   B,L
    void opcode_46();   // LD   B,(HL)
    void opcode_47();   // LD   B,A
    void opcode_48();   // LD   C,B
    void opcode_49();   // LD   C,C
    void opcode_4a();   // LD   C,D
    void opcode_4b();   // LD   C,E
    void opcode_4c();   // LD   C,H
    void opcode_4d();   // LD   C,L
    void opcode_4e();   // LD   C,(HL)
    void opcode_4f();   // LD   C,A
    void opcode_50();   // LD   D,B
    void opcode_51();   // LD   D,C
    void opcode_52();   // LD   D,D
    void opcode_53();   // LD   D,E
    void opcode_54();   // LD   D,H
    void opcode_55();   // LD   D,L
    void opcode_56();   // LD   D,(HL)
    void opcode_57();   // LD   D,A
    void opcode_58();   // LD   E,B
    void opcode_59();   // LD   E,C
    void opcode_5a();   // LD   E,D
    void opcode_5b();   // LD   E,E
    void opcode_5c();   // LD   E,H
    void opcode_5d();   // LD   E,L
    void opcode_5e();   // LD   E,(HL)
    void opcode_5f();   // LD   E,A
    void opcode_60();   // LD   H,B
    void opcode_61();   // LD   H,C
    void opcode_62();   // LD   H,D
    void opcode_63();   // LD   H,E
    void opcode_64();   // LD   H,H
    void opcode_65();   // LD   H,L
    void opcode_66();   // LD   H,(HL)
    void opcode_67();   // LD   H,A
    void opcode_68();   // LD   L,B
    void opcode_69();   // LD   L,C
    void opcode_6a();   // LD   L,D
    void opcode_6b();   // LD   L,E
    void opcode_6c();   // LD   L,H
    void opcode_6d();   // LD   L,L
    void opcode_6e();   // LD   L,(HL)
    void opcode_6f();   // LD   L,A
    void opcode_70();   // LD   (HL),B
    void opcode_71();   // LD   (HL),C
    void opcode_72();   // LD   (HL),D
    void opcode_73();   // LD   (HL),E
    void opcode_74();   // LD   (HL),H
    void opcode_75();   // LD   (HL),L
    void opcode_76();   // HALT
    void opcode_77();   // LD   (HL),A
    void opcode_78();   // LD   A,B
    void opcode_79();   // LD   A,C
    void opcode_7a();   // LD   A,D
    void opcode_7b();   // LD   A,E
    void opcode_7c();   // LD   A,H
    void opcode_7d();   // LD   A,L
    void opcode_7e();   // LD   A,(HL)
    void opcode_7f();   // LD   A,A
    void opcode_80();   // ADD  A,B
    void opcode_81();   // ADD  A,C
    void opcode_82();   // ADD  A,D
    void opcode_83();   // ADD  A,E
    void opcode_84();   // ADD  A,H
    void opcode_85();   // ADD  A,L
    void opcode_86();   // ADD  A,(HL)
    void opcode_87();   // ADD  A,A
    void opcode_88();   // ADC  A,B
    void opcode_89();   // ADC  A,C
    void opcode_8a();   // ADC  A,D
    void opcode_8b();   // ADC  A,E
    void opcode_8c();   // ADC  A,H
    void opcode_8d();   // ADC  A,L
    void opcode_8e();   // ADC  A,(HL)
    void opcode_8f();   // ADC  A,A
    void opcode_90();   // SUB  B
    void opcode_91();   // SUB  C
    void opcode_92();   // SUB  D
    void opcode_93();   // SUB  E
    void opcode_94();   // SUB  H
    void opcode_95();   // SUB  L
    void opcode_96();   // SUB  (HL)
    void opcode_97();   // SUB  A
    void opcode_98();   // SBC  A,B
    void opcode_99();   // SBC  A,C
    void opcode_9a();   // SBC  A,D
    void opcode_9b();   // SBC  A,E
    void opcode_9c();   // SBC  A,H
    void opcode_9d();   // SBC  A,L
    void opcode_9e();   // SBC  A,(HL)
    void opcode_9f();   // SBC  A,A
    void opcode_a0();   // AND  B
    void opcode_a1();   // AND  C
    void opcode_a2();   // AND  D
    void opcode_a3();   // AND  E
    void opcode_a4();   // AND  H
    void opcode_a5();   // AND  L
    void opcode_a6();   // AND  (HL)
    void opcode_a7();   // AND  A
    void opcode_a8();   // XOR  B
    void opcode_a9();   // XOR  C
    void opcode_aa();   // XOR  D
    void opcode_ab();   // XOR  E
    void opcode_ac();   // XOR  H
    void opcode_ad();   // XOR  L
    void opcode_ae();   // XOR  (HL)
    void opcode_af();   // XOR  A
    void opcode_b0();   // OR   B
    void opcode_b1();   // OR   C
    void opcode_b2();   // OR   D
    void opcode_b3();   // OR   E
    void opcode_b4();   // OR   H
    void opcode_b5();   // OR   L
    void opcode_b6();   // OR   (HL)
    void opcode_b7();   // OR   A
    void opcode_b8();   // CP   B
    void opcode_b9();   // CP   C
    void opcode_ba();   // CP   D
    void opcode_bb();   // CP   E
    void opcode_bc();   // CP   H
    void opcode_bd();   // CP   L
    void opcode_be();   // CP   (HL)
    void opcode_bf();   // CP   A
    void opcode_c0();   // RET  NZ
    void opcode_c1();   // POP  BC
    void opcode_c2();   // JP   NZ,nn
    void opcode_c3();   // JP   nn
    void opcode_c4();   // CALL NZ,nn
    void opcode_c5();   // PUSH BC
    void opcode_c6();   // ADD  A,n
    void opcode_c7();   // RST  0
    void opcode_c8();   // RET  Z
    void opcode_c9();   // RET
    void opcode_ca();   // JP   Z,nn
    void opcode_cb();   // [Prefix]
    void opcode_cc();   // CALL Z,nn
    void opcode_cd();   // CALL nn
    void opcode_ce();   // ADC  A,n
    void opcode_cf();   // RST  8
    void opcode_d0();   // RET  NC
    void opcode_d1();   // POP  DE
    void opcode_d2();   // JP   NC,nn
    void opcode_d3();   // OUT  (n),A
    void opcode_d4();   // CALL NC,nn
    void opcode_d5();   // PUSH DE
    void opcode_d6();   // SUB  n
    void opcode_d7();   // RST  10H
    void opcode_d8();   // RET  C
    void opcode_d9();   // EXX
    void opcode_da();   // JP   C,nn
    void opcode_db();   // IN   A,(n)
    void opcode_dc();   // CALL C,nn
    void opcode_dd();   // [IX Prefix]
    void opcode_de();   // SBC  A,n
    void opcode_df();   // RST  18H
    void opcode_e0();   // RET  PO
    void opcode_e1();   // POP  HL
    void opcode_e2();   // JP   PO,nn
    void opcode_e3();   // EX   (SP),HL
    void opcode_e4();   // CALL PO,nn
    void opcode_e5();   // PUSH HL
    void opcode_e6();   // AND  n
    void opcode_e7();   // RST  20H
    void opcode_e8();   // RET  PE
    void opcode_e9();   // JP   (HL)
    void opcode_ea();   // JP   PE,nn
    void opcode_eb();   // EX   DE,HL
    void opcode_ec();   // CALL PE,nn
    void opcode_ed();   // [Prefix]
    void opcode_ee();   // XOR  n
    void opcode_ef();   // RST  28H
    void opcode_f0();   // RET  P
    void opcode_f1();   // POP  AF
    void opcode_f2();   // JP   P,nn
    void opcode_f3();   // DI
    void opcode_f4();   // CALL P,nn
    void opcode_f5();   // PUSH AF
    void opcode_f6();   // OR   n
    void opcode_f7();   // RST  30H
    void opcode_f8();   // RET  M
    void opcode_f9();   // LD   SP,HL
    void opcode_fa();   // JP   M,nn
    void opcode_fb();   // EI
    void opcode_fc();   // CALL M,nn
    void opcode_fd();   // [IY Prefix]
    void opcode_fe();   // CP   n
    void opcode_ff();   // RST  38H
                        
    // Handlers for the 0xCB prefix
    void opcode_cb_00();    // RLC B
    void opcode_cb_01();    // RLC C
    void opcode_cb_02();    // RLC D
    void opcode_cb_03();    // RLC E
    void opcode_cb_04();    // RLC H
    void opcode_cb_05();    // RLC L
    void opcode_cb_06();    // RLC (HL)
    void opcode_cb_07();    // RLC A
    void opcode_cb_08();    // RRC B
    void opcode_cb_09();    // RRC C
    void opcode_cb_0a();    // RRC D
    void opcode_cb_0b();    // RRC E
    void opcode_cb_0c();    // RRC H
    void opcode_cb_0d();    // RRC L
    void opcode_cb_0e();    // RRC (HL)
    void opcode_cb_0f();    // RRC A
    void opcode_cb_10();    // RL B
    void opcode_cb_11();    // RL C
    void opcode_cb_12();    // RL D
    void opcode_cb_13();    // RL E
    void opcode_cb_14();    // RL H
    void opcode_cb_15();    // RL L
    void opcode_cb_16();    // RL (HL)
    void opcode_cb_17();    // RL A
    void opcode_cb_18();    // RR B
    void opcode_cb_19();    // RR C
    void opcode_cb_1a();    // RR D
    void opcode_cb_1b();    // RR E
    void opcode_cb_1c();    // RR H
    void opcode_cb_1d();    // RR L
    void opcode_cb_1e();    // RR (HL)
    void opcode_cb_1f();    // RR A
    void opcode_cb_20();    // SLA B
    void opcode_cb_21();    // SLA C
    void opcode_cb_22();    // SLA D
    void opcode_cb_23();    // SLA E
    void opcode_cb_24();    // SLA H
    void opcode_cb_25();    // SLA L
    void opcode_cb_26();    // SLA (HL)
    void opcode_cb_27();    // SLA A
    void opcode_cb_28();    // SRA B
    void opcode_cb_29();    // SRA C
    void opcode_cb_2a();    // SRA D
    void opcode_cb_2b();    // SRA E
    void opcode_cb_2c();    // SRA H
    void opcode_cb_2d();    // SRA L
    void opcode_cb_2e();    // SRA (HL)
    void opcode_cb_2f();    // SRA A
    void opcode_cb_30();    // SLL B    [undocumented]
    void opcode_cb_31();    // SLL C    [undocumented]
    void opcode_cb_32();    // SLL D    [undocumented]
    void opcode_cb_33();    // SLL E    [undocumented]
    void opcode_cb_34();    // SLL H    [undocumented]
    void opcode_cb_35();    // SLL L    [undocumented]
    void opcode_cb_36();    // SLL (HL) [undocumented]
    void opcode_cb_37();    // SLL A    [undocumented]
    void opcode_cb_38();    // SRL B
    void opcode_cb_39();    // SRL C
    void opcode_cb_3a();    // SRL D
    void opcode_cb_3b();    // SRL E
    void opcode_cb_3c();    // SRL H
    void opcode_cb_3d();    // SRL L
    void opcode_cb_3e();    // SRL (HL)
    void opcode_cb_3f();    // SRL A
    void opcode_cb_40();    // BIT 0, B
    void opcode_cb_41();    // BIT 0, C
    void opcode_cb_42();    // BIT 0, D
    void opcode_cb_43();    // BIT 0, E
    void opcode_cb_44();    // BIT 0, H
    void opcode_cb_45();    // BIT 0, L
    void opcode_cb_46();    // BIT 0, (HL)
    void opcode_cb_47();    // BIT 0, A
    void opcode_cb_48();    // BIT 1, B
    void opcode_cb_49();    // BIT 1, C
    void opcode_cb_4a();    // BIT 1, D
    void opcode_cb_4b();    // BIT 1, E
    void opcode_cb_4c();    // BIT 1, H
    void opcode_cb_4d();    // BIT 1, L
    void opcode_cb_4e();    // BIT 1, (HL)
    void opcode_cb_4f();    // BIT 1, A
    void opcode_cb_50();    // BIT 2, B
    void opcode_cb_51();    // BIT 2, C
    void opcode_cb_52();    // BIT 2, D
    void opcode_cb_53();    // BIT 2, E
    void opcode_cb_54();    // BIT 2, H
    void opcode_cb_55();    // BIT 2, L
    void opcode_cb_56();    // BIT 2, (HL)
    void opcode_cb_57();    // BIT 2, A
    void opcode_cb_58();    // BIT 3, B
    void opcode_cb_59();    // BIT 3, C
    void opcode_cb_5a();    // BIT 3, D
    void opcode_cb_5b();    // BIT 3, E
    void opcode_cb_5c();    // BIT 3, H
    void opcode_cb_5d();    // BIT 3, L
    void opcode_cb_5e();    // BIT 3, (HL)
    void opcode_cb_5f();    // BIT 3, A
    void opcode_cb_60();    // BIT 4, B
    void opcode_cb_61();    // BIT 4, C
    void opcode_cb_62();    // BIT 4, D
    void opcode_cb_63();    // BIT 4, E
    void opcode_cb_64();    // BIT 4, H
    void opcode_cb_65();    // BIT 4, L
    void opcode_cb_66();    // BIT 4, (HL)
    void opcode_cb_67();    // BIT 4, A
    void opcode_cb_68();    // BIT 5, B
    void opcode_cb_69();    // BIT 5, C
    void opcode_cb_6a();    // BIT 5, D
    void opcode_cb_6b();    // BIT 5, E
    void opcode_cb_6c();    // BIT 5, H
    void opcode_cb_6d();    // BIT 5, L
    void opcode_cb_6e();    // BIT 5, (HL)
    void opcode_cb_6f();    // BIT 5, A
    void opcode_cb_70();    // BIT 6, B
    void opcode_cb_71();    // BIT 6, C
    void opcode_cb_72();    // BIT 6, D
    void opcode_cb_73();    // BIT 6, E
    void opcode_cb_74();    // BIT 6, H
    void opcode_cb_75();    // BIT 6, L
    void opcode_cb_76();    // BIT 6, (HL)
    void opcode_cb_77();    // BIT 6, A
    void opcode_cb_78();    // BIT 7, B
    void opcode_cb_79();    // BIT 7, C
    void opcode_cb_7a();    // BIT 7, D
    void opcode_cb_7b();    // BIT 7, E
    void opcode_cb_7c();    // BIT 7, H
    void opcode_cb_7d();    // BIT 7, L
    void opcode_cb_7e();    // BIT 7, (HL)
    void opcode_cb_7f();    // BIT 7, A
    void opcode_cb_80();    // RES 0, B
    void opcode_cb_81();    // RES 0, C
    void opcode_cb_82();    // RES 0, D
    void opcode_cb_83();    // RES 0, E
    void opcode_cb_84();    // RES 0, H
    void opcode_cb_85();    // RES 0, L
    void opcode_cb_86();    // RES 0, (HL)
    void opcode_cb_87();    // RES 0, A
    void opcode_cb_88();    // RES 1, B
    void opcode_cb_89();    // RES 1, C
    void opcode_cb_8a();    // RES 1, D
    void opcode_cb_8b();    // RES 1, E
    void opcode_cb_8c();    // RES 1, H
    void opcode_cb_8d();    // RES 1, L
    void opcode_cb_8e();    // RES 1, (HL)
    void opcode_cb_8f();    // RES 1, A
    void opcode_cb_90();    // RES 2, B
    void opcode_cb_91();    // RES 2, C
    void opcode_cb_92();    // RES 2, D
    void opcode_cb_93();    // RES 2, E
    void opcode_cb_94();    // RES 2, H
    void opcode_cb_95();    // RES 2, L
    void opcode_cb_96();    // RES 2, (HL)
    void opcode_cb_97();    // RES 2, A
    void opcode_cb_98();    // RES 3, B
    void opcode_cb_99();    // RES 3, C
    void opcode_cb_9a();    // RES 3, D
    void opcode_cb_9b();    // RES 3, E
    void opcode_cb_9c();    // RES 3, H
    void opcode_cb_9d();    // RES 3, L
    void opcode_cb_9e();    // RES 3, (HL)
    void opcode_cb_9f();    // RES 3, A
    void opcode_cb_a0();    // RES 4, B
    void opcode_cb_a1();    // RES 4, C
    void opcode_cb_a2();    // RES 4, D
    void opcode_cb_a3();    // RES 4, E
    void opcode_cb_a4();    // RES 4, H
    void opcode_cb_a5();    // RES 4, L
    void opcode_cb_a6();    // RES 4, (HL)
    void opcode_cb_a7();    // RES 4, A
    void opcode_cb_a8();    // RES 5, B
    void opcode_cb_a9();    // RES 5, C
    void opcode_cb_aa();    // RES 5, D
    void opcode_cb_ab();    // RES 5, E
    void opcode_cb_ac();    // RES 5, H
    void opcode_cb_ad();    // RES 5, L
    void opcode_cb_ae();    // RES 5, (HL)
    void opcode_cb_af();    // RES 5, A
    void opcode_cb_b0();    // RES 6, B
    void opcode_cb_b1();    // RES 6, C
    void opcode_cb_b2();    // RES 6, D
    void opcode_cb_b3();    // RES 6, E
    void opcode_cb_b4();    // RES 6, H
    void opcode_cb_b5();    // RES 6, L
    void opcode_cb_b6();    // RES 6, (HL)
    void opcode_cb_b7();    // RES 6, A
    void opcode_cb_b8();    // RES 7, B
    void opcode_cb_b9();    // RES 7, C
    void opcode_cb_ba();    // RES 7, D
    void opcode_cb_bb();    // RES 7, E
    void opcode_cb_bc();    // RES 7, H
    void opcode_cb_bd();    // RES 7, L
    void opcode_cb_be();    // RES 7, (HL)
    void opcode_cb_bf();    // RES 7, A
    void opcode_cb_c0();    // SET 0, B
    void opcode_cb_c1();    // SET 0, C
    void opcode_cb_c2();    // SET 0, D
    void opcode_cb_c3();    // SET 0, E
    void opcode_cb_c4();    // SET 0, H
    void opcode_cb_c5();    // SET 0, L
    void opcode_cb_c6();    // SET 0, (HL)
    void opcode_cb_c7();    // SET 0, A
    void opcode_cb_c8();    // SET 1, B
    void opcode_cb_c9();    // SET 1, C
    void opcode_cb_ca();    // SET 1, D
    void opcode_cb_cb();    // SET 1, E
    void opcode_cb_cc();    // SET 1, H
    void opcode_cb_cd();    // SET 1, L
    void opcode_cb_ce();    // SET 1, (HL)
    void opcode_cb_cf();    // SET 1, A
    void opcode_cb_d0();    // SET 2, B
    void opcode_cb_d1();    // SET 2, C
    void opcode_cb_d2();    // SET 2, D
    void opcode_cb_d3();    // SET 2, E
    void opcode_cb_d4();    // SET 2, H
    void opcode_cb_d5();    // SET 2, L
    void opcode_cb_d6();    // SET 2, (HL)
    void opcode_cb_d7();    // SET 2, A
    void opcode_cb_d8();    // SET 3, B
    void opcode_cb_d9();    // SET 3, C
    void opcode_cb_da();    // SET 3, D
    void opcode_cb_db();    // SET 3, E
    void opcode_cb_dc();    // SET 3, H
    void opcode_cb_dd();    // SET 3, L
    void opcode_cb_de();    // SET 3, (HL)
    void opcode_cb_df();    // SET 3, A
    void opcode_cb_e0();    // SET 4, B
    void opcode_cb_e1();    // SET 4, C
    void opcode_cb_e2();    // SET 4, D
    void opcode_cb_e3();    // SET 4, E
    void opcode_cb_e4();    // SET 4, H
    void opcode_cb_e5();    // SET 4, L
    void opcode_cb_e6();    // SET 4, (HL)
    void opcode_cb_e7();    // SET 4, A
    void opcode_cb_e8();    // SET 5, B
    void opcode_cb_e9();    // SET 5, C
    void opcode_cb_ea();    // SET 5, D
    void opcode_cb_eb();    // SET 5, E
    void opcode_cb_ec();    // SET 5, H
    void opcode_cb_ed();    // SET 5, L
    void opcode_cb_ee();    // SET 5, (HL)
    void opcode_cb_ef();    // SET 5, A
    void opcode_cb_f0();    // SET 6, B
    void opcode_cb_f1();    // SET 6, C
    void opcode_cb_f2();    // SET 6, D
    void opcode_cb_f3();    // SET 6, E
    void opcode_cb_f4();    // SET 6, H
    void opcode_cb_f5();    // SET 6, L
    void opcode_cb_f6();    // SET 6, (HL)
    void opcode_cb_f7();    // SET 6, A
    void opcode_cb_f8();    // SET 7, B
    void opcode_cb_f9();    // SET 7, C
    void opcode_cb_fa();    // SET 7, D
    void opcode_cb_fb();    // SET 7, E
    void opcode_cb_fc();    // SET 7, H
    void opcode_cb_fd();    // SET 7, L
    void opcode_cb_fe();    // SET 7, (HL)
    void opcode_cb_ff();    // SET 7, A

    // Handlers for the 0xED prefix
    void opcode_ed_40();    // IN B, (C)
    void opcode_ed_41();    // OUT (C), B
    void opcode_ed_42();    // SBC HL, BC
    void opcode_ed_43();    // LD (nn), BC
    void opcode_ed_44();    // NEG
    void opcode_ed_45();    // RETN
    void opcode_ed_46();    // IM 0
    void opcode_ed_47();    // LD I, A
    void opcode_ed_48();    // IN C, (C)
    void opcode_ed_49();    // OUT (C), C
    void opcode_ed_4a();    // ADC HL, BC
    void opcode_ed_4b();    // LD BC, (nn)
    void opcode_ed_4c();    // NEG      [undocumented]
    void opcode_ed_4d();    // RETI
    void opcode_ed_4e();    // IM 0/1   [undocumented]
    void opcode_ed_4f();    // LD R, A
    void opcode_ed_50();    // IN D, (C)
    void opcode_ed_51();    // OUT (C), D
    void opcode_ed_52();    // SBC HL, DE
    void opcode_ed_53();    // LD (nn), DE
    void opcode_ed_54();    // NEG      [undocumented]
    void opcode_ed_55();    // RETN     [undocumented]
    void opcode_ed_56();    // IM 1
    void opcode_ed_57();    // LD A, I
    void opcode_ed_58();    // IN E, (C)
    void opcode_ed_59();    // OUT (C), E
    void opcode_ed_5a();    // ADC HL, DE
    void opcode_ed_5b();    // LD DE, (nn)
    void opcode_ed_5c();    // NEG      [undocumented]
    void opcode_ed_5d();    // RETN     [undocumented]
    void opcode_ed_5e();    // IM 2
    void opcode_ed_5f();    // LD A, R
    void opcode_ed_60();    // IN H, (C)
    void opcode_ed_61();    // OUT (C), H
    void opcode_ed_62();    // SBC HL, HL
    void opcode_ed_63();    // LD (nn), HL
    void opcode_ed_64();    // NEG      [undocumented]
    void opcode_ed_65();    // RETN     [undocumented]
    void opcode_ed_66();    // IM 0     [undocumented]
    void opcode_ed_67();    // RRD
    void opcode_ed_68();    // IN L, (C)
    void opcode_ed_69();    // OUT (C), L
    void opcode_ed_6a();    // ADC HL, HL
    void opcode_ed_6b();    // LD HL, (nn)
    void opcode_ed_6c();    // NEG      [undocumented]
    void opcode_ed_6d();    // RETN     [undocumented]
    void opcode_ed_6e();    // IM 0/1   [undocumented]
    void opcode_ed_6f();    // RLD
    void opcode_ed_70();    // IN (C)/IN F, (C) [undocumented]
    void opcode_ed_71();    // OUT (C), 0       [undocumented]
    void opcode_ed_72();    // SBC HL, SP
    void opcode_ed_73();    // LD (nn), SP
    void opcode_ed_74();    // NEG      [undocumented]
    void opcode_ed_75();    // RETN     [undocumented]
    void opcode_ed_76();    // IM 1     [undocumented]
    void opcode_ed_78();    // IN A, (C)
    void opcode_ed_79();    // OUT (C), A
    void opcode_ed_7a();    // ADC HL, SP
    void opcode_ed_7b();    // nLD SP, (nn)
    void opcode_ed_7c();    // NEG      [undocumented]
    void opcode_ed_7d();    // RETN     [undocumented]
    void opcode_ed_7e();    // IM 2     [undocumented]
    void opcode_ed_a0();    // LDI
    void opcode_ed_a1();    // CPI
    void opcode_ed_a2();    // INI
    void opcode_ed_a3();    // OUTI
    void opcode_ed_a8();    // LDD
    void opcode_ed_a9();    // CPD
    void opcode_ed_aa();    // IND
    void opcode_ed_ab();    // OUTD
    void opcode_ed_b0();    // LDIR
    void opcode_ed_b1();    // CPIR
    void opcode_ed_b2();    // INIR
    void opcode_ed_b3();    // OTIR
    void opcode_ed_b8();    // LDDR
    void opcode_ed_b9();    // CPDR
    void opcode_ed_ba();    // INDR
    void opcode_ed_bb();    // OTDR

    // Handlers for the 0xDD prefix (IX)
    void opcode_dd_09();    // ADD IX, BC
    void opcode_dd_19();    // ADD IX, DE
    void opcode_dd_21();    // LD IX, nn
    void opcode_dd_22();    // LD (nn), IX
    void opcode_dd_23();    // INC IX
    void opcode_dd_24();    // INC IXH      [undocumented]
    void opcode_dd_25();    // DEC IXH      [undocumented]
    void opcode_dd_26();    // LD IXH, n    [undocumented]
    void opcode_dd_29();    // ADD IX, IX
    void opcode_dd_2a();    // LD IX, (nn)
    void opcode_dd_2b();    // DEC IX
    void opcode_dd_2c();    // INC IXL      [undocumented]
    void opcode_dd_2d();    // DEC IXL      [undocumented]
    void opcode_dd_2e();    // LD IXL, n    [undocumented]
    void opcode_dd_34();    // INC (IX + d)
    void opcode_dd_35();    // DEC (IX + d)
    void opcode_dd_36();    // LD (IX + d), n
    void opcode_dd_39();    // ADD IX, SP
    void opcode_dd_44();    // LD B, IXH    [undocumented]
    void opcode_dd_45();    // LD B, IXL    [undocumented]
    void opcode_dd_46();    // LD B, (IX + d)
    void opcode_dd_4c();    // LD C, IXH    [undocumented]
    void opcode_dd_4d();    // LD C, IXL    [undocumented]
    void opcode_dd_4e();    // LD C, (IX + d)
    void opcode_dd_54();    // LD D, IXH    [undocumented]
    void opcode_dd_55();    // LD D, IXL    [undocumented]
    void opcode_dd_56();    // LD D, (IX + d)
    void opcode_dd_5c();    // LD E, IXH    [undocumented]
    void opcode_dd_5d();    // LD E, IXL    [undocumented]
    void opcode_dd_5e();    // LD E, (IX + d)
    void opcode_dd_60();    // LD IXH, B    [undocumented]
    void opcode_dd_61();    // LD IXH, C    [undocumented]
    void opcode_dd_62();    // LD IXH, D    [undocumented]
    void opcode_dd_63();    // LD IXH, E    [undocumented]
    void opcode_dd_64();    // LD IXH, IXH  [undocumented]
    void opcode_dd_65();    // LD IXH, IXL  [undocumented]
    void opcode_dd_66();    // LD H, (IX + d)
    void opcode_dd_67();    // LD IXH, A    [undocumented]
    void opcode_dd_68();    // LD IXL, B    [undocumented]
    void opcode_dd_69();    // LD IXL, C    [undocumented]
    void opcode_dd_6a();    // LD IXL, D    [undocumented]
    void opcode_dd_6b();    // LD IXL, E    [undocumented]
    void opcode_dd_6c();    // LD IXL, IXH  [undocumented]
    void opcode_dd_6d();    // LD IXL, IXL  [undocumented]
    void opcode_dd_6e();    // LD L, (IX + d)
    void opcode_dd_6f();    // LD IXL, A    [undocumented]
    void opcode_dd_70();    // LD (IX + d), B
    void opcode_dd_71();    // LD (IX + d), C
    void opcode_dd_72();    // LD (IX + d), D
    void opcode_dd_73();    // LD (IX + d), E
    void opcode_dd_74();    // LD (IX + d), H
    void opcode_dd_75();    // LD (IX + d), L
    void opcode_dd_77();    // LD (IX + d), A
    void opcode_dd_7c();    // LD A, IXH    [undocumented]
    void opcode_dd_7d();    // LD A, IXL    [undocumented]
    void opcode_dd_7e();    // LD A, (IX + d)
    void opcode_dd_84();    // ADD A, IXH   [undocumented]
    void opcode_dd_85();    // ADD A, IXL   [undocumented]
    void opcode_dd_86();    // ADD A, (IX + d)
    void opcode_dd_8c();    // ADC A, IXH   [undocumented]
    void opcode_dd_8d();    // ADC A, IXL   [undocumented]
    void opcode_dd_8e();    // ADC A, (IX + d)
    void opcode_dd_94();    // SUB IXH      [undocumented]
    void opcode_dd_95();    // SUB IXL      [undocumented]
    void opcode_dd_96();    // SUB (IX + d)
    void opcode_dd_9c();    // SBC A, IXH   [undocumented]
    void opcode_dd_9d();    // SBC A, IXL   [undocumented]
    void opcode_dd_9e();    // SBC A, (IX + d)
    void opcode_dd_a4();    // AND IXH      [undocumented]
    void opcode_dd_a5();    // AND IXL      [undocumented]
    void opcode_dd_a6();    // AND (IX + d)
    void opcode_dd_ac();    // XOR IXH      [undocumented]
    void opcode_dd_ad();    // XOR IXL      [undocumented]
    void opcode_dd_ae();    // XOR (IX + d)
    void opcode_dd_b4();    // OR IXH       [undocumented]
    void opcode_dd_b5();    // OR IXL       [undocumented]
    void opcode_dd_b6();    // OR (IX + d)
    void opcode_dd_bc();    // CP IXH       [undocumented]
    void opcode_dd_bd();    // CP IXL       [undocumented]
    void opcode_dd_be();    // CP (IX + d)
    void opcode_dd_cb();    // 
    void opcode_dd_e1();    // POP IX
    void opcode_dd_e3();    // EX (SP), IX
    void opcode_dd_e5();    // PUSH IX
    void opcode_dd_e9();    // JP (IX)
    void opcode_dd_f9();    // LD SP, IX

    // Handlers for the 0xFD prefix (IY)
    void opcode_fd_09();    // ADD IY, BC
    void opcode_fd_19();    // ADD IY, DE
    void opcode_fd_21();    // LD IY, nn
    void opcode_fd_22();    // LD (nn), IY
    void opcode_fd_23();    // INC IY
    void opcode_fd_24();    // INC IYH      [undocumented]
    void opcode_fd_25();    // DEC IYH      [undocumented]
    void opcode_fd_26();    // LD IYH, n    [undocumented]
    void opcode_fd_29();    // ADD IY, IY
    void opcode_fd_2a();    // LD IY, (nn)
    void opcode_fd_2b();    // DEC IY
    void opcode_fd_2c();    // INC IYL      [undocumented]
    void opcode_fd_2d();    // DEC IYL      [undocumented]
    void opcode_fd_2e();    // LD IYL, n    [undocumented]
    void opcode_fd_34();    // INC (IY + d)
    void opcode_fd_35();    // DEC (IY + d)
    void opcode_fd_36();    // LD (IY + d), n
    void opcode_fd_39();    // ADD IY, SP
    void opcode_fd_44();    // LD B, IYH    [undocumented]
    void opcode_fd_45();    // LD B, IYL    [undocumented]
    void opcode_fd_46();    // LD B, (IY + d)
    void opcode_fd_4c();    // LD C, IYH    [undocumented]
    void opcode_fd_4d();    // LD C, IYL    [undocumented]
    void opcode_fd_4e();    // LD C, (IY + d)
    void opcode_fd_54();    // LD D, IYH    [undocumented]
    void opcode_fd_55();    // LD D, IYL    [undocumented]
    void opcode_fd_56();    // LD D, (IY + d)
    void opcode_fd_5c();    // LD E, IYH    [undocumented]
    void opcode_fd_5d();    // LD E, IYL    [undocumented]
    void opcode_fd_5e();    // LD E, (IY + d)
    void opcode_fd_60();    // LD IYH, B    [undocumented]
    void opcode_fd_61();    // LD IYH, C    [undocumented]
    void opcode_fd_62();    // LD IYH, D    [undocumented]
    void opcode_fd_63();    // LD IYH, E    [undocumented]
    void opcode_fd_64();    // LD IYH, IYH  [undocumented]
    void opcode_fd_65();    // LD IYH, IYL  [undocumented]
    void opcode_fd_66();    // LD H, (IY + d)
    void opcode_fd_67();    // LD IYH, A    [undocumented]
    void opcode_fd_68();    // LD IYL, B    [undocumented]
    void opcode_fd_69();    // LD IYL, C    [undocumented]
    void opcode_fd_6a();    // LD IYL, D    [undocumented]
    void opcode_fd_6b();    // LD IYL, E    [undocumented]
    void opcode_fd_6c();    // LD IYL, IYH  [undocumented]
    void opcode_fd_6d();    // LD IYL, IYL  [undocumented]
    void opcode_fd_6e();    // LD L, (IY + d)
    void opcode_fd_6f();    // LD IYL, A    [undocumented]
    void opcode_fd_70();    // LD (IY + d), B
    void opcode_fd_71();    // LD (IY + d), C
    void opcode_fd_72();    // LD (IY + d), D
    void opcode_fd_73();    // LD (IY + d), E
    void opcode_fd_74();    // LD (IY + d), H
    void opcode_fd_75();    // LD (IY + d), L
    void opcode_fd_77();    // LD (IY + d), A
    void opcode_fd_7c();    // LD A, IYH    [undocumented]
    void opcode_fd_7d();    // LD A, IYL    [undocumented]
    void opcode_fd_7e();    // LD A, (IY + d)
    void opcode_fd_84();    // ADD A, IYH   [undocumented]
    void opcode_fd_85();    // ADD A, IYL   [undocumented]
    void opcode_fd_86();    // ADD A, (IY + d)
    void opcode_fd_8c();    // ADC A, IYH   [undocumented]
    void opcode_fd_8d();    // ADC A, IYL   [undocumented]
    void opcode_fd_8e();    // ADC A, (IY + d)
    void opcode_fd_94();    // SUB IYH      [undocumented]
    void opcode_fd_95();    // SUB IYL      [undocumented]
    void opcode_fd_96();    // SUB (IY + d)
    void opcode_fd_9c();    // SBC A, IYH   [undocumented]
    void opcode_fd_9d();    // SBC A, IYL   [undocumented]
    void opcode_fd_9e();    // SBC A, (IY + d)
    void opcode_fd_a4();    // AND IYH      [undocumented]
    void opcode_fd_a5();    // AND IYL      [undocumented]
    void opcode_fd_a6();    // AND (IY + d)
    void opcode_fd_ac();    // XOR IYH      [undocumented]
    void opcode_fd_ad();    // XOR IYL      [undocumented]
    void opcode_fd_ae();    // XOR (IY + d)
    void opcode_fd_b4();    // OR IYH       [undocumented]
    void opcode_fd_b5();    // OR IYL       [undocumented]
    void opcode_fd_b6();    // OR (IY + d)
    void opcode_fd_bc();    // CP IYH       [undocumented]
    void opcode_fd_bd();    // CP IYL       [undocumented]
    void opcode_fd_be();    // CP (IY + d)
    void opcode_fd_cb();    // 
    void opcode_fd_e1();    // POP IY
    void opcode_fd_e3();    // EX (SP), IY
    void opcode_fd_e5();    // PUSH IY
    void opcode_fd_e9();    // JP (IY)
    void opcode_fd_f9();    // LD SP, IY

    // Handlers for 0xDDCB and 0xFDCB prefixes
    void opcode_xycb_00( unsigned );    // LD B, RLC (IX + d)   [undocumented]   
    void opcode_xycb_01( unsigned );    // LD C, RLC (IX + d)   [undocumented]
    void opcode_xycb_02( unsigned );    // LD D, RLC (IX + d)   [undocumented]
    void opcode_xycb_03( unsigned );    // LD E, RLC (IX + d)   [undocumented]
    void opcode_xycb_04( unsigned );    // LD H, RLC (IX + d)   [undocumented]
    void opcode_xycb_05( unsigned );    // LD L, RLC (IX + d)   [undocumented]
    void opcode_xycb_06( unsigned );    // RLC (IX + d)
    void opcode_xycb_07( unsigned );    // LD A, RLC (IX + d)   [undocumented]
    void opcode_xycb_08( unsigned );    // LD B, RRC (IX + d)   [undocumented]
    void opcode_xycb_09( unsigned );    // LD C, RRC (IX + d)   [undocumented]
    void opcode_xycb_0a( unsigned );    // LD D, RRC (IX + d)   [undocumented]
    void opcode_xycb_0b( unsigned );    // LD E, RRC (IX + d)   [undocumented]
    void opcode_xycb_0c( unsigned );    // LD H, RRC (IX + d)   [undocumented]
    void opcode_xycb_0d( unsigned );    // LD L, RRC (IX + d)   [undocumented]
    void opcode_xycb_0e( unsigned );    // RRC (IX + d)
    void opcode_xycb_0f( unsigned );    // LD A, RRC (IX + d)   [undocumented]
    void opcode_xycb_10( unsigned );    // LD B, RL (IX + d)    [undocumented]
    void opcode_xycb_11( unsigned );    // LD C, RL (IX + d)    [undocumented]
    void opcode_xycb_12( unsigned );    // LD D, RL (IX + d)    [undocumented]
    void opcode_xycb_13( unsigned );    // LD E, RL (IX + d)    [undocumented]
    void opcode_xycb_14( unsigned );    // LD H, RL (IX + d)    [undocumented]
    void opcode_xycb_15( unsigned );    // LD L, RL (IX + d)    [undocumented]
    void opcode_xycb_16( unsigned );    // RL (IX + d)
    void opcode_xycb_17( unsigned );    // LD A, RL (IX + d)    [undocumented]
    void opcode_xycb_18( unsigned );    // LD B, RR (IX + d)    [undocumented]
    void opcode_xycb_19( unsigned );    // LD C, RR (IX + d)    [undocumented]
    void opcode_xycb_1a( unsigned );    // LD D, RR (IX + d)    [undocumented]
    void opcode_xycb_1b( unsigned );    // LD E, RR (IX + d)    [undocumented]
    void opcode_xycb_1c( unsigned );    // LD H, RR (IX + d)    [undocumented]
    void opcode_xycb_1d( unsigned );    // LD L, RR (IX + d)    [undocumented]
    void opcode_xycb_1e( unsigned );    // RR (IX + d)
    void opcode_xycb_1f( unsigned );    // LD A, RR (IX + d)    [undocumented]
    void opcode_xycb_20( unsigned );    // LD B, SLA (IX + d)   [undocumented]
    void opcode_xycb_21( unsigned );    // LD C, SLA (IX + d)   [undocumented]
    void opcode_xycb_22( unsigned );    // LD D, SLA (IX + d)   [undocumented]
    void opcode_xycb_23( unsigned );    // LD E, SLA (IX + d)   [undocumented]
    void opcode_xycb_24( unsigned );    // LD H, SLA (IX + d)   [undocumented]
    void opcode_xycb_25( unsigned );    // LD L, SLA (IX + d)   [undocumented]
    void opcode_xycb_26( unsigned );    // SLA (IX + d)
    void opcode_xycb_27( unsigned );    // LD A, SLA (IX + d)   [undocumented]
    void opcode_xycb_28( unsigned );    // LD B, SRA (IX + d)   [undocumented]
    void opcode_xycb_29( unsigned );    // LD C, SRA (IX + d)   [undocumented]
    void opcode_xycb_2a( unsigned );    // LD D, SRA (IX + d)   [undocumented]
    void opcode_xycb_2b( unsigned );    // LD E, SRA (IX + d)   [undocumented]
    void opcode_xycb_2c( unsigned );    // LD H, SRA (IX + d)   [undocumented]
    void opcode_xycb_2d( unsigned );    // LD L, SRA (IX + d)   [undocumented]
    void opcode_xycb_2e( unsigned );    // SRA (IX + d)
    void opcode_xycb_2f( unsigned );    // LD A, SRA (IX + d)   [undocumented]
    void opcode_xycb_30( unsigned );    // LD B, SLL (IX + d)   [undocumented]
    void opcode_xycb_31( unsigned );    // LD C, SLL (IX + d)   [undocumented]
    void opcode_xycb_32( unsigned );    // LD D, SLL (IX + d)   [undocumented]
    void opcode_xycb_33( unsigned );    // LD E, SLL (IX + d)   [undocumented]
    void opcode_xycb_34( unsigned );    // LD H, SLL (IX + d)   [undocumented]
    void opcode_xycb_35( unsigned );    // LD L, SLL (IX + d)   [undocumented]
    void opcode_xycb_36( unsigned );    // SLL (IX + d)         [undocumented]
    void opcode_xycb_37( unsigned );    // LD A, SLL (IX + d)   [undocumented]
    void opcode_xycb_38( unsigned );    // LD B, SRL (IX + d)   [undocumented]
    void opcode_xycb_39( unsigned );    // LD C, SRL (IX + d)   [undocumented]
    void opcode_xycb_3a( unsigned );    // LD D, SRL (IX + d)   [undocumented]
    void opcode_xycb_3b( unsigned );    // LD E, SRL (IX + d)   [undocumented]
    void opcode_xycb_3c( unsigned );    // LD H, SRL (IX + d)   [undocumented]
    void opcode_xycb_3d( unsigned );    // LD L, SRL (IX + d)   [undocumented]
    void opcode_xycb_3e( unsigned );    // SRL (IX + d)
    void opcode_xycb_3f( unsigned );    // LD A, SRL (IX + d)   [undocumented]
    void opcode_xycb_40( unsigned );    // BIT 0, (IX + d)      [undocumented]
    void opcode_xycb_41( unsigned );    // BIT 0, (IX + d)      [undocumented]
    void opcode_xycb_42( unsigned );    // BIT 0, (IX + d)      [undocumented]
    void opcode_xycb_43( unsigned );    // BIT 0, (IX + d)      [undocumented]
    void opcode_xycb_44( unsigned );    // BIT 0, (IX + d)      [undocumented]
    void opcode_xycb_45( unsigned );    // BIT 0, (IX + d)      [undocumented]
    void opcode_xycb_46( unsigned );    // BIT 0, (IX + d)
    void opcode_xycb_47( unsigned );    // BIT 0, (IX + d)      [undocumented]
    void opcode_xycb_48( unsigned );    // BIT 1, (IX + d)      [undocumented]
    void opcode_xycb_49( unsigned );    // BIT 1, (IX + d)      [undocumented]
    void opcode_xycb_4a( unsigned );    // BIT 1, (IX + d)      [undocumented]
    void opcode_xycb_4b( unsigned );    // BIT 1, (IX + d)      [undocumented]
    void opcode_xycb_4c( unsigned );    // BIT 1, (IX + d)      [undocumented]
    void opcode_xycb_4d( unsigned );    // BIT 1, (IX + d)      [undocumented]
    void opcode_xycb_4e( unsigned );    // BIT 1, (IX + d)
    void opcode_xycb_4f( unsigned );    // BIT 1, (IX + d)      [undocumented]
    void opcode_xycb_50( unsigned );    // BIT 2, (IX + d)      [undocumented]
    void opcode_xycb_51( unsigned );    // BIT 2, (IX + d)      [undocumented]
    void opcode_xycb_52( unsigned );    // BIT 2, (IX + d)      [undocumented]
    void opcode_xycb_53( unsigned );    // BIT 2, (IX + d)      [undocumented]
    void opcode_xycb_54( unsigned );    // BIT 2, (IX + d)      [undocumented]
    void opcode_xycb_55( unsigned );    // BIT 2, (IX + d)      [undocumented]
    void opcode_xycb_56( unsigned );    // BIT 2, (IX + d)
    void opcode_xycb_57( unsigned );    // BIT 2, (IX + d)      [undocumented]
    void opcode_xycb_58( unsigned );    // BIT 3, (IX + d)      [undocumented]
    void opcode_xycb_59( unsigned );    // BIT 3, (IX + d)      [undocumented]
    void opcode_xycb_5a( unsigned );    // BIT 3, (IX + d)      [undocumented]
    void opcode_xycb_5b( unsigned );    // BIT 3, (IX + d)      [undocumented]
    void opcode_xycb_5c( unsigned );    // BIT 3, (IX + d)      [undocumented]
    void opcode_xycb_5d( unsigned );    // BIT 3, (IX + d)      [undocumented]
    void opcode_xycb_5e( unsigned );    // BIT 3, (IX + d)
    void opcode_xycb_5f( unsigned );    // BIT 3, (IX + d)      [undocumented]
    void opcode_xycb_60( unsigned );    // BIT 4, (IX + d)      [undocumented]
    void opcode_xycb_61( unsigned );    // BIT 4, (IX + d)      [undocumented]
    void opcode_xycb_62( unsigned );    // BIT 4, (IX + d)      [undocumented]
    void opcode_xycb_63( unsigned );    // BIT 4, (IX + d)      [undocumented]
    void opcode_xycb_64( unsigned );    // BIT 4, (IX + d)      [undocumented]
    void opcode_xycb_65( unsigned );    // BIT 4, (IX + d)      [undocumented]
    void opcode_xycb_66( unsigned );    // BIT 4, (IX + d)
    void opcode_xycb_67( unsigned );    // BIT 4, (IX + d)      [undocumented]
    void opcode_xycb_68( unsigned );    // BIT 5, (IX + d)      [undocumented]
    void opcode_xycb_69( unsigned );    // BIT 5, (IX + d)      [undocumented]
    void opcode_xycb_6a( unsigned );    // BIT 5, (IX + d)      [undocumented]
    void opcode_xycb_6b( unsigned );    // BIT 5, (IX + d)      [undocumented]
    void opcode_xycb_6c( unsigned );    // BIT 5, (IX + d)      [undocumented]
    void opcode_xycb_6d( unsigned );    // BIT 5, (IX + d)      [undocumented]
    void opcode_xycb_6e( unsigned );    // BIT 5, (IX + d)
    void opcode_xycb_6f( unsigned );    // BIT 5, (IX + d)      [undocumented]
    void opcode_xycb_70( unsigned );    // BIT 6, (IX + d)      [undocumented]
    void opcode_xycb_71( unsigned );    // BIT 6, (IX + d)      [undocumented]
    void opcode_xycb_72( unsigned );    // BIT 6, (IX + d)      [undocumented]
    void opcode_xycb_73( unsigned );    // BIT 6, (IX + d)      [undocumented]
    void opcode_xycb_74( unsigned );    // BIT 6, (IX + d)      [undocumented]
    void opcode_xycb_75( unsigned );    // BIT 6, (IX + d)      [undocumented]
    void opcode_xycb_76( unsigned );    // BIT 6, (IX + d)
    void opcode_xycb_77( unsigned );    // BIT 6, (IX + d)      [undocumented]
    void opcode_xycb_78( unsigned );    // BIT 7, (IX + d)      [undocumented]
    void opcode_xycb_79( unsigned );    // BIT 7, (IX + d)      [undocumented]
    void opcode_xycb_7a( unsigned );    // BIT 7, (IX + d)      [undocumented]
    void opcode_xycb_7b( unsigned );    // BIT 7, (IX + d)      [undocumented]
    void opcode_xycb_7c( unsigned );    // BIT 7, (IX + d)      [undocumented]
    void opcode_xycb_7d( unsigned );    // BIT 7, (IX + d)      [undocumented]
    void opcode_xycb_7e( unsigned );    // BIT 7, (IX + d)
    void opcode_xycb_7f( unsigned );    // BIT 7, (IX + d)      [undocumented]
    void opcode_xycb_80( unsigned );    // LD B, RES 0, (IX + d)    [undocumented]
    void opcode_xycb_81( unsigned );    // LD C, RES 0, (IX + d)    [undocumented]
    void opcode_xycb_82( unsigned );    // LD D, RES 0, (IX + d)    [undocumented]
    void opcode_xycb_83( unsigned );    // LD E, RES 0, (IX + d)    [undocumented]
    void opcode_xycb_84( unsigned );    // LD H, RES 0, (IX + d)    [undocumented]
    void opcode_xycb_85( unsigned );    // LD L, RES 0, (IX + d)    [undocumented]
    void opcode_xycb_86( unsigned );    // RES 0, (IX + d)
    void opcode_xycb_87( unsigned );    // LD A, RES 0, (IX + d)    [undocumented]
    void opcode_xycb_88( unsigned );    // LD B, RES 1, (IX + d)    [undocumented]
    void opcode_xycb_89( unsigned );    // LD C, RES 1, (IX + d)    [undocumented]
    void opcode_xycb_8a( unsigned );    // LD D, RES 1, (IX + d)    [undocumented]
    void opcode_xycb_8b( unsigned );    // LD E, RES 1, (IX + d)    [undocumented]
    void opcode_xycb_8c( unsigned );    // LD H, RES 1, (IX + d)    [undocumented]
    void opcode_xycb_8d( unsigned );    // LD L, RES 1, (IX + d)    [undocumented]
    void opcode_xycb_8e( unsigned );    // RES 1, (IX + d)
    void opcode_xycb_8f( unsigned );    // LD A, RES 1, (IX + d)    [undocumented]
    void opcode_xycb_90( unsigned );    // LD B, RES 2, (IX + d)    [undocumented]
    void opcode_xycb_91( unsigned );    // LD C, RES 2, (IX + d)    [undocumented]
    void opcode_xycb_92( unsigned );    // LD D, RES 2, (IX + d)    [undocumented]
    void opcode_xycb_93( unsigned );    // LD E, RES 2, (IX + d)    [undocumented]
    void opcode_xycb_94( unsigned );    // LD H, RES 2, (IX + d)    [undocumented]
    void opcode_xycb_95( unsigned );    // LD L, RES 2, (IX + d)    [undocumented]
    void opcode_xycb_96( unsigned );    // RES 2, (IX + d)
    void opcode_xycb_97( unsigned );    // LD A, RES 2, (IX + d)    [undocumented]
    void opcode_xycb_98( unsigned );    // LD B, RES 3, (IX + d)    [undocumented]
    void opcode_xycb_99( unsigned );    // LD C, RES 3, (IX + d)    [undocumented]
    void opcode_xycb_9a( unsigned );    // LD D, RES 3, (IX + d)    [undocumented]
    void opcode_xycb_9b( unsigned );    // LD E, RES 3, (IX + d)    [undocumented]
    void opcode_xycb_9c( unsigned );    // LD H, RES 3, (IX + d)    [undocumented]
    void opcode_xycb_9d( unsigned );    // LD L, RES 3, (IX + d)    [undocumented]
    void opcode_xycb_9e( unsigned );    // RES 3, (IX + d)
    void opcode_xycb_9f( unsigned );    // LD A, RES 3, (IX + d)    [undocumented]
    void opcode_xycb_a0( unsigned );    // LD B, RES 4, (IX + d)    [undocumented]
    void opcode_xycb_a1( unsigned );    // LD C, RES 4, (IX + d)    [undocumented]
    void opcode_xycb_a2( unsigned );    // LD D, RES 4, (IX + d)    [undocumented]
    void opcode_xycb_a3( unsigned );    // LD E, RES 4, (IX + d)    [undocumented]
    void opcode_xycb_a4( unsigned );    // LD H, RES 4, (IX + d)    [undocumented]
    void opcode_xycb_a5( unsigned );    // LD L, RES 4, (IX + d)    [undocumented]
    void opcode_xycb_a6( unsigned );    // RES 4, (IX + d)
    void opcode_xycb_a7( unsigned );    // LD A, RES 4, (IX + d)    [undocumented]
    void opcode_xycb_a8( unsigned );    // LD B, RES 5, (IX + d)    [undocumented]
    void opcode_xycb_a9( unsigned );    // LD C, RES 5, (IX + d)    [undocumented]
    void opcode_xycb_aa( unsigned );    // LD D, RES 5, (IX + d)    [undocumented]
    void opcode_xycb_ab( unsigned );    // LD E, RES 5, (IX + d)    [undocumented]
    void opcode_xycb_ac( unsigned );    // LD H, RES 5, (IX + d)    [undocumented]
    void opcode_xycb_ad( unsigned );    // LD L, RES 5, (IX + d)    [undocumented]
    void opcode_xycb_ae( unsigned );    // RES 5, (IX + d)
    void opcode_xycb_af( unsigned );    // LD A, RES 5, (IX + d)    [undocumented]
    void opcode_xycb_b0( unsigned );    // LD B, RES 6, (IX + d)    [undocumented]
    void opcode_xycb_b1( unsigned );    // LD C, RES 6, (IX + d)    [undocumented]
    void opcode_xycb_b2( unsigned );    // LD D, RES 6, (IX + d)    [undocumented]
    void opcode_xycb_b3( unsigned );    // LD E, RES 6, (IX + d)    [undocumented]
    void opcode_xycb_b4( unsigned );    // LD H, RES 6, (IX + d)    [undocumented]
    void opcode_xycb_b5( unsigned );    // LD L, RES 6, (IX + d)    [undocumented]
    void opcode_xycb_b6( unsigned );    // RES 6, (IX + d)
    void opcode_xycb_b7( unsigned );    // LD A, RES 6, (IX + d)    [undocumented]
    void opcode_xycb_b8( unsigned );    // LD B, RES 7, (IX + d)    [undocumented]
    void opcode_xycb_b9( unsigned );    // LD C, RES 7, (IX + d)    [undocumented]
    void opcode_xycb_ba( unsigned );    // LD D, RES 7, (IX + d)    [undocumented]
    void opcode_xycb_bb( unsigned );    // LD E, RES 7, (IX + d)    [undocumented]
    void opcode_xycb_bc( unsigned );    // LD H, RES 7, (IX + d)    [undocumented]
    void opcode_xycb_bd( unsigned );    // LD L, RES 7, (IX + d)    [undocumented]
    void opcode_xycb_be( unsigned );    // RES 7, (IX + d)
    void opcode_xycb_bf( unsigned );    // LD A, RES 7, (IX + d)    [undocumented]
    void opcode_xycb_c0( unsigned );    // LD B, SET 0, (IX + d)    [undocumented]
    void opcode_xycb_c1( unsigned );    // LD C, SET 0, (IX + d)    [undocumented]
    void opcode_xycb_c2( unsigned );    // LD D, SET 0, (IX + d)    [undocumented]
    void opcode_xycb_c3( unsigned );    // LD E, SET 0, (IX + d)    [undocumented]
    void opcode_xycb_c4( unsigned );    // LD H, SET 0, (IX + d)    [undocumented]
    void opcode_xycb_c5( unsigned );    // LD L, SET 0, (IX + d)    [undocumented]
    void opcode_xycb_c6( unsigned );    // SET 0, (IX + d)
    void opcode_xycb_c7( unsigned );    // LD A, SET 0, (IX + d)    [undocumented]
    void opcode_xycb_c8( unsigned );    // LD B, SET 1, (IX + d)    [undocumented]
    void opcode_xycb_c9( unsigned );    // LD C, SET 1, (IX + d)    [undocumented]
    void opcode_xycb_ca( unsigned );    // LD D, SET 1, (IX + d)    [undocumented]
    void opcode_xycb_cb( unsigned );    // LD E, SET 1, (IX + d)    [undocumented]
    void opcode_xycb_cc( unsigned );    // LD H, SET 1, (IX + d)    [undocumented]
    void opcode_xycb_cd( unsigned );    // LD L, SET 1, (IX + d)    [undocumented]
    void opcode_xycb_ce( unsigned );    // SET 1, (IX + d)
    void opcode_xycb_cf( unsigned );    // LD A, SET 1, (IX + d)    [undocumented]
    void opcode_xycb_d0( unsigned );    // LD B, SET 2, (IX + d)    [undocumented]
    void opcode_xycb_d1( unsigned );    // LD C, SET 2, (IX + d)    [undocumented]
    void opcode_xycb_d2( unsigned );    // LD D, SET 2, (IX + d)    [undocumented]
    void opcode_xycb_d3( unsigned );    // LD E, SET 2, (IX + d)    [undocumented]
    void opcode_xycb_d4( unsigned );    // LD H, SET 2, (IX + d)    [undocumented]
    void opcode_xycb_d5( unsigned );    // LD L, SET 2, (IX + d)    [undocumented]
    void opcode_xycb_d6( unsigned );    // SET 2, (IX + d)
    void opcode_xycb_d7( unsigned );    // LD A, SET 2, (IX + d)    [undocumented]
    void opcode_xycb_d8( unsigned );    // LD B, SET 3, (IX + d)    [undocumented]
    void opcode_xycb_d9( unsigned );    // LD C, SET 3, (IX + d)    [undocumented]
    void opcode_xycb_da( unsigned );    // LD D, SET 3, (IX + d)    [undocumented]
    void opcode_xycb_db( unsigned );    // LD E, SET 3, (IX + d)    [undocumented]
    void opcode_xycb_dc( unsigned );    // LD H, SET 3, (IX + d)    [undocumented]
    void opcode_xycb_dd( unsigned );    // LD L, SET 3, (IX + d)    [undocumented]
    void opcode_xycb_de( unsigned );    // SET 3, (IX + d)
    void opcode_xycb_df( unsigned );    // LD A, SET 3, (IX + d)    [undocumented]
    void opcode_xycb_e0( unsigned );    // LD B, SET 4, (IX + d)    [undocumented]
    void opcode_xycb_e1( unsigned );    // LD C, SET 4, (IX + d)    [undocumented]
    void opcode_xycb_e2( unsigned );    // LD D, SET 4, (IX + d)    [undocumented]
    void opcode_xycb_e3( unsigned );    // LD E, SET 4, (IX + d)    [undocumented]
    void opcode_xycb_e4( unsigned );    // LD H, SET 4, (IX + d)    [undocumented]
    void opcode_xycb_e5( unsigned );    // LD L, SET 4, (IX + d)    [undocumented]
    void opcode_xycb_e6( unsigned );    // SET 4, (IX + d)
    void opcode_xycb_e7( unsigned );    // LD A, SET 4, (IX + d)    [undocumented]
    void opcode_xycb_e8( unsigned );    // LD B, SET 5, (IX + d)    [undocumented]
    void opcode_xycb_e9( unsigned );    // LD C, SET 5, (IX + d)    [undocumented]
    void opcode_xycb_ea( unsigned );    // LD D, SET 5, (IX + d)    [undocumented]
    void opcode_xycb_eb( unsigned );    // LD E, SET 5, (IX + d)    [undocumented]
    void opcode_xycb_ec( unsigned );    // LD H, SET 5, (IX + d)    [undocumented]
    void opcode_xycb_ed( unsigned );    // LD L, SET 5, (IX + d)    [undocumented]
    void opcode_xycb_ee( unsigned );    // SET 5, (IX + d)
    void opcode_xycb_ef( unsigned );    // LD A, SET 5, (IX + d)    [undocumented]
    void opcode_xycb_f0( unsigned );    // LD B, SET 6, (IX + d)    [undocumented]
    void opcode_xycb_f1( unsigned );    // LD C, SET 6, (IX + d)    [undocumented]
    void opcode_xycb_f2( unsigned );    // LD D, SET 6, (IX + d)    [undocumented]
    void opcode_xycb_f3( unsigned );    // LD E, SET 6, (IX + d)    [undocumented]
    void opcode_xycb_f4( unsigned );    // LD H, SET 6, (IX + d)    [undocumented]
    void opcode_xycb_f5( unsigned );    // LD L, SET 6, (IX + d)    [undocumented]
    void opcode_xycb_f6( unsigned );    // SET 6, (IX + d)
    void opcode_xycb_f7( unsigned );    // LD A, SET 6, (IX + d)    [undocumented]
    void opcode_xycb_f8( unsigned );    // LD B, SET 7, (IX + d)    [undocumented]
    void opcode_xycb_f9( unsigned );    // LD C, SET 7, (IX + d)    [undocumented]
    void opcode_xycb_fa( unsigned );    // LD D, SET 7, (IX + d)    [undocumented]
    void opcode_xycb_fb( unsigned );    // LD E, SET 7, (IX + d)    [undocumented]
    void opcode_xycb_fc( unsigned );    // LD H, SET 7, (IX + d)    [undocumented]
    void opcode_xycb_fd( unsigned );    // LD L, SET 7, (IX + d)    [undocumented]
    void opcode_xycb_fe( unsigned );    // SET 7, (IX + d)
    void opcode_xycb_ff( unsigned );    // LD A, SET 7, (IX + d)    [undocumented]

    // Trivia: there are 1018 opcode_xxx() functions in this class, 
    // for a total of 1274 emulated opcodes. Fortunately, most of them
    // were automatically generated by custom made programs and scripts.

protected:
    /** */
    unsigned addDispl( unsigned addr, unsigned char displ ) {
        return (unsigned)((int)addr + (int)(char)displ);
    }

    /** Executes an 8 bit addition (ADD/ADC op) */
    void addByte( unsigned char op, unsigned char cf );

    /** Executes a subroutine call (CALL addr) */
    void callSub( unsigned addr );

    /** Compares the accumulator and the specified operand (CP op) */
    void cmpByte( unsigned char op ) {
        subByte( op, 0 );
    }

    /** Executes an 8 bit decrement (DEC b) */
    unsigned char decByte( unsigned char b );

    /** Executes an 8 bit increment (INC b) */
    unsigned char incByte( unsigned char b );

    /** Fetches a byte from the program counter location */
    unsigned char fetchByte() {
        return env_.readByte( PC++ );
    }

    /** Fetches a 16 bit word from the program counter location */
    unsigned fetchWord() {
        unsigned x = readWord( PC );
        PC += 2;
        return x;
    }

    /** Reads a byte from the port set by register C (IN r, (C)) */
    unsigned char inpReg();

    /** Executes a relative jump (JR o) */
    void relJump( unsigned char o );

    /** Executes a return from subroutine instruction (RET) */
    void retFromSub();

    /** Rotates the operand left (RL op) */
    unsigned char rotateLeft( unsigned char op );

    /** Rotates the operand left with carry (RLC op) */
    unsigned char rotateLeftCarry( unsigned char op );

    /** Rotates the operand right (RR op) */
    unsigned char rotateRight( unsigned char op );

    /** Rotates the operand right with carry (RRC op) */
    unsigned char rotateRightCarry( unsigned char op );

    /** Sets the parity, sign and zero flags from the accumulator value */
    void setFlagsPSZ() {
        F = Halfcarry | PSZ_[A];
    }

    /** Sets the parity, sign, zero, 3rd and 5th flag bits from the accumulator value */
    void setFlags35PSZ() {
        F = (F & (Carry | Halfcarry | Subtraction)) | PSZ_[A];
    }

    /** */
    void setFlags35PSZ000() {
        F = PSZ_[A];
    }

    unsigned char shiftLeft( unsigned char op );
    unsigned char shiftRightArith( unsigned char op );
    unsigned char shiftRightLogical( unsigned char op );

    /** Checks whether the specified bit is set or clear (BIT bit,op) */
    void testBit( unsigned char bit, unsigned char op );

    /** Executes an 8 bit subtraction (SUB/SBC op) */
    unsigned char subByte( unsigned char op, unsigned char cf );

    /**
        Reads a 16 bit word from memory at the specified address.
    */
    unsigned readWord( unsigned addr ) {
        return env_.readByte(addr) | (((unsigned)env_.readByte(addr+1)) << 8);
    }

    /**
        Writes a 16 bit word to memory at the specified address.
    */
    virtual void writeWord( unsigned addr, unsigned value ) {
        env_.writeByte( addr,   value & 0xFF );
        env_.writeByte( addr+1, (value >> 8) & 0xFF );
    }

private:
    Z80();  // No default constructor

    static unsigned char PSZ_[256];     // Parity/Sign/Zero lookup table

    // Interrupt flags
    enum {
        IFF1    = 0x40,     // Interrupts enabled/disabled
        IFF2    = 0x20,     // Copy of IFF1 (used by non-maskable interrupts)
        Halted  = 0x10      // Internal use: signals that the CPU is halted
    };

    // Implements an opcode
    typedef void (Z80::* OpcodeHandler)();

    typedef struct {
        OpcodeHandler   handler;
        unsigned        cycles;
    } OpcodeInfo;

    static OpcodeInfo   OpInfo_[256];   // Opcode info the standard opcodes
    static OpcodeInfo   OpInfoCB_[256]; // Opcode info for the 0xCB prefixed opcodes
    static OpcodeInfo   OpInfoDD_[256]; // Opcode info for the 0xDD prefixed opcodes (IX)
    static OpcodeInfo   OpInfoED_[256]; // Opcode info for the 0xED prefixed opcodes
    static OpcodeInfo   OpInfoFD_[256]; // Opcode info for the 0xFD prefixed opcodes (IY)

    // Implements an opcode for instructions that use the form (IX/IY + b)
    typedef void (Z80::* OpcodeHandlerXY)( unsigned );

    typedef struct {
        OpcodeHandlerXY handler;
        unsigned        cycles;
    } OpcodeInfoXY;

    static OpcodeInfoXY OpInfoXYCB_[256];   // Opcode info for the 0xDDCB and 0xFDCB prefixes

    /** */
    void do_opcode_xy( OpcodeInfo * );

    /** */
    unsigned do_opcode_xycb( unsigned xy );

    unsigned    iflags_;    // Interrupt mode (bits 0 and 1) and flags
    unsigned    cycles_;    // Number of CPU cycles elapsed so far

    // Environment (provides all I/O functions)
    Z80Environment &    env_;   
};

#endif // Z80_H_
