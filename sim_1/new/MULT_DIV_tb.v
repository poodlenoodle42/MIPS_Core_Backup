`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2021 10:30:49 AM
// Design Name: 
// Module Name: MULT_DIV_tb
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


module MULT_DIV_tb();

reg clk;
reg enable;
reg [31:0] value_1;
reg [31:0] value_2;
reg [1:0] operation;

wire [63:0] out;
wire [31:0] hi = out[63:32];
wire [31:0] lo = out[31:0];
wire in_operation;

initial begin
    clk = 0;
    enable = 0;
    value_1 = 0;
    value_2 = 0;
    operation = 0;
    #1
    enable = 1;
    value_1 = 145;
    value_2 = 45;
    #2 
    enable = 0;
    #4
    enable = 1;
    operation = 2;
    #2 
    enable = 0;
    #76
    enable = 1;
    operation = 3;
    value_1 = 45;
    value_2 = -32;
    #2 enable = 0;
    #100 $finish;
    
end

always #1 clk <= !clk;

MULT_DIV uut (
    .clk (clk),
    .enable (enable),
    .value_1 (value_1),
    .value_2 (value_2),
    .operation (operation),
    .out (out),
    .in_operation (in_operation)
);

endmodule
