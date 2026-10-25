`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2026 08:34:50 PM
// Design Name: 
// Module Name: Rand_LFSR
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
//16 bit maximal length Fibonacci LFSR
//Polynomial: x^16 + x^14 + x^13 + x^11 + 1
//Period 65535

module Rand_LFSR #(
    parameter logic [15:0] SEED = 16'h1234 //seed can be any non zero value
) (
    input logic clk,
    input logic rst,
    input logic en,
    output logic [15:0] q
    );
    
    logic feedback;
    assign feedback = q[15] ^ q[13] ^ q[12] ^ q[10];    //read 4 bits of the shift register memory
                                                        //out puts 1 bit
    always_ff @(posedge clk) begin
        if (rst) begin
            q <= SEED;  //all zero is lock up state, never seed with 0
        end else if (en) begin
            q <= {q[14:0], feedback}; //cascading calculating for pseudo random number
        end
    end
    
    
    
    
endmodule
