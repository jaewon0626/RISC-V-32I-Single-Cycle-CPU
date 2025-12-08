`timescale 1ns / 1ps
`include "instr_define.sv"

module control_unit (
    input  logic [31:0] instr_code,
    output logic [ 3:0] alu_controls,
    output logic [ 2:0] funct3,
    output logic        aluSrcMux_sel,
    output logic [ 2:0] RegWdataSel,
    output logic        reg_wr_en,
    output logic        d_wr_en,
    output logic        Branch,
    output logic        jal,
    output logic        jalr
);

    wire  [6:0] funct7 = instr_code[31:25];
    wire  [6:0] opcode = instr_code[6:0];

    logic [8:0] controls;

    assign funct3 = instr_code[14:12];
    assign {RegWdataSel, aluSrcMux_sel, reg_wr_en, d_wr_en, Branch, jal, jalr} = controls;
    
    always_comb begin
        case (opcode)
            `R_TYPE: controls = 9'b000_010000;
            `S_TYPE: controls = 9'b000_101000;
            `IL_TYPE: controls = 9'b001_110000;
            `I_TYPE: controls = 9'b000_110000;
            `B_TYPE: controls = 9'b000_000100;
            `LUI_TYPE: controls = 9'b010_010000;
            `AUIPC_TYPE: controls = 9'b011_010000;
            `JAL_TYPE: controls = 9'b100_010010;
            `JALR_TYPE: controls = 9'b100_010011;
            default: controls = 9'b000_000000;
        endcase
    end

    always_comb begin
        case (opcode)
            `R_TYPE:  alu_controls = {funct7[5], funct3};  // R-type
            `S_TYPE:  alu_controls = `ADD;  // S-type
            `IL_TYPE: alu_controls = `ADD;  // IL-type 
            `I_TYPE: begin // I-type
                // funct7[5] 자리가 1이며, funct3가 101인 경우 -> SRA 명령어에 대해서만 처리
                if ({funct7[5], funct3} == 4'b1_101) begin
                    alu_controls = {funct7[5], funct3};
                end else begin
                    alu_controls = {1'b0, funct3};
                end
            end
            `B_TYPE:  alu_controls = {1'b0, funct3};
            default:  alu_controls = 4'bx;
        endcase
    end

endmodule
