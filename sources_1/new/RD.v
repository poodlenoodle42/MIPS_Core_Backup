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
    input clk,
    input forwarding_rs,
    input forwarding_rt,
    input [31:0] fu_value_rs,
    input [31:0] fu_value_rt,
    output reg [5:0] opcode_o,
    output reg [4:0] rd_o,
    output reg register_write_o,
    output reg branch_o,
    output reg [4:0] shamt_o,
    output reg [5:0] funct_o,
    output reg [25:0] target_o,
    output reg [31:0] pc_o,
    output reg [31:0] value_1,
    output reg [31:0] value_2,
    output reg [31:0] value_3
    );

wire [31:0] immediate_extended;
assign immediate_extended = {{16{immediate[15]}}, immediate};

initial begin
    opcode_o = 0;
    rd_o = 0;
    register_write_o = 0;
    branch_o = 0;
    shamt_o = 0;
    funct_o = 0;
    target_o = 0;
    pc_o = 0;
    value_1 = 0;
    value_2 = 0;
    value_3 = 0;
end

always @ (posedge clk) begin
    if (stall == 0) begin
        opcode_o <= opcode;
        rd_o <= rd;
        register_write_o <= register_write;
        shamt_o <= shamt;
        funct_o <= funct;
        target_o <= target;
        pc_o <= pc;
        value_1 <= forwarding_rs == 1 ? fu_value_rs : register_1;
        value_2 <= forwarding_rt == 1 ? fu_value_rt : register_2;
        branch_o <= branch;
        if (branch == 1) begin
            value_3 <= immediate_extended << 2;
        end else begin
            value_3 <= immediate_extended;
        end
     end else begin 
        opcode_o <= 0;
        rd_o <= 0;
        register_write_o <= 0;
        shamt_o <= 0;
        funct_o <= 0;
        target_o <= 0;
        pc_o <= 0;
        value_1 <= 0;
        value_2 <= 0;
        value_3 <= 0;
        branch_o <= 0;
     end
end


endmodule
