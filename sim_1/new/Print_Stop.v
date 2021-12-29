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
    input [31:0] data_address,
    inout [31:0] data_bus,
    input data_cs,
    input data_rw,
    input [1:0] data_mode,
    input clk
    );

reg [31:0] mbr;
assign data_bus = (data_rw == 0 && cs == 1) ? mbr : 32'bz;

wire cs;
assign cs = data_address == 1 || data_address == 2 && data_cs ? 1 : 0;

initial begin
    mbr = 0;
end

always @ (negedge clk) begin
    if (cs == 1) begin
        if(data_address == 1 && data_bus == 1 && data_rw == 1) begin 
            $finish;
        end else if (data_address == 2 && data_rw == 1) begin
            $write("%c",data_bus[7:0]);
        end
    end
end
endmodule
