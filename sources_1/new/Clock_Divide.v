`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2021 07:06:00 PM
// Design Name: 
// Module Name: Clock_Divide
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


module Clock_Divide(
    input clk,
    output reg clk_o
    );
    
parameter DIVIDE = 2;
reg [$clog2(DIVIDE) + 1:0] counter;

initial begin
    counter = 0;
    clk_o = 0;
end

always @ (posedge clk) begin
    if(counter == DIVIDE) begin
        counter <= 0;
        clk_o <= !clk_o;
    end else begin
        counter <= counter + 1;
    end
end

endmodule
