`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2021 12:14:00 PM
// Design Name: 
// Module Name: Print_Stop
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


module Print_Stop(
    input [29:0] data_address,
    inout [31:0] data_bus,
    input data_cs,
    input data_rw,
    input [1:0] data_mode,
    input clk
    );

reg [31:0] mbr;
assign data_bus = (data_rw == 0 && cs == 1) ? mbr : 32'bz;

wire cs;
assign cs = data_address == 0 && data_cs == 1 ? 1 : 0;

initial begin
    mbr = 0;
end

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
