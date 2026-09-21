`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/18/2026 12:37:29 PM
// Design Name: 
// Module Name: DELAY
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


module DELAY (
    input  wire       CLK,
    input  wire       RESET,
    input  wire       EXEC_EN,
    input  wire       DELAY_LOAD,
    input  wire [3:0] DELAY_COUNT,
    output wire       DELAY_ZERO
);
    reg [3:0] count;

    assign DELAY_ZERO = (count == 4'd0);

    // Priority: RESET, then enabled LOAD, then enabled countdown, otherwise hold.
    always @(posedge CLK) begin
        if (RESET)
            count <= 4'd0;
        else if (EXEC_EN && DELAY_LOAD)
            count <= DELAY_COUNT;
        else if (EXEC_EN && count != 4'd0)
            count <= count - 4'd1;
    end
    // Loading 7 skips the next seven execution edges. On the edge that changes
    // count from 1 to 0, the other registers still see DELAY_ZERO=0 before that
    // edge, so they hold. The next instruction executes one edge later.
    // DELAY_COUNT can change while waiting; it is ignored unless LOAD=1.
endmodule
