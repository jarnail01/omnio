`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2026 06:48:40 PM
// Design Name: 
// Module Name: CLK_DIV
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


module CLK_DIV #(
    parameter integer DIV_INT = 54,
    parameter integer FRAC_BITS = 8,
    parameter integer DIV_FRAC = 65
) (
    input  wire CLK,
    input  wire RESET,
    output wire EXEC_EN
);
    reg [15:0] remaining;
    reg [FRAC_BITS-1:0] fraction;
    localparam [15:0] BASE_RELOAD = DIV_INT - 1;
    localparam [FRAC_BITS-1:0] FRAC_STEP = DIV_FRAC;
    wire [FRAC_BITS:0] fraction_sum;

    assign fraction_sum = {1'b0, fraction} + {1'b0, FRAC_STEP};
    assign EXEC_EN = !RESET && (remaining == 16'd0);

    // The first rising edge after reset executes immediately.
    // At each tick, schedule the NEXT interval: N or N+1 clocks.
    // Fractional carry distributes the longer intervals over time.
    always @(posedge CLK) begin
        if (RESET) begin
            remaining <= 16'd0;
            fraction  <= {FRAC_BITS{1'b0}};
        end else if (EXEC_EN) begin
            remaining <= BASE_RELOAD + {{15{1'b0}}, fraction_sum[FRAC_BITS]};
            fraction  <= fraction_sum[FRAC_BITS-1:0];
        end else begin
            remaining <= remaining - 16'd1;
        end
    end

    // This design uses explicit positive divisors; it does not implement
    // RP2040's special zero encoding. Reject invalid settings in simulation.
    // synthesis translate_off
    initial begin
        if (FRAC_BITS < 1 || FRAC_BITS > 16 || DIV_INT < 1 ||
            DIV_INT > 65535 || DIV_FRAC < 0 || DIV_FRAC >= (2**FRAC_BITS)) begin
            $display("ERROR: invalid CLK_DIV parameters");
            $finish;
        end
    end
    // synthesis translate_on
endmodule
