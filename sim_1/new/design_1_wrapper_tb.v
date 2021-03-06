`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2021 11:24:51 AM
// Design Name: 
// Module Name: design_1_wrapper_tb
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


module design_1_wrapper_tb();

reg clk;
wire hdmi_tx_clk_p;
wire hdmi_tx_clk_n;
wire [2:0] hdmi_tx_d_n;
wire [2:0] hdmi_tx_d_p;

reg ck_miso;
wire ck_ss;
wire ck_sck;
wire ck_mosi;

reg [7:0] value;
reg [3:0] counter;

initial begin
    ck_miso = 0;
    value = 0;
    counter = 0;
    #1000 clk = 0;
end
always #4 clk = !clk;


design_1_wrapper uut (
    .clk (clk),
    .hdmi_tx_clk_n (hdmi_tx_clk_n),
    .hdmi_tx_clk_p (hdmi_tx_clk_p),
    .hdmi_tx_d_n (hdmi_tx_d_n),
    .hdmi_tx_d_p (hdmi_tx_d_p),
    .ck_miso (ck_miso),
    .ck_mosi (ck_mosi),
    .ck_ss (ck_ss),
    .ck_sck (ck_sck)
);

integer i;
always @ (posedge ck_sck) begin
    if(ck_ss == 0) begin
        for(i = 0; i < 7; i = i + 1) begin
            value[i+1] <= value[i];
        end
        value[0] <= ck_mosi;
    end
end

always @ (negedge ck_sck) begin
    if(counter == 7) begin
        counter <= 0;
        if(value == 0) begin
            $finish;
        end else begin
            $write("%c",value);
            value <= 0;
            counter <= 0;
        end
    end else if (ck_ss == 0) begin
        counter <= counter + 1;
    end
end


endmodule
