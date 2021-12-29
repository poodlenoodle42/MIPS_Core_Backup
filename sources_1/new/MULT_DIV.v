`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2021 10:46:21 AM
// Design Name: 
// Module Name: MULT_DIV
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


module MULT_DIV(
    input clk,
    input enable,
//    input [1:0] mode, //0: multu, 1: mult 2: divu 3: div
    input [31:0] value_1,
    input [31:0] value_2,
    input [1:0] operation,  //0: multu, 1: mult 2: divu 3: div
    output reg [63:0] out,
    output reg in_operation 
    );


reg [1:0] operation_reg;
reg value_1_neg;
reg value_2_neg;
reg [31:0] operand1;
reg [31:0] operand2;
reg running_division;
reg [5:0] counter;
reg [31:0] A;
wire [31:0] A_shifted;
assign A_shifted = (A << 1) | operand1[31];
wire [31:0] A_shifted_m_divisor;
assign A_shifted_m_divisor = A_shifted - operand2;
initial begin
    operation_reg = 0;
    value_1_neg = 0;
    value_2_neg = 0;
    operand1 = 0;
    operand2 = 0;
    running_division = 0;
    counter = 0;
    A = 0;
    out = 0;
    in_operation = 0;
end

wire [31:0] positive1;
assign positive1 = value_1[31] == 0 ? value_1 : (~value_1) + 1;

wire [31:0] positive2;
assign positive2 = value_2[31] == 0 ? value_2 : (~value_2) + 1;

wire [63:0] multiplication;
assign multiplication = operand1 * operand2;

always @ (posedge clk) begin
    if(enable == 1) begin
        operation_reg <= operation;
        in_operation <= 1;
        if(operation == 0 || operation == 2) begin
            operand1 <= value_1;
            operand2 <= value_2;
        end else if (operation == 1 || operation == 3) begin
            operand1 <= positive1;
            operand2 <= positive2;
            value_1_neg <= value_1[31];
            value_2_neg <= value_2[31];
        end
    end else if (in_operation == 1) begin
        if(operation_reg == 0) begin
            out <= multiplication;
            in_operation <= 0;
        end else if (operation_reg == 1) begin
            if(value_1_neg ^ value_2_neg) begin
                out <= ~(multiplication) + 1;
            end else begin
                out <= multiplication;
            end
            in_operation <= 0;
        end else if (running_division == 0 && (operation_reg == 2 || operation_reg == 3)) begin
            A <= 0;
            counter <= 32;
            running_division <= 1;
        end else if (running_division == 1) begin
            if(A_shifted_m_divisor[31] == 1) begin
                operand1 <= operand1 << 1;
                A <= A_shifted;
            end else begin
                operand1 <= (operand1 << 1) | 1;
                A <= A_shifted_m_divisor;
            end
            counter <= counter - 1;
            if(counter == 0) begin
                running_division <= 0;
                in_operation <= 0;
                if((value_1_neg == 0 && value_2_neg == 0) || operation_reg == 2) begin
                    out[63:32] <= A;
                    out[31:0] <= operand1;
                end else if (value_1_neg == 1 && value_2_neg == 0) begin
                    out[63:32] <= (~A) + 1;
                    out[31:0] <= (~operand1) + 1;
                end else if (value_1_neg == 1 && value_2_neg == 1) begin
                    out[31:0] <= operand1;
                    out[63:32] <= (~A) + 1;
                end else if (value_1_neg == 0 && value_2_neg == 1) begin
                    out[31:0] <= (~operand1) + 1;
                    out[63:32] <= A;
                end
            end
        end
    end
end


endmodule
