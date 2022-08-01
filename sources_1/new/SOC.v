`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2022 04:39:34 PM
// Design Name: 
// Module Name: SOC
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

module SOC(
    input spi_miso,
    input spi_clk,
    input cpu_clk,
    input gpu_clk,
    
    input [GPIO_PINS-1:0] gpio,
    
    output [23:0] gpu_pixel_data,
    output gpu_hsync,
    output gpu_vsync,
    output gpu_vde,
    
    output spi_clk_o,
    output spi_ss,
    output spi_mosi
    
    );
    
parameter GPIO_PINS = 18;

wire [31:0] data_bus;
wire [29:0] data_address;
wire data_cs;
wire data_rw;

MIPS_CPU cpu (
    .clk (cpu_clk),
    .data_bus (data_bus),
    .data_address (data_address),
    .data_cs (data_cs),
    .data_rw (data_rw)     
);

GPU gpu (
    .cpu_clk (cpu_clk),
    .gpu_clk (gpu_clk),
    .data_rw (data_rw),
    .data_cs (data_cs),
    .data_address (data_address),
    
    .data_bus (data_bus),
    .pixel (gpu_pixel_data),
    .vsync (gpu_vsync),
    .hsync (gpu_hsync),
    .vde (gpu_vde)
);

SPI_Controller spi_controller (
    .data_address (data_address),
    .data_rw (data_rw),
    .data_cs (data_cs),
    .clk (cpu_clk),
    .spi_clk (spi_clk),
    .miso (spi_miso),
    
    .data_bus (data_bus),
    .spi_clk_o (spi_clk_o),
    .ss (spi_ss),
    .mosi (spi_mosi)
);

GPIO_Controller #(.GPIO_PINS(GPIO_PINS), .ADDRESS('h60000000)) gpio_controller (
    .cpu_clk (cpu_clk),
    .data_bus (data_bus),
    .data_address (data_address),
    .data_rw (data_rw),
    .data_cs (data_cs),
    
    .gpio (gpio)
);

//Hallo
endmodule
