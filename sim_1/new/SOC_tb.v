`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2022 05:01:55 PM
// Design Name: 
// Module Name: SOC_tb
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


module SOC_tb();


reg spi_miso;
reg spi_clk;
reg cpu_clk;
reg gpu_clk;

reg [17:0] gpio;

wire [23:0] gpu_pixel_data;
wire gpu_hsync;
wire gpu_vsync;
wire gpu_vde;
wire spi_clk_o;
wire spi_ss;
wire spi_mosi;

SOC uut (
    .spi_miso (spi_miso),
    .spi_clk (spi_clk),
    .cpu_clk (cpu_clk),
    .gpu_clk (gpu_clk),
    .gpu_pixel_data (gpu_pixel_data),
    .gpu_hsync (gpu_hsync),
    .gpu_vsync (gpu_vsync),
    .gpu_vde (gpu_vde),
    .spi_clk_o (spi_clk_o),
    .spi_ss (spi_ss),
    .spi_mosi (spi_mosi),
    
    .gpio (gpio)
);

reg [7:0] value;
reg [3:0] counter;

initial begin
    value = 0;
    counter = 0;
    spi_miso = 0;
    spi_clk = 0;
    cpu_clk = 0;
    gpu_clk = 0;
    gpio = 0;
    #1000
    gpio[2] = 1;
    gpio[10] = 1;
    #1000
    gpio[2] = 0;
    gpio[4] = 1;
    gpio[6] = 1;
    #1000
    gpio[16] = 1;
    gpio[14] = 1;
end

always #2 cpu_clk = !cpu_clk;
always #3 gpu_clk = !gpu_clk;
always #5 spi_clk = !spi_clk;

integer i;
always @ (posedge spi_clk_o) begin
    if(spi_ss == 0) begin
        for(i = 0; i < 7; i = i + 1) begin
            value[i+1] <= value[i];
        end
        value[0] <= spi_mosi;
        
    end
end

always @ (negedge spi_clk_o) begin
    
    if(counter == 7) begin
        counter <= 0;
        if(value == 0) begin
            $finish;
        end else begin
            $write("%c",value);
            value <= 0;
            counter <= 0;
        end
    end else if (spi_ss == 0) begin
        counter <= counter + 1;
    end
end

endmodule
