`timescale 1ns / 1ps

module tb_rv32i ();
    RV32I_TOP u_RV32I (.*);

    logic clk = 0;
    logic reset = 1;

    always #5 clk = ~clk;

    initial begin
        #30;
        reset = 0;
        #100;
        $stop;
    end


endmodule