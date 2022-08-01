`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2021 07:37:04 PM
// Design Name: 
// Module Name: RD
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


module RD(
    input [5:0] opcode,
    input [4:0] rd,
    input register_write,
    input branch,
    input [4:0] shamt,
    input [5:0] funct,
    input [15:0] immediate,
    input [25:0] target,
    input [31:0] pc,
    input [31:0] register_1,
    input [31:0] register_2,
    input stall,
    
    input double_write_back_stall,
    
    input clk,
    input forwarding_rs,
    input forwarding_rt,
    input [31:0] fu_value_rs,
    input [31:0] fu_value_rt,
    output [5:0] opcode_o,
    output [4:0] rd_o,
    output register_write_o,
    output branch_o,
    output [4:0] shamt_o,
    output [5:0] funct_o,
    output [25:0] target_o,
    output [31:0] pc_o,
    output [31:0] value_1,
    output [31:0] value_2,
    output [31:0] value_3
    );

wire [31:0] immediate_extended;
assign immediate_extended = {{16{immediate[15]}}, immediate};

initial begin
    opcode_o_reg = 0;
    rd_o_reg = 0;
    register_write_o_reg = 0;
    branch_o_reg = 0;
    shamt_o_reg = 0;
    funct_o_reg = 0;
    target_o_reg = 0;
    pc_o_reg = 0;
    value_1_reg = 0;
    value_2_reg = 0;
    value_3_reg = 0;
end

reg [5:0] opcode_o_reg;
reg [4:0] rd_o_reg;
reg register_write_o_reg;
reg branch_o_reg;
reg [4:0] shamt_o_reg;
reg [5:0] funct_o_reg;
reg [25:0] target_o_reg;
reg [31:0] pc_o_reg;
reg [31:0] value_1_reg;
reg [31:0] value_2_reg;
reg [31:0] value_3_reg;

/*
assign opcode_o = stall ? 0 : opcode_o_reg;
assign rd_o = stall ? 0 : rd_o_reg;
assign register_write_o = stall ? 0 : register_write_o_reg;
assign branch_o = stall ? 0 : branch_o_reg;
assign shamt_o = stall ? 0 : shamt_o_reg;
assign funct_o = stall ? 0 : funct_o_reg;
assign target_o = stall ? 0 : target_o_reg;
assign pc_o = stall ? 0 : pc_o_reg;
assign value_1 = stall ? 0 : value_1_reg;
assign value_2 = stall ? 0 : value_2_reg;
assign value_3 = stall ? 0 : value_3_reg;
*/

assign opcode_o = opcode_o_reg;
assign rd_o = rd_o_reg;
assign register_write_o = register_write_o_reg;
assign branch_o = branch_o_reg;
assign shamt_o = shamt_o_reg;
assign funct_o = funct_o_reg;
assign target_o = target_o_reg;
assign pc_o = pc_o_reg;
assign value_1 = value_1_reg;
assign value_2 = value_2_reg;
assign value_3 = value_3_reg;

wire zero_extend = opcode == 12 || opcode == 13 || opcode == 14 || opcode == 15 ? 1 : 0;


always @ (posedge clk) begin
if(double_write_back_stall == 0) begin
    if (stall == 0) begin
        opcode_o_reg <= opcode;
        rd_o_reg <= rd;
        register_write_o_reg <= register_write;
        shamt_o_reg <= shamt;
        funct_o_reg <= funct;
        target_o_reg <= target;
        pc_o_reg <= pc;
        value_1_reg <= forwarding_rs == 1 ? fu_value_rs : register_1;
        value_2_reg <= forwarding_rt == 1 ? fu_value_rt : register_2;
        branch_o_reg <= branch;
        if (branch == 1) begin
            value_3_reg <= immediate_extended << 2;
        end else if(zero_extend == 1) begin
            value_3_reg <= {{16{1'b0}}, immediate};
        end else begin
            value_3_reg <= immediate_extended;
        end
     
     end  else begin 
        opcode_o_reg <= 0;
        rd_o_reg <= 0;
        register_write_o_reg <= 0;
        shamt_o_reg <= 0;
        funct_o_reg <= 0;
        target_o_reg <= 0;
        pc_o_reg <= 0;
        value_1_reg <= 0;
        value_2_reg <= 0;
        value_3_reg <= 0;
        branch_o_reg <= 0;
     end
end
end


endmodule
