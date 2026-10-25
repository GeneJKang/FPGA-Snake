`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2026 09:49:54 PM
// Design Name: 
// Module Name: Snake_Logic
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

//Snake state: occupancy grid, cell trail direction, cell rainbow hue pattern
//Move one cell per tick and tail follows the trail of arrows left by the head

//Directions: 0 = RIGHT, 1 = DOWN, 2 = LEFT, 3 = UP
//Opposite directions differ by 2 so reversal trigger is a ^ b




module Snake_Logic #(
 parameter int GRID_W = 40,
 parameter int GRID_H = 22
 ) (
    input logic clk,
    input logic rst,
    input logic tick,   //1 cycle pulse
    input logic [1:0] dir_in,   //direction
    input logic [5:0] food_x,
    input logic [4:0] food_y,
    
    //renderer (cell under current pixel)
    input logic [5:0] rd_x,
    input logic [4:0] rd_y,
    output logic rd_occ,
    output logic [2:0] rd_hue,
    
    //food placement (check if cell is valid)
    input logic [5:0] check_x,
    input logic [4:0] check_y,
    output logic check_occ,
    output logic ate,    //snake ate
    output logic game_over,  //snake died
    output logic [1:0] cur_dir,
    
    //Game over ripple
    output logic [5:0] head_x_o, //head position
    output logic [4:0] head_y_o
    );
    
    localparam logic [1:0] RIGHT = 2'd0, DOWN = 2'd1, LEFT = 2'd2, UP = 2'd3;
    
    //Board state
    logic occ [0:GRID_H-1][0:GRID_W-1]; //snake is in this cell
    logic [1:0] trail [0:GRID_H-1][0:GRID_W-1]; //direction taken when leaving the cell
    
    logic [2:0]hue [0:GRID_H-1][0:GRID_W-1]; //rainbow color index
    
    logic [5:0] head_x, tail_x;
    logic [4:0] head_y, tail_y;
    logic [1:0] dir;    //direction of the last move
    logic [2:0] hue_count;  //next hue to paint at the head
    
    //Read ports
    logic rd_valid, check_valid;
    assign rd_valid = (rd_x < GRID_W) && (rd_y < GRID_H);
    assign check_valid = (check_x < GRID_W) && (check_y < GRID_H);
    
    assign rd_occ = rd_valid ? occ[rd_y][rd_x] : 1'b0;
    assign rd_hue = rd_valid ? hue[rd_y][rd_x] : 3'd0;
    assign check_occ = check_valid ? occ[check_y][check_x] : 1'b1;   //off grid counts as taken
    
    //Next head position (combinational)
    logic [1:0] new_dir;
    logic [5:0] nx;
    logic [4:0] ny;
    
    //Ignore a press that is considered a reversal
    assign new_dir = ((dir_in ^ dir) == 2'b10) ? dir : dir_in;
    
    always_comb begin
        nx = head_x;
        ny = head_y;
        case (new_dir)
            RIGHT: nx = head_x + 6'd1;
            DOWN: ny = head_y + 5'd1;
            LEFT: nx = head_x - 6'd1;   //0 - 1 wraps to 63 and caught by bound check
            UP: ny = head_y - 5'd1;     //swraps to 31 ^^^
        endcase
    end
    
    //Move pipeline (3 clock cycles)
    //compute new head -> 880:1 board lookup -> collision check -> write enables
    //for every cell all in one clock period. moves only happens every few frames, 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    logic out_of_bounds, eat_now, hit_self;
    assign out_of_bounds = (nx >= GRID_W) || (ny >= GRID_H);
    assign eat_now = (nx == food_x) && (ny == food_y);
    
    //Moving into the cell the tail is leaving this same tick is legal
    //Unless we are growing in which the tail stays put
    assign hit_self = !out_of_bounds && occ[ny][nx] && !((nx == tail_x) && (ny == tail_y) && !eat_now);
    
    logic [1:0] tail_dir;
    assign tail_dir = trail[tail_y][tail_x];
    
    //State Update
    always_ff @(posedge clk) begin
        ate <= 1'b0;
        
        if (rst) begin
            for (int yy = 0; yy < GRID_H; yy++) begin
                for (int xx = 0; xx < GRID_W; xx++) begin
                    occ[yy][xx] <= 1'b0;
                    trail[yy][xx] <= RIGHT; //Initializing direction
                    hue[yy][xx] <= 3'd0;
                end
            end
            
            //snake starts with 3 cells in the middle, moving depending on reset init
            occ[11][18] <= 1'b1;    hue[11][18] <= 3'd0; //tail
            occ[11][19] <= 1'b1;    hue[11][19] <= 3'd1;
            occ[11][20] <= 1'b1;    hue[11][20] <= 3'd2; //head
            
            tail_x <= 6'd18;    tail_y <= 5'd11;
            head_x <= 6'd20;    head_y <= 5'd11;
            dir <= RIGHT;
            hue_count <= 3'd3;
            game_over <= 1'b0;
    
        end else if (tick && !game_over) begin
            if (out_of_bounds || hit_self) begin
                game_over <= 1'b1;  //freeze; btnC restarts
            end else begin
                //head: leave a trail arrow in the old head cell
                trail[head_y][head_x] <= new_dir;
                
                //tail: remove trail arrow and follow its arrow (skip when growing)
                if (!eat_now) begin
                    occ[tail_y][tail_x] <= 1'b0;
                    case (tail_dir)
                        RIGHT: tail_x <= tail_x + 6'd1;
                        DOWN: tail_y <= tail_y + 5'd1;
                        LEFT: tail_x <= tail_x - 5'd1;
                        UP: tail_y <= tail_y - 5'd1;
                    endcase
                end
                
                //updating head
                occ[ny][nx] <= 1'b1;
                hue[ny][nx] <= hue_count;
                head_x <= nx;
                head_y <= ny;
                dir <= new_dir;
                hue_count <= hue_count + 3'd1;
                ate <= eat_now;
            end
        end
    end
    assign cur_dir = dir;
    assign head_x_o = head_x;
    assign head_y_o = head_y;
endmodule
