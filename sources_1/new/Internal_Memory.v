`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2021 05:24:13 PM
// Design Name: 
// Module Name: Internal_Memory
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


module Internal_Memory(
    input [31:0] data_address,
    inout [31:0] data_bus,
    input data_cs,
    input data_rw,
    input [1:0] data_mode,
    input clk
    );

reg [31:0] mbr_reg;
wire [31:0] mbr;
assign mbr = write_back_needed == 1 && write_back_addr == d_addr_internal ? write_back_word_reg : mbr_reg;


assign data_bus = (data_rw == 0 && cs == 1) ? mbr : 32'bz;
parameter SIZE = 4096;
parameter ADDRESS = 32'h80000000;
reg [31:0] memory [0:SIZE];

wire cs;
assign cs = (data_address >= ADDRESS && data_address < (ADDRESS + (SIZE * 4) - 1)) && data_cs == 1 ? 1 : 0;

wire [31:0] d_addr_internal;  
assign d_addr_internal = (data_address - ADDRESS) >> 2;


reg [31:0] write_back_addr;
reg [31:0] write_back_value;
reg write_back_needed;
reg [1:0] write_back_mode;
reg [1:0] write_back_word_offset;
wire [31:0] write_back_word;
assign write_back_word = write_back_mode == 2 ? write_back_value : write_back_mode == 1 ? (mbr & halfword_bit_mask) | ({write_back_value[15:0],{16{1'b0}}} >> (write_back_word_offset*8)) : (mbr & byte_bit_mask) | ({write_back_value[7:0],{24{1'b0}}} >> (write_back_word_offset*8));
reg [31:0] write_back_word_reg;

integer i;
initial begin
    mbr_reg = 0;
    for(i = 0; i < SIZE; i = i + 1) begin
        memory[i] = 0;
    end
    write_back_addr = 0;
    write_back_value = 0;
    write_back_needed = 0;
    write_back_mode = 0;
    write_back_word_offset = 0;
    write_back_word_reg = 0;
end

wire [31:0] byte_bit_mask;
assign byte_bit_mask = write_back_word_offset == 0 ? 32'h00ffffff : write_back_word_offset == 1 ? 32'hff00ffff : write_back_word_offset == 2 ? 32'hffff00ff : 32'hffffff00;

wire [31:0] halfword_bit_mask;
assign halfword_bit_mask = write_back_word_offset == 0 ? 32'h0000ffff : 32'hffff0000; //Only data_address % 4 == 0 oder == 2  


always @ (negedge clk) begin
    if(cs == 1) begin
        mbr_reg <=  memory[d_addr_internal];
    end
    if(cs == 1 && data_rw == 1) begin
        write_back_addr <= d_addr_internal;
        write_back_mode <= data_mode;
        write_back_value <= data_bus;
        write_back_needed <= 1;
        write_back_word_offset <= data_address % 4;
    end
    if(write_back_needed == 1) begin
        memory[write_back_addr] <= write_back_word;
        write_back_word_reg <= write_back_word;
        if (cs == 0 || data_rw == 0) begin
            write_back_needed <= 0;
        end
    end

end


/*
always @ (negedge clk) begin
    if (cs == 1) begin
        if (data_rw == 0) begin
            mbr <= memory[d_addr_internal];
        end else begin
            if (data_mode == 2) begin
                memory[d_addr_internal] <= data_bus;
            end  else if (data_mode == 1) begin
                write_back_addr <= d_addr_internal;
                write_back_value <= (memory[d_addr_internal] & halfword_bit_mask) | ({data_bus[15:0],{16{1'b0}}} >> ((data_address % 4)*8));
                write_back_needed <= 1;
            end else if (data_mode == 0) begin
                write_back_addr <= d_addr_internal;
                write_back_value <= (memory[d_addr_internal] & byte_bit_mask) | ({data_bus[7:0],{24{1'b0}}} >> ((data_address % 4)*8));
                write_back_needed <= 1;
            end
        end
    end else if (write_back_needed == 1) begin
        write_back_needed <= 0;
        memory[write_back_addr] <= write_back_value;
    end
end
*/
endmodule
