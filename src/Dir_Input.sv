`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2026 11:02:21 PM
// Design Name: 
// Module Name: Dir_Input
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


module Dir_Input(
    input logic clk,
    input logic rst,
    input logic btnU,
    input logic btnD,
    input logic btnL,
    input logic btnR,
    input logic tick,
    input logic [1:0] cur_dir,  //snake's current direction
    output logic [1:0] dir_req, //Snake_Logic dir_in
    output logic started //gate the snake's tick
    );
    
    localparam logic [1:0] RIGHT = 2'd0, DOWN = 2'd1, LEFT = 2'd2, UP = 2'd3;
    
    //Synchronizer with rising edge detection
    // bit order {U, D, L, R}
    logic [3:0] sync1, sync2, sync3;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            sync1 <= '0;
            sync2 <= '0;
            sync3 <= '0;
        end else begin
            sync1 <= {btnU, btnD, btnL, btnR};
            sync2 <= sync1;
            sync3 <= sync2;           // last cycle's value for edge detect
        end
    end
    
    logic [3:0] press;
    assign press = sync2 & ~sync3;  //1 for one clock when a button goes down
    
    logic press_valid;
    logic [1:0] press_dir;
    
    always_comb begin
        press_valid = 1'b1;
        press_dir = RIGHT;
        //if two buttons go down on the exact same clock then first match wins
        if (press[3]) begin
            press_dir = UP;
        end else if (press[2]) begin
            press_dir = DOWN;
        end else if (press[1]) begin
            press_dir = LEFT;
        end else if (press[0]) begin
            press_dir = RIGHT;
        end else begin
            press_valid = 1'b0;
        end
    end
    
    //Input buffer (2 inputs buffer)
    //q0 (curr move) q1 (next move)
    logic [1:0] q0, q1;
    logic [1:0] count;  //0, 1 , or 2 entries
    
    //direction a new press is compared against
    logic [1:0] last;
    always_comb begin
        case (count)
            2'd0: last = cur_dir;
            2'd1: last = q0;
            default: last = q1;
        endcase
    end
    
    logic accept, pop;
    assign accept = press_valid && (count != 2'd2) //full (drop input)
                                && (press_dir != last) //repeat (drop input)
                                && ((press_dir ^last) != 2'b10); //reversal (drop input)
    assign pop = tick && (count != 2'd0);
    
    assign dir_req = (count != 2'd0) ? q0 : cur_dir; //empty queue (keep going)
    
    always_ff @(posedge clk) begin
        if (rst) begin
            q0 <= RIGHT;
            q1 <= RIGHT;
            count <= 2'd0;
            started <= 1'b0;
        end else begin
            if (press_valid) begin
                started <= 1'b1;
            end
            if (pop && accept) begin
                //only possible if count == 1. q1 leaves and new press takes its place
                q0 <= press_dir;
            end else if (pop) begin
                q0 <= q1;
                count <= count - 2'd1;
            end else if (accept) begin
                if (count == 2'd0) begin 
                    q0 <= press_dir;
                end else begin
                    q1 <= press_dir;
                end
                count <= count + 2'd1;
            end
        end
    end
endmodule
