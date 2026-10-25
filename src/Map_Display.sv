`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2026 06:54:09 PM
// Design Name: 
// Module Name: Map_Display
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


module Map_Display(
    input logic clk,
    input logic btnC,   //reset (only after game over)
    input logic btnU,   //input buttons
    input logic btnL,
    input logic btnD,
    input logic btnR,
    output logic [3:0] vgaRed,
    output logic [3:0] vgaGreen,
    output logic [3:0] vgaBlue,
    output logic Hsync,
    output logic Vsync
    );
    
    //Pixel clock converter (100 MHz to 74.25 MHz)
    //This uses clocking wizard ip
    logic clk_pix, locked;
    
    clk_wiz_0 clk_gen(
        .clk_in1 (clk),
        .reset (1'b0),  //active HIGH reset on the wizard
        .clk_out1(clk_pix),
        .locked (locked)
    );
    
    //Reset Sync while MMCM is unlocked
    logic [1:0] rst_sync;
    logic rst;
    
    always_ff @(posedge clk_pix or negedge locked) begin
        if (!locked) begin
            rst_sync <= 2'b11;
        end else begin
            rst_sync <= {rst_sync[0], 1'b0};
        end
    end
    
    assign rst = rst_sync[1];
    
    game_core core (
        .clk (clk_pix),
        .rst (rst),
        .btnC(btnC),
        .btnU(btnU),
        .btnR(btnR),
        .btnD(btnD),
        .btnL(btnL),
        .vgaRed(vgaRed),
        .vgaGreen(vgaGreen),
        .vgaBlue(vgaBlue),
        .Hsync(Hsync),
        .Vsync(Vsync),
        .de()
    );
       
endmodule
