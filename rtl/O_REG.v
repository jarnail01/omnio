`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/18/2026 12:37:29 PM
// Design Name: 
// Module Name: O_REG
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


module O_REG (
    input  wire       CLK,
    input  wire       RESET,
    input  wire       O_REG_WE,
    input  wire       O_BIT_WE,
    input  wire [7:0] ARG,
    input  wire [2:0] PIN_SEL,
    input  wire       S_BIT,
    output reg  [7:0] O_VALUE
);
    // SET writes the whole register. OUT writes only the selected bit.
    // The CU never intentionally asserts both write enables together.
    always @(posedge CLK) begin
        if (RESET)
            O_VALUE <= 8'h00;
        else if (O_REG_WE)
            O_VALUE <= ARG;
        else if (O_BIT_WE)
            O_VALUE[PIN_SEL] <= S_BIT;
        // Other bits hold during a selected-bit write.
    end
endmodule
