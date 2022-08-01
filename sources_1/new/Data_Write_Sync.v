`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2022 05:45:46 PM
// Design Name: 
// Module Name: Data_Write_Sync
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


module Data_Write_Sync(
    input clk,
    inout [31:0] data_bus_i,
    input [31:0] data_address_i,
    input data_cs_i, 
    input data_rw_i, // 0 - read ; 1 - write
    input [1:0] data_mode, //0 Byte, 1 Halfword, 2 Word 
    inout [31:0] data_bus_o,
    output [29:0] data_address_o,
    output data_cs_o,
    output data_rw_o
);

wire direct_forwarding;
assign direct_forwarding = (data_mode == 2 || data_rw_i == 0) && data_cs_i == 1;
wire [29:0] word_address;
assign word_address = data_address_i[31:2];

assign data_address_o = direct_forwarding || non_word_write ? word_address : (write_back ? address_buffer : 32'bz);
assign data_bus_o =  data_mode == 2 && data_rw_i == 1 && data_cs_i == 1 ? data_bus_i : (write_back ? word_buffer : 32'bz); //Word write
assign data_bus_i = data_rw_i == 0 && data_cs_i == 1 ? data_bus_o : 32'bz; //Read

wire non_word_write;
assign non_word_write = data_mode != 2 && data_rw_i == 1 && data_cs_i == 1;

assign data_cs_o = direct_forwarding ? 1 : (non_word_write ? 1 : (write_back ? 1 : 0));
assign data_rw_o = direct_forwarding ? data_rw_i : (non_word_write ? 0 : (write_back ? 1 : 0));


reg [31:0] word_buffer;
reg [29:0] address_buffer;
reg in_operation;

reg last_was_non_word_write;
reg last_wrote_back;

wire [1:0] write_back_offset;
assign write_back_offset = data_address_i[1:0];

wire [31:0] byte_bit_mask;
assign byte_bit_mask = write_back_offset == 0 ? 32'h00ffffff : write_back_offset == 1 ? 32'hff00ffff : write_back_offset == 2 ? 32'hffff00ff : 32'hffffff00;

wire [31:0] halfword_bit_mask;
assign halfword_bit_mask = write_back_offset == 0 ? 32'h0000ffff : 32'hffff0000; //Only data_address % 4 == 0 oder == 2  

wire [31:0] write_back_word;
assign write_back_word =  data_mode == 1 ? (data_bus_o & halfword_bit_mask) | ({data_bus_i[15:0],{16{1'b0}}} >> (write_back_offset*8)) : (data_bus_o & byte_bit_mask) | ({data_bus_i[7:0],{24{1'b0}}} >> (write_back_offset*8));

wire write_back;
assign write_back = in_operation == 1 && data_cs_i == 0;


initial begin
    word_buffer = 0;
    address_buffer = 0;
    in_operation = 0;
    last_was_non_word_write = 0;
    last_wrote_back = 0;
end

always @(posedge clk) begin 
    if(last_was_non_word_write) begin
        word_buffer <= write_back_word;
        address_buffer <= word_address;
        in_operation <= 1;
    end
    else if(last_wrote_back) begin
        in_operation <= 0;
    end
end 

always @(negedge clk) begin
    if(non_word_write) begin
        last_was_non_word_write <= 1;
    end else begin
        last_was_non_word_write <= 0;
    end
    
    if(write_back) begin
        last_wrote_back <= 1;
    end else begin
        last_wrote_back <= 0;
    end
end

endmodule
