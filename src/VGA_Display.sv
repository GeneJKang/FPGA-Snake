`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2026 06:17:51 PM
// Design Name: 
// Module Name: VGA_Display
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


module VGA_Display(
    input logic clk,
    input logic rst,
    output logic hsync,
    output logic vsync,
    output logic video_on,
    output logic [10:0] x,  //horizontal pixels
    output logic [10:0] y   //vertical pixels
    );
    
    //VGA timing constraints for 1280x720 at 60 Hz
    //The values were taken from VESA monitor standards
    //Horizontal
    localparam H_DISPLAY = 1280;
    localparam H_FRONT = 110;
    localparam H_SYNC = 40;
    localparam H_BACK = 220;
    localparam H_TOTAL = H_DISPLAY + H_FRONT + H_SYNC + H_BACK;
    
    //Vertical
    localparam V_DISPLAY = 720;
    localparam V_FRONT = 5;
    localparam V_SYNC = 5;
    localparam V_BACK = 20;
    localparam V_TOTAL = V_DISPLAY + V_FRONT + V_SYNC + V_BACK;
    
    logic [10:0] h_count, h_next;
    logic [10:0] v_count, v_next;
    
    logic hsync_reg, hsync_next;
    logic vsync_reg, vsync_next;
    
    //Register state
    always_ff @(posedge clk) begin
        if (rst) begin
            h_count <= 0;
            v_count <= 0;
            hsync_reg <= 0;
            vsync_reg <= 0;
        end else begin
            h_count <= h_next;
            v_count <= v_next;
            hsync_reg <= hsync_next;
            vsync_reg <= vsync_next;
        end
    end    
    
    //Next-state logic for counters
    always_comb begin //Use combinational logic
        if (h_count == H_TOTAL - 1) begin
            h_next = 0;
            if (v_count == V_TOTAL - 1) begin
                v_next = 0;
            end else begin
                v_next = v_count + 1;
            end
        end else begin
            h_next = h_count + 1;
            v_next = v_count;
        end

        //Sync pulses (720p uses active HIGH sync polarity)
        hsync_next = (h_next >= (H_DISPLAY + H_FRONT) && h_next < (H_DISPLAY + H_FRONT + H_SYNC));
        vsync_next = (v_next >= (V_DISPLAY + V_FRONT) && v_next < (V_DISPLAY + V_FRONT + V_SYNC));
    end
    
    //output signals
    assign x = h_count;
    assign y = v_count;
    assign hsync = hsync_reg;
    assign vsync = vsync_reg;
    assign video_on = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);
    
endmodule
