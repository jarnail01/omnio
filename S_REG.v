`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/18/2026 06:35:06 PM
// Design Name: 
// Module Name: S_REG
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


module S_REG (
    input  wire       CLK,
    input  wire       RESET,
    input  wire       S_REG_LOAD,
    input  wire       S_REG_SHIFT,
    input  wire [7:0] ARG,
    output reg  [7:0] S_VALUE
);

    // Priority: reset, load, shift, otherwise hold.
    // The CU never intentionally asserts LOAD and SHIFT together.
    always @(posedge CLK) begin
        if (RESET)
            S_VALUE <= 8'h00;
        else if (S_REG_LOAD)
            S_VALUE <= ARG;
        else if (S_REG_SHIFT)
            S_VALUE <= {1'b0, S_VALUE[7:1]};
        // No enable: retain the byte, including during delays and HALT.
    end
    
endmodule

