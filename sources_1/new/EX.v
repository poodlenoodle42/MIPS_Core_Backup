`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2021 12:00:37 PM
// Design Name: 
// Module Name: EX
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


module EX(
    input [5:0] opcode,
    input [4:0] rd,
    input register_write,
    input branch,
    input [4:0] shamt,
    input [5:0] funct,
    input [25:0] target,
    input [31:0] pc,
    input [31:0] value_1,
    input [31:0] value_2,
    input [31:0] value_3,
    input clk,
    input stall,
    
    input double_write_back_stall,
    
    
    output reg [5:0] opcode_o,
    output reg [4:0] rd_o,
    output reg register_write_o,
    output reg [31:0] result,
    output reg branch_o,
    output reg [31:0] address,
    output stall_o
    );
wire [5:0] op;
assign op = opcode;
wire [31:0] shift_input_2;
assign shift_input_2 = (funct == 0 || funct == 3 || funct == 2) ? {{27{1'b0}}, shamt} : value_1;

wire [31:0] shift_left_logical;
assign shift_left_logical = value_2 << shift_input_2;
wire [31:0] shift_right_logical;
assign shift_right_logical = value_2 >> shift_input_2;

wire [31:0] shift_left_arithmetic;
assign shift_left_arithmetic = value_2 <<< shift_input_2;
wire [31:0] shift_right_arithmetic;
assign shift_right_arithmetic = value_2 >>> shift_input_2;

wire [31:0] arithmetic_input; 
assign arithmetic_input = (op == 0 || op == 4 || op == 5) ? value_2 : value_3;

wire [31:0] add;
assign add = value_1 + arithmetic_input;

wire [31:0] subtract;
assign subtract = value_1 - arithmetic_input;

wire [31:0] and_w;
assign and_w = value_1 & arithmetic_input;

wire [31:0] or_w;
assign or_w = value_1 | arithmetic_input;

wire [31:0] xor_w;
assign xor_w = value_1 ^ arithmetic_input;

wire [31:0] nor_w;
assign nor_w = ~or_w;

wire [31:0] address_w_input;
assign address_w_input = branch == 0 ? value_1 : pc;

wire [31:0] address_w;
assign address_w = address_w_input + value_3;

wire equal;
assign equal = value_1 == arithmetic_input;

wire bigger;
assign bigger = value_1 > arithmetic_input;

wire bigger_signed;
assign bigger_signed = $signed(value_1) > $signed(arithmetic_input);

wire smaller;
assign smaller = (!bigger && !equal);

wire smaller_signed;
assign smaller_signed = (!bigger_signed && !equal);

wire jump;
assign jump = ((op == 4 && equal) || //beq
              (op == 1 && (((rd == 1 || rd == 17) && value_1[31] == 0) || //bgez and bgezal
              (rd == 0 && (rd == 0 || rd == 16) && value_1[31] == 1))) || //bltz and bltzal
              (op == 7 && value_1[31] == 0 && value_1 > 0) || //bgtz
              (op == 6 && (value_1[31] == 1 || value_1 == 0)) || //blez
              (op == 5 && !equal) || //bne
              (op == 2) || // j
              (op == 3) || // jal
              (op == 0 && (funct == 9 || funct == 8)) // jalr and jr
              ); 


wire [63:0] mult_div_out;
reg [63:0] mul_result;
wire [31:0] lo = mul_result[31:0];
wire [31:0] hi = mul_result[63:32];
wire mult_div_in_operation;
assign stall_o = mult_div_in_operation;
wire enable = op == 0 && (funct == 26 || funct == 27 || funct == 24 || funct == 25) ? 1 : 0;
wire [1:0] operation = {funct[1],!funct[0]}; 
reg division;
reg last_mult_div_in_operation;
MULT_DIV mult_div(
    .clk (clk),
    .enable (enable),
    .value_1 (value_1),
    .value_2 (value_2),
    .operation (operation),
    .out (mult_div_out),
    .in_operation (mult_div_in_operation)
);

initial begin 
    opcode_o = 0;
    rd_o = 0;
    register_write_o = 0;
    result = 0;
    branch_o = 0;
    address = 0;
    mul_result = 0;
    division = 0;
end

always @ (posedge clk) begin
if(double_write_back_stall == 0) begin
    rd_o <= rd;
    register_write_o <= register_write;
    opcode_o <= opcode;
    last_mult_div_in_operation <= mult_div_in_operation;
    if((op == 0 && (funct == 32 || funct == 33)) || op == 8 || op == 9) begin //add,addi,addiu,addu
        result <= add;
    end else if ((op == 0 && funct == 36) || op == 12) begin //and, and_i
        result <= and_w;
    end else if (op == 0 && (funct == 26 || funct == 27)) begin //div,divu
        division <= 1;
    end else if (op == 15) begin //lui 
        result <= value_3 << 16;
    end else if (op == 0 && funct == 18) begin //mflo
        result <= lo;
    end else if (op == 0 && funct == 16) begin //mfhi
        result <= hi;
    end else if (op == 0 && funct == 17) begin //mthi
        mul_result[63:32] <= value_1;
    end else if (op == 0 && funct == 19) begin //mtlo
        mul_result[31:0] <= value_1;
    end else if (op == 0 && (funct == 24 || funct == 25)) begin //mult,multu
        division <= 0;
    end else if (op == 0 && funct == 39) begin //nor
        result <= nor_w;
    end else if ((op == 0 && funct == 37) || op == 13) begin //or,ori
        result <= or_w;
    end else if (op == 40 || op == 41 || op == 43 || op == 42 || op == 46 || op == 34 || op == 38) begin //sb,sh,sw,swl,swr,lwl,lwr
        result <= value_2;
    end else if (op == 0 && (funct == 0 || funct == 4)) begin //sll,sllv
        result <= shift_left_logical;
    end else if ((op == 0 && funct == 42) || op == 10) begin //slt,slti
        if (smaller_signed) begin
            result <= 1;
        end else begin
            result <= 0;
        end
    end else if (op == 11 || (op == 0 && funct == 43)) begin //sltu,sltiu
        if (smaller) begin
            result <= 1;
        end else begin
            result <= 0;
        end
    end else if (op == 0 && (funct == 3 || funct == 7)) begin //sra,srav
        result <= shift_right_arithmetic;
    end else if (op == 0 && (funct == 2 || funct == 6)) begin //srl,srlv
        result <= shift_right_logical;
    end else if (op == 0 && (funct == 34 || funct == 35)) begin //sub,subu
        result <= subtract;
    end else if ((op == 0 && funct == 38) || op == 14) begin //xor,xori
        result <= xor_w;
    end else begin
        result <= value_2;
    end
    
    
    
    if (op == 2 || op == 3) begin 
        address <= ({{6{1'b0}}, target} << 2) | {pc[31:28],{28{1'b0}}}; //Jump instructions
    end else if (op == 0 && (funct == 9 || funct == 8)) begin //jalr and jr
        address <= value_1;
    end else begin
        address <= address_w;
    end 
    branch_o <= jump;
    if (jump == 1) begin 
        result <= pc + 4;
    end 
end

    if(mult_div_in_operation == 0 && last_mult_div_in_operation == 1) begin
        mul_result <= mult_div_out;
    end
    
end

endmodule
