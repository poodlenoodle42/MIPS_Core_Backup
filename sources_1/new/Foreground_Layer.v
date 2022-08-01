`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2022 10:42:07 AM
// Design Name: 
// Module Name: Foreground_Layer
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


module Foreground_Layer(
    input gpu_clk,
    input cpu_clk,
    input [29:0] data_address,
    inout [31:0] data_bus,
    input data_cs,
    input data_rw,
    
    input [15:0] pixel,
    input [15:0] line,
    
    output reg [15:0] tile_number,
    output reg [7:0] offset_x,
    output reg [7:0] offset_y
);

parameter SPRITES = 64;
parameter ADDRESS = 'h70100000;
wire [SPRITES-1:0] matches;
wire [15:0] tile_numbers [0:SPRITES-1];
wire [7:0] x_offsets [0:SPRITES-1];
wire [7:0] y_offsets [0:SPRITES-1];

genvar i;
generate 
    for(i = 0; i<SPRITES;i=i+1) begin : sprite_matchers
        Sprite_Matcher #(.ADDRESS(ADDRESS + i*8)) matcher (
            .gpu_clk (gpu_clk),
            .cpu_clk (cpu_clk),
            .data_address (data_address),
            .data_bus (data_bus),
            .data_cs (data_cs),
            .data_rw (data_rw),
            
            .pixel (pixel),
            .line (line),
            
            .match (matches[i]),
            .tile_number (tile_numbers[i]),
            .x_offset (x_offsets[i]),
            .y_offset (y_offsets[i])
        );
    end
endgenerate


integer j;
always @(posedge gpu_clk) begin
    if(matches != 0) begin
        for(j = 0;j < SPRITES;j = j+1) begin
            if(matches[j] == 1 && tile_numbers[j] != 'hffff) begin
                tile_number <= tile_numbers[j];
                offset_x <= x_offsets[j];
                offset_y <= y_offsets[j];
            end
        end
     end else begin
        offset_x <= 0;
        offset_y <= 0;
        tile_number <= 16'hffff;
     end

end

endmodule
