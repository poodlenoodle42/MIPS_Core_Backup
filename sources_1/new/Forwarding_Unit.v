`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/15/2021 04:05:51 PM
// Design Name: 
// Module Name: Forwarding_Unit
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


module Forwarding_Unit(
    input clk,
    input [4:0] rs_cu,
    input [4:0] rt_cu,
    input [4:0] rd_cu,
    input register_write_cu,
    input [5:0] op_ex,
    input [4:0] rd_ex,
    input [31:0] value_ex,
    input register_write_ex,
    input [5:0] op_mem,
    input [4:0] rd_mem,
    input [31:0] value_mem,
    input register_write_mem,
    output forwarding_rs,
    output forwarding_rt,
    output [31:0] value_rs,
    output [31:0] value_rt
);

reg [4:0] rd_rd;
reg register_write_rd;


initial begin
    rd_rd = 0;
    register_write_rd = 0;
end

wire write_after_mem;
assign write_after_mem = op_ex == 32 || op_ex == 33 || op_ex == 34 || op_ex == 35 ||
                         op_ex == 36 || op_ex == 37 || op_ex == 38 || op_ex == 40 || 
                         op_ex == 41 || op_ex == 42 || op_ex == 43 || op_ex == 46;

wire forward_ex;
assign forward_ex = register_write_ex == 1 && !write_after_mem && (rd_ex != rd_rd || register_write_rd == 0) && rd_ex != 0;

wire forward_mem;
assign forward_mem = register_write_mem == 1 && (rd_mem != rd_rd || register_write_rd == 0) && (rd_mem != rd_ex || register_write_ex == 0) && rd_mem != 0;


wire forwarding_rs_ex;
assign forwarding_rs_ex = forward_ex == 1 && rd_ex == rs_cu ? 1 : 0;
wire forwarding_rt_ex;
assign forwarding_rt_ex = forward_ex == 1 && rd_ex == rt_cu ? 1 : 0;

wire forwarding_rs_mem;
assign forwarding_rs_mem = forward_mem == 1 && rd_mem == rs_cu ? 1 : 0;
wire forwarding_rt_mem;
assign forwarding_rt_mem = forward_mem == 1 && rd_mem == rt_cu ? 1 : 0;

assign forwarding_rs = forwarding_rs_ex || forwarding_rs_mem;
assign forwarding_rt = forwarding_rt_ex || forwarding_rt_mem;

assign value_rs = forwarding_rs_ex ? value_ex : (forwarding_rs_mem ? value_mem : 0);
assign value_rt = forwarding_rt_ex ? value_ex : (forwarding_rt_mem ? value_mem : 0);

always @ (posedge clk) begin
    rd_rd <= rd_cu;
    register_write_rd <= register_write_cu;
end

/*
assign forwarding_rs = 0;
assign forwarding_rt = 0;

assign value_rs = 0;
assign value_rt = 0;
*/
/*
always @ (negedge clk) begin
    rd_rd <= rd_cu;
    register_write_rd <= register_write_cu;
    if(forward_ex) begin
        if(rd_ex == rs_cu) begin
            forwarding_rs <= 1;
            value_rs <= value_ex;
        end else begin
            forwarding_rs <= 0;
        end
        if(rd_ex == rt_cu) begin
            forwarding_rt <= 1;
            value_rt <= value_ex;
        end else begin
            forwarding_rt <= 0;
        end
    end else if (forward_mem) begin
        if(rd_mem == rs_cu) begin
            forwarding_rs <= 1;
            value_rs <= value_mem;
        end else begin
            forwarding_rs <= 0;
        end
        if(rd_mem == rt_cu) begin
            forwarding_rt <= 1;
            value_rt <= value_mem;
        end else begin
            forwarding_rt <= 0;
        end
    end else begin
        forwarding_rt <= 0;
        forwarding_rs <= 0;
    end
    
end
*/

endmodule