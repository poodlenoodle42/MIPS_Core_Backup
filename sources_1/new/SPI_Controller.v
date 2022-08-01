`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2021 07:33:44 PM
// Design Name: 
// Module Name: SPI_Controller
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


module SPI_Controller(
//    input interrupt,
//    input [7:0] value,
    inout [31:0] data_bus,
    input [29:0] data_address,
    input data_rw,
    input data_cs,
    
    
    input clk,
    input spi_clk,
    output spi_clk_o,
    output ss,
    output reg mosi,
    input miso
    );

wire interrupt;
assign interrupt = data_address == 0 && data_cs == 1 && data_rw == 1 ? 1 : 0;
wire [7:0] value;
assign value = data_bus[15:8]; //Value at address 2

assign data_bus = data_address == 0 && data_cs == 1 && data_rw == 0 ? 0 : 32'bz;

parameter BUFFER_SIZE = 64;

//CPU Clock Domain
reg [7:0] buffer [0:BUFFER_SIZE];
reg [7:0] send_buffer1;
reg [7:0] send_buffer2;
reg [$clog2(BUFFER_SIZE) + 1:0] write_ptr;
reg [$clog2(BUFFER_SIZE) + 1:0] read_ptr;
reg empty;
reg full;
reg req1;
reg req2;
reg ack1_pipe;
reg ack1_cpu;
reg ack2_pipe;
reg ack2_cpu;
reg line;
//Flags
reg read;
reg wrote;

//SPI Clock Domain
reg line_spi;
reg ack1;
reg ack2;
reg req1_pipe;
reg req1_spi;
reg req2_pipe;
reg req2_spi;

reg [7:0] value_spi;
reg [2:0] counter;
reg transaction;
reg ss_rising;
reg ss_faling;
integer i;
initial begin
    for(i = 0; i<=BUFFER_SIZE;i = i + 1) begin
        buffer[i] = 0;
    end
    write_ptr = 0;
    read_ptr = 0;
    empty = 1;
    full = 0;
    send_buffer1 = 0;
    send_buffer2 = 0;
    req1 = 0;
    req1_pipe = 0;
    req1_spi = 0;
    req2 = 0;
    req2_pipe = 0;
    req2_spi = 0;
    ack1_pipe = 0;
    ack1_cpu = 0;
    ack1 = 0;
    ack2_pipe = 0;
    ack2_cpu = 0;
    ack2 = 0;
    line = 0;
    read = 0;
    wrote = 0;
    line_spi = 0;
    value_spi = 0;
    counter = 0;
    ss_rising = 1;
    ss_faling = 1;
    mosi = 0;
    transaction = 0;
    
end

wire [$clog2(BUFFER_SIZE) + 1:0] next_write_ptr = write_ptr == BUFFER_SIZE ? 0 : write_ptr + 1;
wire [$clog2(BUFFER_SIZE) + 1:0] next_read_ptr = read_ptr == BUFFER_SIZE ? 0 : read_ptr + 1;
always @ (posedge clk) begin
    if(interrupt == 1 && full == 0) begin
        buffer[write_ptr] <= value;
        write_ptr <= next_write_ptr;
        wrote <= 1;
    end else begin
        wrote <= 0;
    end
    if(empty == 0) begin
        if(line == 0 && req1 == 0 && ack1_cpu == 0) begin
            send_buffer1 <= buffer[read_ptr];
            read_ptr <= next_read_ptr;
            req1 <= 1;
            line <= 1;
            read <= 1;
        end else if (line == 1 && req2 == 0 && ack2_cpu == 0) begin
            send_buffer2 <= buffer[read_ptr];
            read_ptr <= next_read_ptr;
            req2 <= 1;
            line = 0;
            read <= 1;
        end else begin
            read <= 0;
        end
    end else begin
        read <= 0;
    end
    if(ack1_cpu == 1) begin
        req1 <= 0;
    end else if (ack2_cpu == 1) begin
        req2 <= 0;
    end
    {ack1_cpu,ack1_pipe} <= {ack1_pipe,ack1};
    {ack2_cpu,ack2_pipe} <= {ack2_pipe,ack2};
    
end
wire read_eq_write;
assign read_eq_write = read_ptr == write_ptr;
always @ (negedge clk) begin
    if(read == 0 && wrote == 1 && read_eq_write == 1) begin
        full <= 1;
    end else if (read == 1 && wrote == 0 && read_eq_write == 1) begin
        empty <= 1;
    end else if (read_eq_write == 0) begin 
        empty <= 0;
        full <= 0;
    end
end

assign spi_clk_o = ss == 0 ? spi_clk : 0;

always @ (negedge spi_clk) begin
    {req1_spi,req1_pipe} <= {req1_pipe,req1};
    {req2_spi,req2_pipe} <= {req2_pipe,req2};
    if(line_spi == 0 && req1_spi == 1 && transaction == 0) begin
        transaction <= 1;
        value_spi <= send_buffer1;
        ack1 <= 1;
        line_spi <= 1;
        counter <= 0;
    end else if (line_spi == 1 && req1_spi == 1 && transaction == 0) begin
        transaction <= 1;
        value_spi <= send_buffer2;
        ack2 <= 1;
        line_spi <= 0;
        counter <= 0;
    end
    
    else if(transaction == 1) begin
        mosi <= value_spi[7];
        counter <= counter + 1;
        if (counter == 7) begin
            if(line_spi == 0) begin
                ack2 <= 0;
                if(req1_spi == 1) begin
                    value_spi <= send_buffer1;
                    ack1 <= 1;
                    line_spi <= 1;
                end else begin
                    transaction <= 0;
                end
            end else begin
                ack1 <= 0;
                if(req2_spi == 1) begin
                    value_spi <= send_buffer2;
                    ack2 <= 1;
                    line_spi <= 0;
                end else begin
                    transaction <= 0;
                end
            end
        end else begin
            value_spi <= value_spi << 1;
        end
    end
    ss_faling <= !transaction;
    
end
assign ss = !(!ss_rising || !ss_faling);
always @ (posedge spi_clk) begin
    ss_rising <= ss_faling;
end

endmodule
