`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2022 11:54:07 AM
// Design Name: 
// Module Name: GPIO_Controller
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


module GPIO_Controller(
    input cpu_clk,
    input data_rw,
    input data_cs,
    input [29:0] data_address,
    inout [31:0] data_bus,
    
    input [GPIO_PINS-1:0] gpio
);

parameter GPIO_PINS = 13;
parameter ADDRESS = 'h60000000;

reg [GPIO_PINS-1:0] values_temp;
reg [GPIO_PINS-1:0] values;

wire [31:0] values_to_read [0:(GPIO_PINS / 4) + 1];

genvar i;
generate
    for(i = 0; i < (GPIO_PINS / 4) + 1; i = i+1) begin
        assign values_to_read[i] = {{{7{1'b0}},values[i*4]},{{7{1'b0}},values[i*4+1]},{{7{1'b0}},values[i*4+2]},{{7{1'b0}},values[i*4+3]}}; 
    end
endgenerate

wire cs;
assign cs = (data_address >= (ADDRESS >> 2) && data_address  < ((ADDRESS >> 2) + (GPIO_PINS / 4) + 1)) && data_cs == 1 ? 1 : 0;

wire [29:0] internal_address;
assign internal_address = data_address - (ADDRESS >> 2);

assign data_bus = cs == 1 && data_rw == 0 ? values_to_read[internal_address] : 32'bz;


always @(posedge cpu_clk) begin
    values <= values_temp;
    values_temp <= gpio;
end 

endmodule
