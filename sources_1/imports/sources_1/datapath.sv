`timescale 1ns / 1ps
`include "instr_define.sv"

//funct7[5] + funct3[2:0] (R-type)
//funct3 (S-type)

module datapath (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instr_code,
    input  logic [ 3:0] alu_controls,
    input  logic        reg_wr_en,
    input  logic        aluSrcMux_sel,
    input  logic [ 2:0] RegWdataSel,
    input  logic        Branch,
    input  logic        jal,
    input  logic        jalr,
    input  logic [31:0] dRdata,
    output logic [31:0] instr_rAddr,
    output logic [31:0] dAddr,
    output logic [31:0] dWdata
);

    logic [31:0] w_regfile_rd1, w_regfile_rd2, w_alu_result;
    logic [31:0] w_imm_Ext, w_aluSrcMux_out;
    logic [31:0] w_RegWdataOut, w_pc_MuxOut;
    logic [31:0] pc_Next;
    logic [31:0] w_auipc;
    logic [31:0] w_jalr_MuxOut;
    logic [31:0] w_jalr_imm_Sum;
    logic pc_MuxSel;
    logic Btaken;

    assign dAddr = w_alu_result;
    assign dWdata = w_regfile_rd2;
    assign pc_MuxSel = jal | (Branch & Btaken);

    register_file u_REG_FILE (
        .clk      (clk),
        .RA1      (instr_code[19:15]),  // read address 1
        .RA2      (instr_code[24:20]),  // read address 2
        .WA       (instr_code[11:7]),   // write address
        .reg_wr_en(reg_wr_en),          // write enable
        .WData    (w_RegWdataOut),      // write data
        .RD1      (w_regfile_rd1),      // read data 1
        .RD2      (w_regfile_rd2)       // read data 2
    );

    mux_2x1 u_JALR_MUX(
        .sel(jalr),
        .x0(instr_rAddr),
        .x1(w_regfile_rd1),
        .y(w_jalr_MuxOut)
    );

    mux_2x1 u_PC_MUX (
        .sel(pc_MuxSel),
        .x0 (pc_Next),       
        .x1 (w_jalr_imm_Sum),   
        .y  (w_pc_MuxOut)
    );

    pc_adder u_JALR_IMM_ADDER (
        .a(w_imm_Ext),
        .b(w_jalr_MuxOut),
        .sum(w_jalr_imm_Sum)
    );

    pc_adder u_PC_ADDER (
        .a  (instr_rAddr),
        .b  (32'd4),
        .sum(pc_Next)
    );

    program_counter u_PC (
        .clk    (clk),
        .reset  (reset),
        .pc_Next(w_pc_MuxOut),
        .pc     (instr_rAddr)
    );

    // adder_auipc u_AUIPC (
    //     .imm_Ext(w_imm_Ext),
    //     .pc     (instr_rAddr),
    //     .auipc  (w_auipc)
    // );

    mux_5x1 u_RegWdataMux (
        .sel(RegWdataSel),
        .x0 (w_alu_result),  
        .x1 (dRdata),        
        .x2 (w_imm_Ext),
        .x3 (w_jalr_imm_Sum),
        .x4 (pc_Next),
        .y  (w_RegWdataOut)  // to Register file
    );

    ALU u_ALU (
        .a(w_regfile_rd1),
        .b(w_aluSrcMux_out),
        .alu_controls(alu_controls),
        .alu_result(w_alu_result),
        .Btaken(Btaken)
    );

    mux_2x1 u_AluSrcMux (
        .sel(aluSrcMux_sel),
        .x0(w_regfile_rd2),   //0 : regFile R2
        .x1(w_imm_Ext),   //1 : imm [31:0]
        .y(w_aluSrcMux_out)     //to ALU R2
    );


    extend u_extend (
        .instr_code(instr_code),
        .imm_Ext   (w_imm_Ext)
    );

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////

module program_counter (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] pc_Next,
    output logic [31:0] pc
);
    // wire [31:0] pc_4;
    // assign pc_Next = pc + 4;

    register U_PC_REG (
        .clk(clk),
        .reset(reset),
        .d(pc_Next),
        .q(pc)
    );
endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////

module register (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] d,
    output logic [31:0] q
);

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            q <= 0;
        end else begin
            q <= d;
        end
    end

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////

