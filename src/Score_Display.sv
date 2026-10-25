`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2026 06:45:09 AM
// Design Name: 
// Module Name: Score_Display
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


module Score_Display #(
    parameter int X0 = 16, //left edge of the first digit
    parameter int Y0 = 707 //top edge of the digits
) (
    input logic clk,
    input logic rst,
    input logic inc,        // 1 cycle increment + 1
    input logic [10:0] x,
    input logic [10:0] y,
    output logic pixel_on    // 1 if this pixel is part of a digit  
    );
    
    //BCD counter from 000 to 999 (saturates after 999)
    logic [3:0] d2, d1, d0;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            d2 <= 4'd0;
            d1 <= 4'd0;
            d0 <= 4'd0;
        end else if (inc && !(d2 == 4'd9 && d1 == 4'd9 && d0 == 4'd9)) begin
            if (d0 != 4'd9) begin
                d0 <= d0 + 4'd1;
            end else begin
                d0 <= 4'd0; // carry into tens
                if (d1 != 4'd9) begin
                    d1 <= d1 + 4'd1;
                end else begin
                    d1 <= 4'd0; // carry into hundreds
                    d2 <= d2 + 4'd1;
                end
            end
        end
    end
    
    //3x5 font
    //5 rows of 3 bits with top row first
    //MSB is top left pixel
    
    function automatic logic [14:0] glyph(input logic [3:0] d);
        case (d)
            4'd0: glyph = 15'b111_101_101_101_111;
            4'd1: glyph = 15'b010_110_010_010_111;
            4'd2: glyph = 15'b111_001_111_100_111;
            4'd3: glyph = 15'b111_001_111_001_111;
            4'd4: glyph = 15'b101_101_111_001_001;
            4'd5: glyph = 15'b111_100_111_001_111;
            4'd6: glyph = 15'b111_100_111_101_111;
            4'd7: glyph = 15'b111_001_001_001_001;
            4'd8: glyph = 15'b111_101_111_101_111;
            4'd9: glyph = 15'b111_101_111_001_111;
            default: glyph = 15'b0;
        endcase
    endfunction
    
    //Renderer
    //which digit / font pixel is under (x, y)
    logic in_box;
    logic [10:0] rx, ry;    //position relative to the score box
    logic [1:0] digit_idx;  //0 to 2 (left to right)
    logic [1:0] col;    //0 to 2 font column and 3 = gap between digits
    logic [2:0] row; //0 to 4 font row
    logic [3:0] digit;
    logic [14:0] g;
    
    assign in_box = (x >= X0) && (x < X0 + 24) && (y >= Y0) && (y < Y0 + 10);
    assign rx = x - X0;
    assign ry = y - Y0;
    assign digit_idx = rx[4:3]; // 8 px per digit cell
    assign col = rx[2:1]; // 2x scale each font pixel so 1 font pixel is 2 screen pixels
    assign row = ry[3:1];
 
    always_comb begin
        case (digit_idx)
            2'd0: digit = d2;
            2'd1: digit = d1;
            default: digit = d0;
        endcase
    end
 
    assign g = glyph(digit);
 
    always_comb begin
        pixel_on = 1'b0;
        if (in_box && col != 2'd3) begin
            pixel_on = g[14 - (row * 3 + col)];
        end
    end
    
endmodule
