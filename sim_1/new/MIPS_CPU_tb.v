`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/29/2021 12:09:05 PM
// Design Name: 
// Module Name: MIPS_CPU_tb
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


module MIPS_CPU_tb();

wire [31:0] data_bus;
wire [29:0] data_address;
wire data_cs;
wire data_rw;

reg clk;
reg [31:0] value;

initial begin
    value = 0;
    #1 clk = 0;
end

assign data_bus = data_cs == 1 && data_rw == 0 && data_address == 0 ? value : 32'bz;

always #1 clk = !clk;

MIPS_CPU cpu (
    .clk (clk),
    .data_bus (data_bus),
    .data_address (data_address),
    .data_cs (data_cs),
    .data_rw (data_rw)
);

always @ (negedge clk) begin
    if (data_cs == 1 && data_rw == 1 && data_address == 0) begin
        if(data_bus[15:8] != 0) begin
            $write("%c",data_bus[15:8]);
        end else begin
            $finish;
        end
    end
end

endmodule
