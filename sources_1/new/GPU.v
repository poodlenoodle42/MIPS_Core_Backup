`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2022 02:19:09 PM
// Design Name: 
// Module Name: GPU
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


module GPU(
    input [29:0] data_address,
    inout [31:0] data_bus,
    input data_cs,
    input data_rw,
    input cpu_clk,
    input gpu_clk,
    output [23:0] pixel,
    output vsync,
    output hsync,
    output vde    
);

parameter BACKROUND_TILES = 256;
parameter FOREGROUND_TILES = 64;
parameter FOREGROUND_SPRITES = 32;

localparam STAGES = 2;

reg [15:0] pixel_count [0:4];

reg [15:0] lines_count [0:4];

assign vsync = lines_count[STAGES] >= 600;
assign hsync = pixel_count[STAGES] >= 800;
assign vde = !vsync && !hsync;


wire [31:0] backroud_tile_bus;
wire [29:0] backround_tile_address;
wire [15:0] backround_tile_number;
wire [7:0] backround_tile_offset_x;
wire [7:0] backround_tile_offset_y;


wire [15:0] foreground_tile_number;
wire [7:0] foreground_tile_offset_x;
wire [7:0] foreground_tile_offset_y;

wire [23:0] bg_pixel_generator_bus;
wire [29:0] bg_pixel_generator_address;
wire [23:0] bg_pixel_generator_pixel;

wire [23:0] fg_pixel_generator_bus;
wire [29:0] fg_pixel_generator_address;
wire [23:0] fg_pixel_generator_pixel;


// 
assign pixel = vde == 1 ? (fg_pixel_generator_pixel == 0 ? bg_pixel_generator_pixel : fg_pixel_generator_pixel) : 0;

initial begin
    pixel_count[0] = 0;
    lines_count[0] = 0;
end

GPU_RAM #(.SIZE(BACKROUND_TILES*100), .ADDRESS('h70100000), .WORD_LENGTH(24)) backround_tile_data (
    .data_address (data_address),
    .data_bus (data_bus),
    .data_cs (data_cs),
    .data_rw (data_rw),
    
    .gpu_address (bg_pixel_generator_address),
    .gpu_bus (bg_pixel_generator_bus),
    
    .cpu_clk (cpu_clk),
    .gpu_clk (gpu_clk)
    
);

GPU_RAM #(.SIZE(2400), .ADDRESS('h70010000), .WORD_LENGTH(32)) backround_tile_numbers ( //60*80=4800 Tiles and halfwords => 2400 Words
    .data_address (data_address),
    .data_bus (data_bus),
    .data_cs (data_cs),
    .data_rw (data_rw),
    
    .gpu_address (backround_tile_address),
    .gpu_bus (backroud_tile_bus),
    
    .cpu_clk (cpu_clk),
    .gpu_clk (gpu_clk)
);

GPU_RAM #(.SIZE(FOREGROUND_TILES*16*16), .ADDRESS('h70200000), .WORD_LENGTH(24)) foreground_tile_data (
    .data_address (data_address),
    .data_bus (data_bus),
    .data_cs (data_cs),
    .data_rw (data_rw),
    
    .gpu_address (fg_pixel_generator_address),
    .gpu_bus (fg_pixel_generator_bus),
    
    .cpu_clk (cpu_clk),
    .gpu_clk (gpu_clk)
    
);

Backround_Layer backround(
    .data (backroud_tile_bus),
    .address (backround_tile_address),
    .pixel (pixel_count[0]),
    .line (lines_count[0]),
    .clk (gpu_clk),
    .tile_number (backround_tile_number),
    .offset_x (backround_tile_offset_x),
    .offset_y (backround_tile_offset_y)
);

Pixel_Generator backround_pg (
    .clk (gpu_clk),
    .tile_number (backround_tile_number),
    .tile_offset_x (backround_tile_offset_x),
    .tile_offset_y (backround_tile_offset_y),
    .pixel_data (bg_pixel_generator_bus),
    .addr (bg_pixel_generator_address),
    .pixel_value (bg_pixel_generator_pixel)
);

Foreground_Layer #(.SPRITES(FOREGROUND_SPRITES), .ADDRESS('h70300000)) foreground (
    .gpu_clk (gpu_clk),
    .cpu_clk (cpu_clk),
    
    .data_address (data_address),
    .data_bus (data_bus),
    .data_cs (data_cs),
    .data_rw (data_rw),
    
    .pixel (pixel_count[0]),
    .line (lines_count[0]),
    
    .tile_number (foreground_tile_number),
    .offset_x (foreground_tile_offset_x),
    .offset_y (foreground_tile_offset_y)
);

Pixel_Generator #(.TILE_SIZE(16)) foreground_pg (
    .clk (gpu_clk),
    .tile_number (foreground_tile_number),
    .tile_offset_x (foreground_tile_offset_x),
    .tile_offset_y (foreground_tile_offset_y),
    .pixel_data (fg_pixel_generator_bus),
    .addr (fg_pixel_generator_address),
    .pixel_value (fg_pixel_generator_pixel)
);


GPU_Status status (
    .cpu_clk (cpu_clk),
    
    .data_address (data_address),
    .data_bus (data_bus),
    .data_cs (data_cs),
    .data_rw (data_rw),
    
    .pixel (pixel_count[0]),
    .line (lines_count[0])
    
);



integer i;

always @(posedge gpu_clk) begin
    if(pixel_count[0] == 1056) begin
        pixel_count[0] <= 0;
        lines_count[0] <= lines_count[0] + 1;
    end else begin
        pixel_count[0] <= pixel_count[0] + 1;
    end
    
    if(lines_count[0] == 628) begin
        lines_count[0] <= 0;
    end
    
    for(i = 0; i<STAGES; i=i+1) begin
        pixel_count[i+1] <= pixel_count[i];
        lines_count[i+1] <= lines_count[i];
    end
    

end


endmodule
