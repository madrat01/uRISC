package defines_pkg;
    typedef enum logic [6:0] {
        HALT=7'b0,
        NOP=7'b0000100,
        ADDI=7'b0100000,
        SUBI=7'b0100100,
        XORI=7'b0101000,
        ANDI=7'b0101100,
        ROLI=7'b1010000,
        SLLI=7'b1010100,
        RORI=7'b1011000,
        SRLI=7'b1011100,
        ST=7'b1000000,
        LD=7'b1000100,
        STU=7'b1001100,
        BTR=7'b1100100,
        ADD=7'b1101100,
        SUB=7'b1101101,
        XOR=7'b1101110,
        ANDN=7'b1101111,
        ROL=7'b1101000,
        SLL=7'b1101001,
        ROR=7'b1101010,
        SRL=7'b1101011,
        SEQ=7'b1110000,
        SLT=7'b1110100,
        SLE=7'b1111000,
        SCO=7'b1111100,
        BEQZ=7'b0110000,
        BNEZ=7'b0110100,
        BLTZ=7'b0111000,
        BGEZ=7'b0111100,
        LBI=7'b1100000,
        SLBI=7'b1001000,
        J=7'b0010000,
        JR=7'b0010100,
        JAL=7'b0011000,
        JALR=7'b0011100,
        SIIR=7'b0001000,
        NOP_RTI=7'b0001100
    } inst_t;
endpackage