module register_file (
    input  logic        clk,
    input  logic [ 4:0] RA1,        // read address 1
    input  logic [ 4:0] RA2,        // read address 2
    input  logic [ 4:0] WA,         // write address
    input  logic        reg_wr_en,  // write enable
    input  logic [31:0] WData,      // write data
    output logic [31:0] RD1,        // read data 1
    output logic [31:0] RD2         // read data 2
);

    logic [31:0] reg_file[0:31];  // 32bit 32개.

    initial begin
        // reg_file[0] = 0;
        for (int i = 0; i < 32; i++) begin
            reg_file[i] = i;

        // reg_file[5]  = 32'h1234_5678;  // 저장할 데이터
        // reg_file[10] = 32'h0000_0000;  // 베이스 주소 (0번지부터 시작)

        end
    end

    always_ff @(posedge clk) begin
        if (reg_wr_en) begin
            reg_file[WA] <= WData;
        end
    end

    // register address 0 is zero return
    assign RD1 = (RA1 != 0) ? reg_file[RA1] : 0;
    assign RD2 = (RA2 != 0) ? reg_file[RA2] : 0;

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////

module ALU (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [ 3:0] alu_controls,
    output logic [31:0] alu_result,
    output logic        Btaken
);

    always_comb begin
        case (alu_controls)
            `ADD: alu_result = a + b;
            `SUB: alu_result = a - b;
            `SLL: alu_result = a << b[4:0];  // max 32bit shift
            `SRL: alu_result = a >> b[4:0];  // 0으로 extend
            // [31] extend bt signed bit
            `SRA: alu_result = $signed(a) >>> b[4:0];
            `SLT: alu_result = $signed(a) < $signed(b) ? 1 : 0;
            `SLTU: alu_result = a < b ? 1 : 0;  // unsigned SLT
            `XOR: alu_result = a ^ b;
            `OR: alu_result = a | b;
            `AND: alu_result = a & b;
            default: alu_result = 32'bx;
        endcase
    end
    
    always_comb begin
        case (alu_controls[2:0])
            `BEQ: Btaken = ($signed(a) == $signed(b));
            `BNE: Btaken = ($signed(a) != $signed(b));
            `BLT: Btaken = ($signed(a) < $signed(b));
            `BGE: Btaken = ($signed(a) >= $signed(b));
            `BLTU: Btaken = a < b;
            `BGEU: Btaken = a >= b;
            default: Btaken = 1'b0;
        endcase
    end

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////

module extend (
    input  logic [31:0] instr_code,
    output logic [31:0] imm_Ext
);

    wire [6:0] opcode = instr_code[6:0];
    wire [2:0] funct3 = instr_code[14:12];

    always_comb begin
        case (opcode)
            `R_TYPE: imm_Ext = 32'bx;
            `S_TYPE:
            imm_Ext = {
                {20{instr_code[31]}}, instr_code[31:25], instr_code[11:7]
            };
            // 0으로 앞에서 20개 채우기
            `IL_TYPE: imm_Ext = {{20{instr_code[31]}}, instr_code[31:20]};
            `I_TYPE: imm_Ext = {{20{instr_code[31]}}, instr_code[31:20]};
            `B_TYPE:
            imm_Ext = {
                {20{instr_code[31]}},  // 20bit
                instr_code[7],  // 1bit
                instr_code[30:25],  // 6bit
                instr_code[11:8],  // 4bit
                1'b0  // 1bit
            };
            `LUI_TYPE: imm_Ext = {instr_code[31:12], {12{1'b0}}};
            `AUIPC_TYPE: imm_Ext = {instr_code[31:12], {12{1'b0}}};
            `JAL_TYPE: imm_Ext = {{12{instr_code[31]}},
                                {instr_code[19:12]},
                                {instr_code[20]},
                                {instr_code[30:21]},
                                {1'b0}};
            `JALR_TYPE: imm_Ext = {{20{1'b0}}, instr_code[31:20]};
            default: imm_Ext = 32'bx;
        endcase
    end
endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////

module mux_2x1 (
    input               sel,
    input  logic [31:0] x0,   //0 : regFile R2
    input  logic [31:0] x1,   //1 : imm [31:0]
    output logic [31:0] y     //to ALU R2
);

    assign y = (sel == 1) ? x1 : x0;

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////

module mux_5x1 (
    input        [ 2:0] sel,
    input  logic [31:0] x0,   //0 : regFile R2
    input  logic [31:0] x1,   //1 : imm [31:0]
    input  logic [31:0] x2,
    input  logic [31:0] x3,
    input  logic [31:0] x4,
    output logic [31:0] y     //to ALU R2
);

    assign y =  (sel == 3'b000) ? x0 :
                (sel == 3'b001) ? x1 : 
                (sel == 3'b010) ? x2 :
                (sel == 3'b011) ? x3 : x4; 

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////

module pc_adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] sum
);

    assign sum = a + b;

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////

// module adder_auipc (
//     input  logic [31:0] imm_Ext,
//     input  logic [31:0] pc,
//     output logic [31:0] auipc
// );

//     assign auipc = imm_Ext + pc;

// endmodule
