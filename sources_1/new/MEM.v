`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2021 09:38:14 AM
// Design Name: 
// Module Name: MEM
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

module MEM(
    input [5:0] opcode,
    input [4:0] rd,
    input register_write,
    input [31:0] result,
    input [31:0] address,
    input clk,
    output reg [5:0] opcode_o,
    output reg [4:0] rd_o,
    output reg register_write_o,
    output reg [31:0] result_o,
    
    inout [31:0] data_bus,
    output reg [29:0] data_address,
    output reg data_rw,
    output reg data_cs,
    output reg double_write_back_stall
);

wire [5:0] op;
assign op = opcode;

wire rw;
assign rw = (op == 40 || op == 41 || op == 42 || op == 43 || op == 46) ? 1 : 0;
wire cs;
assign cs = (op == 32 || op == 33 || op == 34 || op == 35 || op == 36 || op == 37 || op == 38 || op == 40 ||
                  op == 41 || op == 42 || op == 43 || op == 46) ? 1 : 0;
wire [1:0] mode;
assign mode = (op == 40 || op == 32 || op == 36) ? 0 : (op == 41 || op == 33 || op == 37) ? 1 : 2; 


wire [29:0] address_out;
assign address_out = address[31:2];
wire [1:0] shift;
assign shift = address[1:0];

wire [31:0] value_to_read = write_back_needed == 1 && write_back_address == address_out ? write_back_word : data_bus;

wire [7:0] byte;
wire [15:0] halfword;
assign byte = shift == 0 ? value_to_read[31:24] : shift == 1 ? value_to_read[23:16] : shift == 2 ? value_to_read[15:8] : value_to_read[7:0];
assign halfword = shift == 0 ? value_to_read[31:16] : value_to_read[15:0];

wire [31:0] sign_extended_byte;
assign sign_extended_byte = {{24{byte[7]}},byte};

wire [31:0] sign_extended_hw;
assign sign_extended_hw = {{16{halfword[15]}},halfword};

reg write_back_succ;

reg write_back_needed_w;

reg write_back_needed;

//reg double_write_back_stall;

reg [31:0] write_back_word;
reg [29:0] write_back_address;

wire [31:0] byte_bit_mask;
assign byte_bit_mask = shift == 0 ? 32'h00ffffff : shift == 1 ? 32'hff00ffff : shift == 2 ? 32'hffff00ff : 32'hffffff00;

wire [31:0] halfword_bit_mask;
assign halfword_bit_mask = shift == 0 ? 32'h0000ffff : 32'hffff0000; //Only data_address % 4 == 0 oder == 2  

wire [31:0] write_back_word_w;
assign write_back_word_w = mode == 1 ? (data_bus & halfword_bit_mask) | ({result[15:0],{16{1'b0}}} >> (shift*8)) : (data_bus & byte_bit_mask) | ({result[7:0],{24{1'b0}}} >> (shift*8));


reg [31:0] data_to_bus;
assign data_bus = data_rw == 1 && data_cs == 1 ? data_to_bus : 32'bz;

always @(*) begin
    if(cs == 1) begin
        if(rw == 1) begin
            if(mode != 2) begin
                if(write_back_needed == 0) begin
                    data_rw = 0;
                    data_cs = 1;
                    //data_bus = 32'bz;
                    write_back_needed_w = 1;
                    double_write_back_stall = 0;
                    write_back_succ = 0;
                end else begin
                    data_rw = 1;
                    data_cs = 1;
                    data_to_bus = write_back_word;
                    write_back_succ = 1;
                    data_address = write_back_address;
                    double_write_back_stall = 1;
                end
            end else begin
                data_rw = 1;
                data_cs = 1;
                
                //data_bus = result;
                data_to_bus = result;
                write_back_succ = 0;
                write_back_needed_w = 0;
                double_write_back_stall = 0;
            end
        end else begin
            //data_bus = 32'bz;
            data_cs = 1;
            data_rw = 0;
            write_back_needed_w = 0;
            double_write_back_stall = 0;
            write_back_succ = 0;
        end
        data_address = address_out;
        
    end else begin
        double_write_back_stall = 0;
        write_back_needed_w = 0;
        if(write_back_needed == 1) begin
            data_rw = 1;
            data_cs = 1;
            
            //data_bus = write_back_word;
            data_to_bus = write_back_word;
            write_back_succ = 1;
            data_address = write_back_address;
        end else begin
            data_rw = 0;
            data_cs = 0;
            //data_bus = 32'bz;
            data_address = 0;
            write_back_succ = 0;
        end
    end
end

initial begin 
    opcode_o = 0;
    rd_o = 0;
    result_o = 0;
    register_write_o = 0;
    write_back_needed = 0;
    write_back_word = 0;
    write_back_address = 0;
    
end

always @(posedge clk) begin
if(double_write_back_stall == 0) begin
    opcode_o <= opcode;
    rd_o <= rd;
    register_write_o <= register_write;
    result_o <= result;
    
    if (op == 32) begin //lb
        result_o <= sign_extended_byte;
    end else if (op == 36) begin //lbu
        result_o <= {{24{1'b0}},byte};
    end else if (op == 33) begin //lh
        result_o <= sign_extended_hw;
    end else if (op == 37) begin //lhu
        result_o <= {{16{1'b0}},halfword};
    end else if (op == 35) begin //lw
        result_o <= data_bus;
    end else begin
        result_o <= result;
    end
end
    if(write_back_needed == 0) begin
        write_back_needed <= write_back_needed_w;
    end else if (write_back_needed == 1 && write_back_succ == 1) begin
        write_back_needed <= 0;
    end
    if(write_back_needed == 0) begin
        write_back_word <= write_back_word_w;
        write_back_address <= address_out;
    end
    
end

endmodule
/*
module MEM(
    input [5:0] opcode,
    input [4:0] rd,
    input register_write,
    input [31:0] result,
    input [31:0] address,
    inout [31:0] data_bus,
    input clk,
    output reg [5:0] opcode_o,
    output reg [4:0] rd_o,
    output reg register_write_o,
    output reg [31:0] result_o,
    output [31:0] data_address,
    output data_rw,
    output data_cs,
    output [1:0] data_mode
    );
    

//reg [5:0] opcode_internal;
//reg [4:0] rd_internal;
//reg register_write_internal;
//reg [31:0] result_internal;


wire [5:0] op;
assign op = opcode;
assign data_bus = data_rw == 1 && data_cs == 1 ? result : 32'bz; 

wire [7:0] byte;
wire [15:0] halfword;
wire [1:0] shift;
assign shift = address[1:0];
assign byte = shift == 0 ? data_bus[31:24] : shift == 1 ? data_bus[23:16] : shift == 2 ? data_bus[15:8] : data_bus[7:0];
assign halfword = shift == 0 ? data_bus[31:16] : data_bus[15:0];
wire [31:0] sign_extended_byte;
assign sign_extended_byte = {{24{byte[7]}},byte};

wire [31:0] sign_extended_hw;
assign sign_extended_hw = {{16{halfword[15]}},halfword};

//wire data_rw_w;
assign data_rw = (op == 40 || op == 41 || op == 42 || op == 43 || op == 46) ? 1 : 0;

//wire data_cs_w;
assign data_cs = (op == 32 || op == 33 || op == 34 || op == 35 || op == 36 || op == 37 || op == 38 || op == 40 ||
                  op == 41 || op == 42 || op == 43 || op == 46) ? 1 : 0;

//wire [1:0] data_mode_w;
assign data_mode = (op == 40 || op == 32 || op == 36) ? 0 : (op == 41 || op == 33 || op == 37) ? 1 : 2; 

assign data_address = address;

initial begin 
    opcode_o = 0;
    rd_o = 0;
    result_o = 0;
    register_write_o = 0;
    
end


always @ (posedge clk) begin
   
    opcode_o <= opcode;
    rd_o <= rd;
    register_write_o <= register_write;
    result_o <= result;
    
    if (op == 32) begin //lb
        result_o <= sign_extended_byte;
    end else if (op == 36) begin //lbu
        result_o <= {{24{1'b0}},byte};
    end else if (op == 33) begin //lh
        result_o <= sign_extended_hw;
    end else if (op == 37) begin //lhu
        result_o <= {{16{1'b0}},halfword};
    end else if (op == 35) begin //lw
        result_o <= data_bus;
    end else begin
        result_o <= result;
    end

   //lwl,lwr,swl,swr are currently not implemented, because they are complicated und not used in the test programm
end
endmodule
*/

