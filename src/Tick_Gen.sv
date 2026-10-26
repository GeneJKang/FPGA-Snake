`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2026 06:35:47 AM
// Design Name: 
// Module Name: Tick_Gen
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


module Tick_Gen #(
    parameter int TICK_FRAMES = 18, //starting frames per move
    parameter int MIN_TICK_FRAMES = 6   //fastest allowed
) (
    input logic clk,
    input logic rst,
    input logic frame_end,  //1 cycle pulse once per frame
    input logic ate,
    output logic tick
    );
    
    //minimum cant be slower than the start
    localparam int MIN_F = MIN_TICK_FRAMES;
    localparam int START_Q = 4 * TICK_FRAMES;   //periods in quarter-frames
    localparam int MIN_Q = 4 * MIN_F;
    localparam int MAX_SPEEDUP = START_Q - MIN_Q; //foods until top speed
    
    logic [9:0] eaten; //saturating food counter
    logic [11:0] period_q; //current period in quarter-frames
    logic [11:0] acc;   //phase accumulator in quarter frames
    
    always_comb begin
        if (eaten >= MAX_SPEEDUP) begin
            period_q = MIN_Q;
        end else begin
            period_q = START_Q - eaten; //-0.25 frame per food
        end
    end
    
    always_ff @(posedge clk) begin
        if (rst) begin
            eaten <= '0;
            acc <= '0;
            tick <= 1'b0;
        end else begin
            tick <= 1'b0;
            if (ate && eaten != 10'h3FF) begin
                eaten <= eaten + 10'd1;
            end
            if (frame_end) begin
                if (acc + 12'd4 >= period_q) begin
                    acc <= acc + 12'd4 - period_q;
                    tick <= 1'b1;
                end else begin
                    acc <= acc + 12'd4;
                end
            end
        end
    end
    
endmodule

