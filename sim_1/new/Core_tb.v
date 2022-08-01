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
wire [29:0] data_address;
wire [31:0] data_bus;
wire data_cs;
wire data_rw;
reg clk;

initial begin
    //$readmemh("prims.elf.mem",instruction_memory.memory);
    $readmemh("presentation_multiply.elf.mem", image.memory);
    clk = 1;
    //#100000000 $finish;
    
end

always #1 clk = !clk;

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
wire [31:0] data_bus_o;
wire [29:0] data_address_o;
wire data_cs_o;
wire data_rw_o;

Data_Write_Sync sync (
    .clk (clk),
    .data_bus_i (data_bus),
    .data_address_i (data_address),
    .data_cs_i (data_cs),
    .data_rw_i (data_rw),
    .data_mode (data_mode),
    .data_bus_o (data_bus_o),
    .data_address_o (data_address_o),
    .data_cs_o (data_cs_o),
    .data_rw_o (data_rw_o)
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

Internal_Memory #(.SIZE(40000), .ADDRESS('h80000000)) image (
    .clk (clk),
    .data_address (data_address),
    .data_bus (data_bus),
    .data_rw (data_rw),
    .data_cs (data_cs),
    
    .instruction_address (instruction_address[31:2]),
    .instruction_bus (instruction_bus)
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
/*
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
*/