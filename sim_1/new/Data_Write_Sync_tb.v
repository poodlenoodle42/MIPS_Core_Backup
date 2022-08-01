`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2022 11:22:48 AM
// Design Name: 
// Module Name: Data_Write_Sync_tb
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


module Data_Write_Sync_tb(

    );
    

reg clk;    
reg [31:0] data_in;
wire [31:0] data_bus_i;
reg [31:0] data_address_i;
reg data_cs_i;
reg data_rw_i;
reg [1:0] data_mode;
assign data_bus_i = data_rw_i == 1 && data_cs_i == 1 ? data_in : 32'bz;

wire [29:0] data_address_o;
wire data_cs_o;
wire data_rw_o;
wire [31:0] data_bus_o;
reg [31:0] value_to_read;
assign data_bus_o = data_rw_o == 0 && data_cs_o == 1 ? value_to_read : 32'bz;

initial begin
    clk = 0;
    #1
    //Write 12345678 word
    data_in = 32'h12345678;
    data_address_i = 32'h80000000;
    data_cs_i = 1;
    data_rw_i = 1;
    data_mode = 2;
    #2 
    value_to_read = 32'habcdef12;
    data_cs_i = 0;
    #6 
    //Read half word
    data_cs_i = 1;
    data_rw_i = 0;
    data_mode = 1;
    #2
    data_cs_i = 0;
    #6
    //Overwrite lower half word with faab
    data_cs_i = 1;
    data_rw_i = 1;
    data_in = 32'h0000faab;
    #2
    data_rw_i = 0;
    #2
    data_cs_i = 0;
    #6 
    $finish;
end

always #1 clk = !clk;


always @(negedge clk) begin
    if(data_cs_o == 1 && data_rw_o == 1) begin
        value_to_read <= data_bus_o;
    end
end


Data_Write_Sync uut(
    .clk(clk),
    .data_bus_i(data_bus_i),
    .data_address_i (data_address_i),
    .data_cs_i (data_cs_i),
    .data_rw_i (data_rw_i),
    .data_mode(data_mode),
    .data_bus_o (data_bus_o),
    .data_address_o (data_address_o),
    .data_cs_o (data_cs_o),
    .data_rw_o (data_rw_o)
    
);



endmodule
