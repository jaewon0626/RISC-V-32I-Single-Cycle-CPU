`timescale 1ns / 1ps
module RV32I_TOP (
    input logic clk,
    input logic reset
);
    logic [31:0] instr_code, instr_rAddr;
    logic [31:0] dAddr, dWdata;
    logic        d_wr_en;
    logic [ 2:0] mem_funct3;
    logic [31:0] dRdata;

    RV32I_core U_RV32I_CPU (
        .clk(clk),
        .reset(reset),
        .instr_code(instr_code),
        .dRdata(dRdata),
        .instr_rAddr(instr_rAddr),
        .d_wr_en(d_wr_en),
        .dAddr(dAddr),
        .mem_funct3(mem_funct3),
        .dWdata(dWdata)
    );

    instr_mem U_instr_mem (
        .instr_rAddr(instr_rAddr),
        .instr_code (instr_code)
    );

    data_mem U_DATA_RAM (
        .clk(clk),
        .d_wr_en(d_wr_en),
        .dAddr(dAddr),
        .mem_funct3(mem_funct3),
        .dWdata(dWdata),
        .dRdata(dRdata)
    );
endmodule

module RV32I_core (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instr_code,
    input  logic [31:0] dRdata,
    output logic [31:0] instr_rAddr,
    output logic        d_wr_en,
    output logic [31:0] dAddr,
    output logic [ 2:0] mem_funct3,
    output logic [31:0] dWdata
);
    logic [3:0] alu_controls;
    logic [2:0] w_RegWdataSel;
    logic reg_wr_en, w_aluSrcMux_sel;
    logic Branch, jal, jalr;

    control_unit U_Control_Unit (
        .instr_code   (instr_code),
        .alu_controls (alu_controls),
        .funct3       (mem_funct3),
        .aluSrcMux_sel(w_aluSrcMux_sel),
        .RegWdataSel  (w_RegWdataSel),
        .reg_wr_en    (reg_wr_en),
        .d_wr_en      (d_wr_en),
        .Branch       (Branch),
        .jal          (jal),
        .jalr         (jalr)
    );

    datapath U_data_path (
        .clk          (clk),
        .reset        (reset),
        .instr_code   (instr_code),
        .alu_controls (alu_controls),
        .reg_wr_en    (reg_wr_en),
        .aluSrcMux_sel(w_aluSrcMux_sel),
        .RegWdataSel  (w_RegWdataSel),
        .Branch       (Branch),
        .jal          (jal),
        .jalr         (jalr),
        .dRdata       (dRdata),
        .instr_rAddr  (instr_rAddr),
        .dAddr        (dAddr),
        .dWdata       (dWdata)
    );
    
endmodule
