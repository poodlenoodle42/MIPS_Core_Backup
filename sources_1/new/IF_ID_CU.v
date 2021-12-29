`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2021 11:23:33 AM
// Design Name: 
// Module Name: IF_ID_CU
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


module IF_ID_CU(
    output [31:0] instruction_address,
    input [31:0] instruction_bus,
    input stall,
    input branch,
    input [31:0] branch_target,
    input clk,
    
    output [5:0] opcode,
    output [4:0] rs,
    output [4:0] rt,
    output [4:0] rd,
    output [4:0] shamt,
    output [5:0] funct,
    output [15:0] immediate,
    output [25:0] target,
    output [31:0] pc,
    output register_write,
    output branch_o
    );

reg [31:0] pc_reg;
reg [31:0] ir_reg;
initial begin 
    ir_reg = 0;
    pc_reg = ('h80000000 - 4);
    last_cycle_stall = 0;
end

wire [31:0] ir;
wire [5:0] op;
assign opcode = op;

assign ir = (branch == 1'b0) ? ir_reg : 0;
assign instruction_address = branch === 1'b1 ? branch_target : pc_reg;

wire [4:0] rt_w;

assign op = ir[31:26];
assign rs =  ir[25:21];
assign rt_w =  ir[20:16];
assign rt = write_rt == 1 ? 0 : rt_w;
assign rd = ((ir[31:26] == 1 && (rt_w == 16 || rt_w == 17)) || ir[31:26] == 3) ? 31 : ((ir[31:26] == 0) ? ir[15:11] : rt_w); //No use of op because op is 0 in case of stall
assign shamt = ir[10:6];
assign funct = ir[5:0];
assign immediate = ir[15:0];
assign target = ir[25:0];

//Acceses ir_reg directly because op gets zero on stall 
assign register_write = (ir_reg[31:26] == 0 || (ir_reg[31:26] == 1 && (rt_w == 16 || rt_w == 17)) || ir_reg[31:26] == 3 
                        || ir_reg[31:26] == 8 || ir_reg[31:26] == 9 || ir_reg[31:26] == 10 || ir_reg[31:26] == 11 || ir_reg[31:26] == 12 
                        || ir_reg[31:26] == 13 || ir_reg[31:26] == 14 || ir_reg[31:26] == 15 || ir_reg[31:26] == 32 || ir_reg[31:26] == 33 
                        || ir_reg[31:26] == 34 || ir_reg[31:26] == 35 || ir_reg[31:26] == 36 || ir_reg[31:26] == 37 || ir_reg[31:26] == 38) ?
                        1 : 0;
assign branch_o = (op == 1 || op == 2 || op == 3 || op == 4 || op == 5 || op == 6 || op == 7) ? 1 : 0;

wire write_rt;   
//Acceses ir_reg directly because op gets zero on stall                        
assign write_rt = (ir_reg[31:26] == 8 || ir_reg[31:26] == 9 || ir_reg[31:26] == 10 || ir_reg[31:26] == 11 || ir_reg[31:26] == 12 || ir_reg[31:26] == 13 ||
                   ir_reg[31:26] == 14 || ir_reg[31:26] == 15 || ir_reg[31:26] == 32 || ir_reg[31:26] == 33 || ir_reg[31:26] == 34 || ir_reg[31:26] == 35 || 
                   ir_reg[31:26] == 36 || ir_reg[31:26] == 37 || ir_reg[31:26] == 38) ? 1 : 0;
reg last_cycle_stall;           
assign pc = pc_reg;
always @ (posedge clk) begin
    if (last_cycle_stall == 0 || branch == 0) begin
        if (stall == 0) begin
            ir_reg <= instruction_bus;
        end
        if(branch == 1) begin
            pc_reg <= branch_target + 4;
            
        end else if (stall == 1) begin end
        else begin
            pc_reg <= pc_reg + 4;
        end
    end else begin
        pc_reg <= branch_target;
    end
    last_cycle_stall <= stall;
end
endmodule
