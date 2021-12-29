`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/29/2021 12:09:05 PM
// Design Name: 
// Module Name: MIPS_CPU_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MIPS_CPU_tb();

wire [7:0] value;
wire interrupt;
reg clk;

initial begin
    #1 clk = 0;
end

always #1 clk = !clk;

MIPS_CPU cpu (
    .clk (clk),
    .value (value),
    .interrupt (interrupt)
);

always @ (negedge clk) begin
    if (interrupt == 1) begin
        if(value != 0) begin
            $write("%c",value);
        end else begin
            $finish;
        end
    end
end

endmodule
