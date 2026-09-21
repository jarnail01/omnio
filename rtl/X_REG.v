`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2026 05:42:58 PM
// Design Name: 
// Module Name: X_REG
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


module X_REG (
    input wire CLK,
    input wire RESET,
    input wire X_REG_LOAD,
    input wire X_REG_DEC,
    input wire [7:0] ARG,
    output reg [7:0] X_VALUE,
    output wire X_GT_ONE
);
    // DJNZ branches iff the pre-decrement count exceeds one.
    assign X_GT_ONE = (X_VALUE > 8'd1);
    always @(posedge CLK) begin
        if (RESET)
            X_VALUE <= 8'd0;
        else if (X_REG_LOAD)
            X_VALUE <= ARG;
        else if (X_REG_DEC && (X_VALUE != 8'd0))
            X_VALUE <= X_VALUE - 8'd1;
        // Hold without an enable; zero saturates rather than wrapping to 255.
    end
endmodule