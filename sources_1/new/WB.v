`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2021 03:18:47 PM
// Design Name: 
// Module Name: WB
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


module WB(
    input [5:0] opcode,
    input [4:0] rd,
    input register_write,
    input [31:0] result,
    output [4:0] rd_o,
    output [31:0] result_o
    );
wire [5:0] op;
assign op = opcode;
assign rd_o = register_write ?  rd : 0; //register_write ? (((op == 1 && (rd == 16 || rd == 17)) || op == 3) ? 31 : rd) : 0;
assign result_o = register_write ? result : 0;
endmodule
