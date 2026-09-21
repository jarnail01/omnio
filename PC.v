`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/18/2026 12:37:29 PM
// Design Name: 
// Module Name: PC
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


module PC(
    input  wire       CLK,
    input  wire       RESET,
    input  wire       PC_EN,
    input  wire       PC_SOURCE,
    input  wire [5:0] JUMP_ADDR,
    output reg  [5:0] PC_ADDR
    );
    
    wire [5:0] pc_plus_one;
    wire [5:0] pc_next;
    
    // Whole-instruction addresses: advance by 1, not by the byte count.
    assign pc_plus_one = PC_ADDR + 6'd1;

    // The input mux you described.
    assign pc_next = PC_SOURCE ? JUMP_ADDR : pc_plus_one;

    always @(posedge CLK) begin
        if (RESET)
            PC_ADDR <= 6'd0;
        else if (PC_EN)
            PC_ADDR <= pc_next;
        // Otherwise hold during delays or HALT.
    end
    // A six-bit sequential increment wraps from 63 back to 0.
    
endmodule
