`timescale 1ns / 1ps
`include "instr_define.sv"

module data_mem (
    input  logic        clk,
    input  logic        d_wr_en,  // control unit
    input  logic [31:0] dAddr,    // data path
    input  logic [31:0] dWdata,   // instr code
    
    input  logic [ 2:0] mem_funct3,
    output logic [31:0] dRdata
);

    logic [31:0] data_mem[0:15];
    
    initial begin
        for (int i = 0; i < 16 ; i ++) begin
            data_mem[i] = 32'h1234_5678;
        end
    end
    // initial begin
    //     data_mem[2] = 32'h1234_5678;
    //     data_mem[3] = 32'h8765_4321;
    //     data_mem[4] = 32'h0000_ffff;
    // end


    always_ff @(posedge clk) begin
        if (d_wr_en) begin
        case (mem_funct3)
            `SB: data_mem[dAddr[31:2]][7:0]   <= dWdata[7:0];   // 하위 8비트만
            `SH: data_mem[dAddr[31:2]][15:0]  <= dWdata[15:0];  // 하위 16비트만
            `SW: data_mem[dAddr[31:2]]        <= dWdata;        // 전체 32비트
            default : data_mem[dAddr[31:2]] <= 32'dx;
        endcase
        end
    end
    
    always_comb begin
        case (mem_funct3)
            `LB : dRdata = {{24{data_mem[dAddr[31:2]][ 7]}}, data_mem[dAddr[31:2]][ 7:0]};
            `LH : dRdata = {{16{data_mem[dAddr[31:2]][15]}}, data_mem[dAddr[31:2]][15:0]};
            `LW : dRdata = data_mem[dAddr[31:2]];
            `LBU: dRdata = {24'b0, data_mem[dAddr[31:2]][7:0]};
            `LHU: dRdata = {16'b0, data_mem[dAddr[31:2]][15:0]};
            default: dRdata = 32'hx;
        endcase
    end

endmodule