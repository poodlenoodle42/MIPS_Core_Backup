`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2021 11:23:33 AM
// Design Name: 
// Module Name: Core
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


module Core(
    output [31:0] instruction_address,
    input [31:0] instruction_bus,
    output [31:0] data_address,
    inout [31:0] data_bus,
    output data_rw,
    output data_cs,
    output [1:0] data_mode,
    input clk
    );

wire [31:0] register_1;
wire [31:0] register_2;

wire branch;

wire [5:0] cu_op;
wire [4:0] cu_rs;
wire [4:0] cu_rt;
wire [4:0] cu_rd;
wire cu_register_write;
wire cu_branch;
wire [4:0] cu_shamt;
wire [5:0] cu_funct;
wire [15:0] cu_immediate;
wire [25:0] cu_target;
wire [31:0] cu_pc;

wire stall_cu_rd;

wire [31:0] rd_pc;
wire [5:0] rd_op;
wire [4:0] rd_rd;
wire rd_register_write;
wire rd_branch;
wire [4:0] rd_shamt;
wire [5:0] rd_funct;
wire [25:0] rd_target;
wire [31:0] rd_value_1;
wire [31:0] rd_value_2;
wire [31:0] rd_value_3;

wire [5:0] ex_op;
wire [4:0] ex_rd;
wire ex_register_write;
wire ex_branch; 
wire [31:0] ex_result;
wire [31:0] ex_address;
wire stall_ex;
wire ex_mult_div_stall;

wire [5:0] mem_op;
wire [4:0] mem_rd;
wire mem_register_write; 
wire [31:0] mem_result;

wire [4:0] wb_rd;
wire [31:0] wb_result;

wire stall_rf;
wire rf_stall_rs;
wire rf_stall_rt;

wire fu_forwarding_rs;
wire fu_forwarding_rt;
wire [31:0] fu_value_rs;
wire [31:0] fu_value_rt;

IF_ID_CU cu (
    .instruction_bus (instruction_bus),
    .stall (stall_cu_rd),
    .branch (branch),
    .branch_target (ex_address),
    .clk (clk),
    .instruction_address (instruction_address),
    .opcode (cu_op),
    .rs (cu_rs),
    .rt (cu_rt),
    .rd (cu_rd),
    .register_write (cu_register_write),
    .branch_o (cu_branch),
    .shamt (cu_shamt),
    .funct (cu_funct),
    .immediate (cu_immediate),
    .target (cu_target),
    .pc (cu_pc)
);

RD rd (
    .opcode (cu_op),
    .rd (cu_rd),
    .register_write (cu_register_write),
    .branch (cu_branch),
    .shamt (cu_shamt),
    .funct (cu_funct),
    .immediate (cu_immediate),
    .target (cu_target),
    .pc (cu_pc),
    .stall (stall_cu_rd),
    .clk (clk),
    .register_1 (register_1),
    .register_2 (register_2),
    .forwarding_rs (fu_forwarding_rs),
    .forwarding_rt (fu_forwarding_rt),
    .fu_value_rs (fu_value_rs),
    .fu_value_rt (fu_value_rt),
    .opcode_o (rd_op),
    .rd_o (rd_rd),
    .register_write_o (rd_register_write),
    .branch_o (rd_branch),
    .shamt_o (rd_shamt),
    .funct_o (rd_funct),
    .target_o (rd_target),
    .pc_o (rd_pc),
    .value_1 (rd_value_1),
    .value_2 (rd_value_2),
    .value_3 (rd_value_3)
);

EX ex (
    .opcode (rd_op),
    .rd (rd_rd),
    .register_write (rd_register_write),
    .branch (rd_branch),
    .shamt (rd_shamt),
    .funct (rd_funct),
    .target (rd_target),
    .pc (rd_pc),
    .value_1 (rd_value_1),
    .value_2 (rd_value_2),
    .value_3 (rd_value_3),
    .clk (clk),
    .opcode_o (ex_op),
    .rd_o (ex_rd),
    .register_write_o (ex_register_write),
    .result (ex_result),
    .branch_o (branch),
    .address (ex_address),
    .stall (stall_ex),
    .stall_o (ex_mult_div_stall)
);

MEM mem (
    .clk (clk),
    .opcode (ex_op),
    .rd (ex_rd),
    .register_write (ex_register_write),
    .result (ex_result),
    .address (ex_address),
    .data_bus (data_bus),
    .opcode_o (mem_op),
    .rd_o (mem_rd),
    .register_write_o (mem_register_write),
    .result_o (mem_result),
    .data_address (data_address),
    .data_rw (data_rw),
    .data_cs (data_cs),
    .data_mode (data_mode)
);

WB wb (
    .opcode (mem_op),
    .rd (mem_rd),
    .register_write (mem_register_write),
    .result (mem_result),
    .rd_o (wb_rd),
    .result_o (wb_result)
);

RF rf (
    .rs (cu_rs),
    .rt (cu_rt),
    .rd (cu_rd),
    .rd_wb (wb_rd),
    .result (wb_result),
    .register_write (cu_register_write),
    .clk (clk),
    .stall (stall_rf),
    .forwarding_rs (fu_forwarding_rs),
    .forwarding_rt (fu_forwarding_rt),
    .stall_rs (rf_stall_rs),
    .stall_rt (rf_stall_rt),
    .register_1 (register_1),
    .register_2 (register_2)
);

Stall_Unit su (
    .mult_div_stall (ex_mult_div_stall),
    .forwarding_rs (fu_forwarding_rs),
    .forwarding_rt (fu_forwarding_rt),
    .rf_stall_rs (rf_stall_rs),
    .rf_stall_rt (rf_stall_rt),
    .stall_cu_rd (stall_cu_rd),
    .stall_ex (stall_ex),
    .stall_rf (stall_rf)
);

Forwarding_Unit fu (
    .clk (clk),
    .rs_cu (cu_rs),
    .rt_cu (cu_rt),
    .rd_cu (cu_rd),
    .register_write_cu (cu_register_write),
    .op_ex (ex_op),
    .rd_ex (ex_rd),
    .value_ex (ex_result),
    .register_write_ex (ex_register_write),
    .op_mem (mem_op),
    .rd_mem (mem_rd),
    .value_mem (mem_result),
    .register_write_mem (mem_register_write),
    .forwarding_rs (fu_forwarding_rs),
    .forwarding_rt (fu_forwarding_rt),
    .value_rs (fu_value_rs),
    .value_rt (fu_value_rt)
);

endmodule
