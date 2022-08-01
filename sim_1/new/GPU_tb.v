`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2022 03:57:02 PM
// Design Name: 
// Module Name: GPU_tb
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


module GPU_tb();

reg [29:0] data_address;
reg [31:0] data_bus_reg;

wire [31:0] data_bus;
assign data_bus = data_cs == 1 && data_rw == 1 ? data_bus_reg : 32'bz;

reg data_cs;
reg data_rw;
reg cpu_clk;
reg gpu_clk;

wire [23:0] pixel_data;
wire hsync;
wire vsync;
wire vde;

integer i;
initial begin
    cpu_clk = 0;
    gpu_clk = 0;
    data_cs = 0;
    data_rw = 0;
    for(i = 0; i<25600;i=i+1) begin
        uut.backround_tile_data.memory[i] = i*4;
    end
    
    
    for(i = 1; i<2400;i=i+1) begin
        uut.backround_tile_numbers.memory[i] = i;
    end 
    
    uut.backround_tile_numbers.memory[0] = 32'h00020000;
    
    #100000 $finish;
end

always #1 cpu_clk = !cpu_clk;
always #2 gpu_clk = !gpu_clk;


GPU uut (
    .data_address (data_address),
    .data_bus (data_bus),
    .data_cs (data_cs),
    .data_rw (data_rw),
    .cpu_clk (cpu_clk),
    .gpu_clk (gpu_clk),
    .pixel (pixel_data),
    .vsync (vsync),
    .hsync (hsync),
    .vde (vde)
);

endmodule
