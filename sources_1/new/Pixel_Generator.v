`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2022 05:29:07 PM
// Design Name: 
// Module Name: Pixel_Generator
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


module Pixel_Generator(
    input clk,
    input [15:0] tile_number,
    input [7:0] tile_offset_x,
    input [7:0] tile_offset_y,
    
    input [23:0] pixel_data,
    output [29:0] addr,
    
    output reg [23:0] pixel_value


    );

parameter TILE_SIZE = 10;

assign addr = TILE_SIZE*TILE_SIZE * tile_number + (tile_offset_y * TILE_SIZE + tile_offset_x);

always @(posedge clk) begin
    if(tile_number == 16'hffff) begin
        pixel_value <= 0;
    end else begin
        pixel_value <= pixel_data;
    end
end
    

endmodule
