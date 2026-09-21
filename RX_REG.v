`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2026 05:42:58 PM
// Design Name: 
// Module Name: RX_REG
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


module RX_REG (
    input wire CLK,
    input wire RESET,
    input wire RX_REG_SHIFT,
    input wire RX_BIT,
    output reg [7:0] RX_VALUE
);
    // Eight LSB-first samples reconstruct one byte. TX data lives in S_REG.
    always @(posedge CLK) begin
        if (RESET)
            RX_VALUE <= 8'h00;
        else if (RX_REG_SHIFT)
            RX_VALUE <= {RX_BIT, RX_VALUE[7:1]};
    end
    // No byte-valid flag or host readout yet; inspect RX_VALUE in simulation.
endmodule