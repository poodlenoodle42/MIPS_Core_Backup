`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2021 08:02:26 AM
// Design Name: 
// Module Name: MIPS_CPU
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


module MIPS_CPU(

    input clk,
    output reg [7:0] value,
    output reg interrupt
    );
    
    

wire [31:0] instruction_address;
wire [31:0] instruction_bus;
wire [31:0] data_address;
wire [31:0] data_bus;
wire data_cs;
wire data_rw;
wire [1:0] data_mode;

initial begin
    value = 0;
    interrupt = 0;
end


Core mips_core (
    .instruction_address (instruction_address),
    .instruction_bus (instruction_bus),
    .data_address (data_address),
    .data_bus (data_bus),
    .data_cs (data_cs),
    .data_rw (data_rw),
    .data_mode (data_mode),
    .clk (clk)
);

Image_Memory  #(.SIZE(4096), .ADDRESS('h80000000)) instruction_memory (
    .instruction_address (instruction_address),
    .instruction_bus (instruction_bus),
    .data_address (data_address),
    .data_bus (data_bus),
    .data_cs (data_cs),
    .data_rw (data_rw),
    .data_mode (data_mode),
    .clk (clk)
);

Internal_Memory #(.SIZE(4096), .ADDRESS('hfffffff0 - (4096 * 4))) stack (
    .data_address (data_address),
    .data_bus (data_bus),
    .data_cs (data_cs),
    .data_rw (data_rw),
    .data_mode (data_mode),
    .clk (clk)
);

always @(negedge clk) begin
    if(data_address == 2 && data_cs == 1 && data_rw == 1) begin
        value <= data_bus[7:0];
        interrupt <= 1;
    end else if (data_address == 1 && data_cs == 1 && data_rw == 1 && data_bus == 1) begin
        value <= 0;
        interrupt <= 1;
    end else begin
        interrupt <= 0;
    end
end   

endmodule
