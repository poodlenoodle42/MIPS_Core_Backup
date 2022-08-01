`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2022 03:43:39 PM
// Design Name: 
// Module Name: GPU_Status
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


module GPU_Status(
    input cpu_clk,

    input [29:0] data_address,
    
    inout [31:0] data_bus,
    
    input data_cs,
    input data_rw,
    
    input [15:0] pixel,
    input [15:0] line
    );
    
    
parameter ADDRESS = 'h70000000;

reg [31:0] lines_pixels;

assign data_bus = data_cs == 1 && data_rw == 0 && data_address == (ADDRESS >> 2) ? lines_pixels : 32'bz;

always @(posedge cpu_clk) begin
    lines_pixels[31:16] <= pixel;
    lines_pixels[15:0] <= line;
end


endmodule
