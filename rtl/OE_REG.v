`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/18/2026 12:37:29 PM
// Design Name: 
// Module Name: OE_REG
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


module OE_REG(
    input  wire       CLK,
    input  wire       RESET,
    input  wire       OE_REG_WE,
    input  wire [7:0] ARG,
    output reg  [7:0] OE_VALUE
);
    // OE writes all eight enables: 1 means drive, 0 means release.
    // The future top-level I/O buffers apply these enables to physical pins.
    always @(posedge CLK) begin
        if (RESET)
            OE_VALUE <= 8'h00;
        else if (OE_REG_WE)
            OE_VALUE <= ARG;
        // Otherwise retain the stored output enables, including during HALT.
    end
endmodule
