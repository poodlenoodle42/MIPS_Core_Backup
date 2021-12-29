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
assign data_mode = (op == 40 || op == 32 || op == 36) ? 0 : (op == 41 || op == 33) ? 1 : 2; 

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
    /*
    lse if (op == 34) begin //lwl
        if (address % 4 == 0) begin
            result_o <= data_bus;
        end else if ((address + 1) % 4 == 0) begin
            result_o[31:24] <= data_bus[31:24];
            result_o[23:0] <= result[23:0];
        end else if ((address + 2) % 4 == 0) begin 
            result_o[31:16] <= data_bus[31:16];
            result_o[15:0] <= result[15:0];
        end else if ((address + 3) % 4 == 0) begin
            result_o[31:8] <= data_bus[31:8];
            result_o[7:0] <= result[7:0];
        end
   end
   */
   //lwl,lwr,swl,swr are currently not implemented, because they are complicated und not used in the test programm
end
endmodule
