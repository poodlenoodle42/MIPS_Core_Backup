`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2021 11:01:43 AM
// Design Name: 
// Module Name: Image_Memory
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

module Image_Memory(
    input [31:0] instruction_address,
    output reg [31:0] instruction_bus,
    input [31:0] data_address,
    inout [31:0] data_bus,
    input data_cs,
    input data_rw,
    input [1:0] data_mode,
    input clk
    );

reg [31:0] mbr;
assign data_bus = (data_rw == 0 && cs == 1) ? mbr : 32'bz;

parameter SIZE = 8192;
parameter ADDRESS = 'h80000000;
reg [31:0] memory [0:SIZE];

wire cs;
assign cs = (data_address >= ADDRESS && data_address < (ADDRESS + (SIZE * 4) - 1)) && data_cs ? 1 : 0;

wire [31:0] d_addr_internal;  
assign d_addr_internal = (data_address - ADDRESS) >> 2;

wire [31:0] i_addr_internal;
assign i_addr_internal = (instruction_address - ADDRESS) >> 2;

initial begin
    instruction_bus = 0;
    mbr = 0;
    $readmemh("prims.elf.mem",memory);
end

always @ (negedge clk) begin
    if(cs) begin
        mbr <= memory[d_addr_internal];
    end
    if((instruction_address >= ADDRESS && instruction_address < (ADDRESS + (SIZE * 4) - 1))) begin
        instruction_bus <= memory[i_addr_internal];
    end
end
        

endmodule
