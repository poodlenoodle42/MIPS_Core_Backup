`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2021 08:18:35 PM
// Design Name: 
// Module Name: Core_tb
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


module Core_tb();

wire [31:0] instruction_address;
wire [31:0] instruction_bus;
wire [31:0] data_address;
wire [31:0] data_bus;
wire data_cs;
wire data_rw;
wire [1:0] data_mode;
reg clk;

initial begin
    //$readmemh("prims.elf.mem",instruction_memory.memory);
    clk = 0;
    #10000000 $finish;
end

always #1 clk = !clk;

Core mips_core (
    .instruction_address (instruction_address),
    .instruction_bus (instruction_bus),
    .data_address (data_address),
    .data_bus (data_bus),
    .data_cs (data_cs),
    .data_rw (data_rw),
    .data_mode (data_mode),
    .clk (clk)
);

Image_Memory  #(.SIZE(4096), .ADDRESS('h80000000)) instruction_memory (
    .instruction_address (instruction_address),
    .instruction_bus (instruction_bus),
    .data_address (data_address),
    .data_bus (data_bus),
    .data_cs (data_cs),
    .data_rw (data_rw),
    .data_mode (data_mode),
    .clk (clk)
);

Internal_Memory #(.SIZE(4096), .ADDRESS('hfffffff0 - (4096 * 4))) stack (
    .data_address (data_address),
    .data_bus (data_bus),
    .data_cs (data_cs),
    .data_rw (data_rw),
    .data_mode (data_mode),
    .clk (clk)
);  

Print_Stop p_s (
    .data_address (data_address),
    .data_bus (data_bus),
    .data_cs (data_cs),
    .data_rw (data_rw),
    .data_mode (data_mode),
    .clk (clk)
);

endmodule
