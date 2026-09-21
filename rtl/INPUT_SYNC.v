`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2026 05:42:58 PM
// Design Name: 
// Module Name: INPUT_SYNC
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


module INPUT_SYNC (
    input wire CLK,
    input wire RESET,
    input wire [7:0] PIN_IN,
    output wire [7:0] PIN_SAMPLE
);
    (* ASYNC_REG = "TRUE" *) reg [7:0] meta;
    (* ASYNC_REG = "TRUE" *) reg [7:0] synced;
    always @(posedge CLK) begin
        if (RESET) begin
            meta <= 8'h00;
            synced <= 8'h00;
        end else begin
            meta <= PIN_IN;
            synced <= meta;
        end
    end
    assign PIN_SAMPLE = synced;
    // These are independent pin synchronizers, not a coherent parallel-bus CDC.
    // Short pulses can be missed. Metastability is not modeled by RTL simulation.
endmodule