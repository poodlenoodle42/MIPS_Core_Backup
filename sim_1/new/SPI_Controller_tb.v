`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2021 05:52:21 PM
// Design Name: 
// Module Name: SPI_Controller_tb
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


module SPI_Controller_tb();

reg clk;
reg spi_clk;
always #1 clk = !clk;
always #3 spi_clk = !spi_clk;
reg interrupt;
reg [7:0] value;
reg miso;
wire mosi;
wire spi_clk_o;
wire ss;


initial begin
    clk = 0;
    spi_clk = 0;
    #1 interrupt = 1;
    value = 42;
    #2 value = 255;
    #2 value = 64;
    #2 value = 33;
    #1 interrupt = 0;
    #300 $finish;
end

SPI_Controller spi (
    .clk (clk),
    .spi_clk (spi_clk),
    .interrupt (interrupt),
    .value (value),
    .miso (miso),
    .mosi (mosi),
    .ss (ss),
    .spi_clk_o (spi_clk_o)
);
endmodule
