`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2022 09:58:32 AM
// Design Name: 
// Module Name: Sprite_Matcher
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


module Sprite_Matcher(
    input gpu_clk,
    input cpu_clk,
    input [29:0] data_address,
    inout [31:0] data_bus,
    input data_cs,
    input data_rw,
    
    input [15:0] pixel,
    input [15:0] line,
    
    output match,
    output [15:0] tile_number,
    output [7:0] x_offset,
    output [7:0] y_offset
    
    );

parameter ADDRESS = 'h70000000;

reg [31:0] position;
reg [15:0] tile_number_reg;

initial begin
    position = 0;
    tile_number_reg = 16'hffff;
end

wire [15:0] x_position;
wire [15:0] y_position;
assign x_position = position[15:0];
assign y_position = position[31:16];

assign tile_number = tile_number_reg;
assign data_bus = data_cs == 1 && data_rw == 0 && data_address == (ADDRESS >> 2) ? position : (data_cs == 1 && data_rw == 0 && data_address == (ADDRESS >> 2) + 1 ? {tile_number,{16{1'b0}}} : 32'bz);

always @(negedge cpu_clk) begin
    if(data_cs == 1 && data_rw == 1 && data_address == (ADDRESS >> 2)) begin
        position <= data_bus;
    end else if (data_cs == 1 && data_rw == 1 && data_address == (ADDRESS >> 2) + 1) begin
        tile_number_reg <= data_bus[31:16];
    end
end

wire match_x;
assign match_x = pixel >= x_position && pixel < x_position + 16;
wire match_y;
assign match_y = line >= y_position && line < y_position + 16;

//wire match;
//wire x_offset;
//wire y_offset;
assign match = match_x & match_y;
assign x_offset = (pixel - x_position) % 16;
assign y_offset = (line - y_position) % 16;



endmodule
