`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2026 08:47:19 PM
// Design Name: 
// Module Name: Food_Gen
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


module Food_Gen#(
    parameter int GRID_W = 40,
    parameter int GRID_H = 22
) (
    input logic clk,
    input logic rst,
    input logic place,  //1 cycle pulse and pick new position
    input logic [15:0] rand_in, //LFSR value
    input logic blocked,    //1 if cand_x/cand_y is occupied by snake or out of bounds
    output logic [5:0] cand_x,
    output logic [4:0] cand_y,
    output logic [5:0] food_x,
    output logic [4:0] food_y,
    output logic ready  //1 when food_x/food_y hold a valid position
    );
    
    typedef enum logic {PLACING, IDLE} state_t;
    state_t state;
    
    //split LFSR to x and y
    assign cand_x = rand_in[5:0];    //0 to 63
    assign cand_y = rand_in[12:8];  //0 to 31
    
    logic cand_ok;
    assign cand_ok = (cand_x < GRID_W) && (cand_y < GRID_H) && !blocked;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= PLACING;   //place food immediately after reset
            food_x <= '0;
            food_y <= '0;
        end else begin
            case (state)
                PLACING: begin
                    if (cand_ok) begin
                        food_x <= cand_x;
                        food_y <= cand_y;
                        state <= IDLE;
                    end
                    //otherwise try again next clock (LFSR has moved on)
                end
                
                IDLE: begin
                    if (place) begin
                        state <= PLACING;
                    end
                end
            endcase
        end
    end

    
    assign ready = (state == IDLE);
    
    
endmodule
