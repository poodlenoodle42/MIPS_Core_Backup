`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2022 02:39:19 PM
// Design Name: 
// Module Name: Backroud_Layer
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


module Backround_Layer(
    input [31:0] data,
    output [29:0] address,
    input [15:0] pixel,
    input [15:0] line,
    input clk,
    output reg [15:0] tile_number,
    output reg [7:0] offset_x,
    output reg [7:0] offset_y
    );
    
wire [12:0] x_index = pixel / 10;
wire [12:0] y_index = line / 10;

wire [31:0] addr = (y_index * 80 + x_index) << 1;
   
assign address = addr[31:2];

always @(posedge clk) begin
    if(addr[1] == 0) begin
        tile_number <= data[31:16];  
    end else begin
        tile_number <= data[15:0];
    end
    offset_x <= pixel % 10;
    offset_y <= line % 10;
end
    
endmodule
