
module RF(
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] rd,
    input [4:0] rd_wb,
    input [31:0] result,
    input register_write,
    input clk,
    input stall,
    input forwarding_rs,
    input forwarding_rt,
    output reg stall_rs,
    output reg stall_rt,
    output reg [31:0] register_1,
    output reg [31:0] register_2
    );

reg [31:0] register_file [0:31];

reg [2:0] register_locks [0:31];

wire rs_locked;
assign rs_locked = rs == 0 ? 0 : (register_locks[rs] > 0);

wire rt_locked;
assign rt_locked = rt == 0 ? 0 : (register_locks[rt] > 0);

wire stall_w;
assign stall_w = (rt_locked == 1 && forwarding_rt == 0) || (rs_locked == 1 && forwarding_rs == 0);



integer i;
initial begin
    stall_rs = 0;
    stall_rt = 0;
    register_1 = 0;
    register_2 = 0;
    for(i = 0; i<32; i = i+1) begin
        register_file[i] = {32{1'b0}};
        register_locks[i] = {3{1'b0}};
    end
    register_file[29] = 'hfffffff0;
    register_file[30] = 'hfffffff0;
    register_file[31] = 'h80000000;
end

always @(negedge clk) begin
    if(stall == 0) begin
        if(stall_w == 0) begin
            if(rd != rd_wb ) begin
                if(rd != 0 && register_write == 1) begin
                    register_locks[rd] <= register_locks[rd] + 1;
                end
                if(rd_wb != 0) begin
                    register_locks[rd_wb] <= register_locks[rd_wb] - 1;
                end
            end else if (rd == rd_wb && register_write == 0) begin
                register_locks[rd_wb] <= register_locks[rd_wb] - 1;
            end
        end else begin
            register_locks[rd_wb] <= register_locks[rd_wb] - 1;
        end
        register_file[rd_wb] <= result;
        register_1 <= stall_w == 1 || rs == 0 ? 0 : register_file[rs];
        register_2 <= stall_w == 1 || rt == 0 ? 0 : register_file[rt];
        stall_rs <= rs_locked;
        stall_rt <= rt_locked;
    end

end
    
    
endmodule








/*
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2021 03:22:19 PM
// Design Name: 
// Module Name: RF
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


module RF(
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] rd,
    input [4:0] rd_wb,
    input [31:0] result,
    input register_write,
    input clk,
    output stall,
    output [31:0] register_1,
    output [31:0] register_2
    );   

wire [0:31] locks;
reg [0:31] locks_reg;
reg stall_reg;

reg [31:0] register_1_reg;
reg [31:0] register_2_reg;

assign locks = {{1'b0},locks_reg[1:31]};

reg [31:0] register_file [0:31];

wire rs_locked;
wire rt_locked;
wire stall_w;

assign rs_locked = locks[rs];
assign rt_locked = locks[rt];
assign stall_w = rs_locked | rt_locked;

assign stall = stall_w == 0 ? 0 : stall_reg;

wire [31:0] rs_w;
wire [31:0] rt_w;
assign rs_w = (stall_w == 1 && rd_wb == rs) ? result : register_file[rs];
assign rt_w = (stall_w == 1 && rd_wb == rt) ? result : register_file[rt];

assign register_1 = stall == 0 ? register_1_reg : 0;
assign register_2 = stall == 0 ? register_2_reg : 0;


integer i;
initial begin
    locks_reg = 0;
    stall_reg = 0;
    for(i = 0; i<32; i = i+1) begin
        register_file[i] = {32{1'b0}};
    end
    //Init stack and frame pointer
    register_file[29] = 'hffffffff;
    register_file[30] = 'hffffffff;
    register_1_reg = 0;
    register_2_reg = 0;
    wait_for_rt_or_rs = 0;
end 
reg wait_for_rt_or_rs;
reg [4:0] waiting_for;
always @ (negedge clk) begin
    if (rd_wb != 0) begin
       //locks_reg[rd_wb] <= 0;
       register_file[rd_wb] <= result;
    end
    if ((rd_wb == rd && register_write == 1) || wait_for_rt_or_rs == 1 ) begin
        if((rs != rd && rs_locked == 1) || (rt != rd && rt_locked == 1)) begin
            stall_reg <= stall_w;
            wait_for_rt_or_rs <= 1;
            waiting_for <= rs != rd ? rs : rt;
        end else begin
            stall_reg <= 0;
        end
    end else begin
        locks_reg[rd_wb] <= 0;
        stall_reg <= stall_w;
    end
    if(wait_for_rt_or_rs == 1 && rd_wb == waiting_for) begin
        locks_reg[rd_wb] <= 0;
        stall_reg <= 0;
        wait_for_rt_or_rs <= 0;
    end
    register_1_reg <= rs == 0 ? 0 : rs_w;
    register_2_reg <= rt == 0 ? 0 : rt_w;
     
    if (rd != 0 && register_write == 1 && stall == 0) begin 
       locks_reg[rd] <= 1;
    end
end
        
        
        
    
    
endmodule
*/