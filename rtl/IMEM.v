`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/18/2026 12:37:29 PM
// Design Name: 
// Module Name: IMEM
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


module IMEM #(
    parameter MEM_FILE = "program.mem"
) (
    input wire [5:0] PC_ADDR,
    output wire [15:0] IR
);
    reg [15:0] memory [0:63];
    initial begin
        $readmemh(MEM_FILE, memory);
    end
    assign IR = memory[PC_ADDR];
endmodule
