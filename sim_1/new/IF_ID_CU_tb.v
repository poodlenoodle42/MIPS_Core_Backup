`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2021 12:42:16 PM
// Design Name: 
// Module Name: IF_ID_CU_tb
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


module IF_ID_CU_tb();

reg [31:0] instruction_bus;
reg stall;
reg branch;
reg [31:0] branch_target;
reg clk;

wire [31:0] instruction_address;
wire [5:0] opcode;
wire [4:0] rs;
wire [4:0] rt;
wire [4:0] rd;
wire [4:0] rw;
wire [4:0] shamt;
wire [5:0] funct;
wire [15:0] immediate;
wire [25:0] jump_target;
wire [31:0] pc;
wire register_write;
wire branch_o;
initial begin 
    instruction_bus = 0;
    stall = 0;
    branch = 0;
    branch_target = 0;
    clk = 1;
    #2 instruction_bus = 31'h27bdffd0; //addiu sp,sp,-48
    #2 instruction_bus = 31'h00621021; //addu v0,v1,v0
    #2 instruction_bus = 31'h0c100828; //jal 4020a0
    #2 stall = 1;
    #2 instruction_bus = 31'h0c100828; //jal 4020a0
    stall = 0;
    #2
    branch = 1;
    branch_target = 31'h13569874;
    #2 instruction_bus = 31'h0c100828; //jal 4020a0
    branch = 0;
    #2
    #2 $finish;
    
end
always #1 clk = !clk;

IF_ID_CU control_unit (
    .instruction_bus (instruction_bus),
    .stall (stall),
    .branch (branch),
    .branch_target (branch_target),
    .clk (clk),
    .instruction_address (instruction_address),
    .op (opcode),
    .rs (rs),
    .rt (rt),
    .rd (rd),
    .rw (rw),
    .shamt (shamt),
    .funct (funct),
    .immediate (immediate),
    .target (jump_target),
    .pc (pc),
    .register_write (register_write),
    .branch_o (branch_o)
);

endmodule
