`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2021 11:21:48 AM
// Design Name: 
// Module Name: RD_tb
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


module RD_tb();

reg [5:0] opcode;
reg [4:0] rd;
reg register_write;
reg branch;
reg [4:0] shamt;
reg [5:0] funct;
reg [15:0] immediate;
reg [25:0] target;
reg [31:0] pc;
reg [31:0] register_1;
reg [31:0] register_2;
reg stall;
reg clk;
wire [5:0] opcode_o;
wire [4:0] rd_o;
wire register_write_o;
wire branch_o;
wire [4:0] shamt_o;
wire [5:0] funct_o;
wire [25:0] target_o;
wire [31:0] pc_o;
wire [31:0] value_1;
wire [31:0] value_2;
wire [31:0] value_3;

initial begin 
    //beq 0,0,56
    clk = 0;
    opcode = 4;
    register_write = 0;
    branch = 1;
    immediate = 56;
    pc = 31;
    register_1 = 4;
    register_2 = 45;
    stall = 0;
    #2
    $finish;
end
always #1 clk = !clk;
RD read_register (
    .opcode (opcode),
    .rd (rd),
    .register_write (register_write),
    .branch (branch),
    .shamt (shamt),
    .funct (funct),
    .immediate (immediate),
    .target (target),
    .pc (pc),
    .register_1 (register_1),
    .register_2 (register_2),
    .stall (stall),
    .clk (clk),
    .opcode_o (opcode_o),
    .rd_o (rd_o),
    .register_write_o (register_write_o),
    .branch_o (branch_o),
    .shamt_o (shamt_o),
    .funct_o (funct_o),
    .target_o (target_o),
    .pc_o (pc_o),
    .value_1 (value_1),
    .value_2 (value_2),
    .value_3 (value_3)
);

endmodule
