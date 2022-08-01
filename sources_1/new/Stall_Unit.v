`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2021 04:19:35 PM
// Design Name: 
// Module Name: stall_unit
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


module Stall_Unit(
    input mult_div_stall,
    input forwarding_rs,
    input forwarding_rt,
    input rf_stall_rs,
    input rf_stall_rt,
    
    input double_write_back_stall,
    
    output stall_cu_rd,
    output stall_ex,
    output stall_rf
    );
    
wire register_stall;
assign register_stall = (rf_stall_rs == 1 && forwarding_rs == 0) || (rf_stall_rt == 1 && forwarding_rt == 0);

assign stall_cu_rd = mult_div_stall || register_stall;
assign stall_ex = mult_div_stall;
assign stall_rf = mult_div_stall || double_write_back_stall;

endmodule
