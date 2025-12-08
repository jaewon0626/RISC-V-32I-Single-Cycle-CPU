// ALU COMMAND

// Instruction
`define R_TYPE 7'b0110011 // RD = RS1 + RS2
`define S_TYPE 7'b0100011 // SW, SH, SB
`define IL_TYPE 7'b0000011 // LW, LH, LBU, LHU
`define I_TYPE 7'b0010011 // RD = RS1 + IMM
`define B_TYPE 7'b1100011 // branch
`define LUI_TYPE 7'b0110111 // rd = imm
`define AUIPC_TYPE 7'b0010111 // rd = PC + imm 
`define JAL_TYPE 7'b1101111  // rd = PC + 4, PC = imm + PC
`define JALR_TYPE 7'b1100111  // rd = PC + 4, PC = imm + rs1

// R-type
`define ADD 4'b0000  // ADD
`define SUB 4'b1000  // SUB
`define SLL 4'b0001  // SLL
`define SRL 4'b0101  // SRL
`define SRA 4'b1101  // SRA
`define SLT 4'b0010  // SLT
`define SLTU 4'b0011  // SLTU
`define XOR 4'b0100  // XOR
`define OR 4'b0110  // OR
`define AND 4'b0111  // AND

// S-type
`define SB 3'b000
`define SH 3'b001
`define SW 3'b010

// IL-type
`define LB 3'b000  // Load Byte (sign-extended)
`define LH 3'b001  // Load Halfword (sign-extended)
`define LW 3'b010  // Load Word
`define LBU 3'b100  // Load Byte Unsigned
`define LHU 3'b101  // Load Halfword Unsigned

// B-type
`define BEQ 3'b000
`define BNE 3'b001
`define BLT 3'b100
`define BGE 3'b101
`define BLTU 3'b110
`define BGEU 3'b111

// J-type