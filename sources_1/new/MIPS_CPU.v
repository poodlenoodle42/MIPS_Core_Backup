`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2021 08:02:26 AM
// Design Name: 
// Module Name: MIPS_CPU
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


module MIPS_CPU(
    input clk,
    inout [31:0] data_bus,
    output [29:0] data_address,
    output data_cs,
    output data_rw
);
    
    

wire [31:0] instruction_address;
wire [31:0] instruction_bus;
wire [31:0] data_address;
wire [31:0] data_bus;
wire data_cs;
wire data_rw;




Core mips_core (
    .instruction_address (instruction_address),
    .instruction_bus (instruction_bus),
    .data_address (data_address),
    .data_bus (data_bus),
    .data_cs (data_cs),
    .data_rw (data_rw),
    .clk (clk)
);

/*
Data_Write_Sync sync (
    .clk (clk),
    .data_bus_i (data_bus),
    .data_address_i (data_address),
    .data_cs_i (data_cs),
    .data_rw_i (data_rw),
    .data_mode (data_mode),
    .data_bus_o (data_bus_out),
    .data_address_o (data_address_out),
    .data_cs_o (data_cs_out),
    .data_rw_o (data_rw_out)
);
*/

Internal_Memory #(.SIZE(6000), .ADDRESS('hfffffff0 - (6000 * 4))) stack (
    .clk (clk),
    .data_address (data_address),
    .data_bus (data_bus),
    .data_rw (data_rw),
    .data_cs (data_cs),
    
    .instruction_address (instruction_address[31:2]),
    .instruction_bus (instruction_bus)
);

Internal_Memory #(.SIZE(32000), .ADDRESS('h80000000), .INIT(1)) image (
    .clk (clk),
    .data_address (data_address),
    .data_bus (data_bus),
    .data_rw (data_rw),
    .data_cs (data_cs),
    
    .instruction_address (instruction_address[31:2]),
    .instruction_bus (instruction_bus)
);


endmodule
