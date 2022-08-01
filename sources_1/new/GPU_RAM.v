`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2022 02:42:29 PM
// Design Name: 
// Module Name: GPU_RAM
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


module GPU_RAM(
    input [29:0] data_address,
    inout [31:0] data_bus,
    input data_cs,
    input data_rw,
    
    input [29:0] gpu_address,
    output [WORD_LENGTH-1:0] gpu_bus,
    
    input cpu_clk,
    input gpu_clk
    );
    
    
parameter SIZE = 0;
parameter ADDRESS = 32'h00000000;
parameter WORD_LENGTH = 32;
 
 
wire cs;
assign cs = ({data_address,2'b0}  >= ADDRESS && {data_address,2'b0}  < (ADDRESS + (SIZE * 4) - 1)) && data_cs == 1 ? 1 : 0;


wire [31:0] data_address_internal;
assign data_address_internal = ({data_address,2'b0} - ADDRESS) >> 2;

reg [WORD_LENGTH-1:0] mbr;
reg [WORD_LENGTH-1:0] gpu_mbr;

assign data_bus = cs == 1 && data_rw == 0 ? {{32-WORD_LENGTH{1'b0}},mbr} : 32'bz;
assign gpu_bus = gpu_mbr;

reg [WORD_LENGTH-1:0] memory [0:SIZE];

always @(negedge cpu_clk) begin
    if(cs == 1) begin
        if(data_rw == 0) begin
            mbr <= memory[data_address_internal];
        end else begin
            memory[data_address_internal] <= data_bus[WORD_LENGTH-1:0];
        end
    end
end

always @(negedge gpu_clk) begin
    gpu_mbr <= memory[gpu_address];
end

endmodule
