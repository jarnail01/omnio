`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/18/2026 12:37:29 PM
// Design Name: 
// Module Name: CU_DCDR
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


module CU_DCDR (
    input  wire        CLK,
    input  wire        RESET,
    input  wire        EXEC_EN,
    input  wire [15:0] IR,
    input  wire        DELAY_ZERO,
    input  wire        X_GT_ONE,
    input  wire [7:0]  PIN_SAMPLE,

    // Instruction fields: always present, even while waiting or halted.
    output wire [3:0]  DELAY_COUNT,
    output wire [7:0]  ARG,
    output wire [5:0]  JUMP_ADDR,

    // Raw opcode decodes: identify the instruction, NOT permission to execute.
    output wire        SET,
    output wire        OE,
    output wire        LDX,
    output wire        DJNZ,
    output wire        IN,
    output wire        WAIT,
    output wire        LDI,
    output wire        OUT,
    output wire        JMP,
    output wire        HALT,

    // Actual execution controls: gated by RESET, delay, and halted state.
    output wire        X_REG_LOAD,
    output wire        X_REG_DEC,
    output wire        RX_REG_SHIFT,
    output wire        S_REG_LOAD,
    output wire        S_REG_SHIFT,
    output wire        O_BIT_WE,
    output wire        O_REG_WE,
    output wire        OE_REG_WE,
    output wire        DELAY_LOAD,
    output wire        PC_EN,
    output wire        PC_SOURCE,
    output reg         halted
);
    wire [3:0] opcode;
    wire ready;
    wire valid_instruction;
    wire execute_action;
    wire wait_match;

    assign opcode      = IR[15:12];
    assign DELAY_COUNT = IR[11:8];
    assign ARG         = IR[7:0];
    assign JUMP_ADDR   = IR[5:0];

    assign SET  = (opcode == 4'h1);
    assign OE   = (opcode == 4'h2);
    assign LDX  = (opcode == 4'h4);
    assign DJNZ = (opcode == 4'h9);
    assign IN   = (opcode == 4'h6);
    assign WAIT = (opcode == 4'h7);
    assign LDI  = (opcode == 4'h3);
    assign OUT  = (opcode == 4'h5);
    assign JMP  = (opcode == 4'h8);
    assign HALT = (opcode == 4'hC);

    // OUT/IN select a pin 0..7. WAIT packs level in bit 7, pin in bits 2:0.
    // Branch destinations must fit six bits. Validate even an untaken DJNZ.
    assign valid_instruction = SET || OE || LDI || LDX ||
                               ((OUT || IN) && (IR[7:3] == 5'b00000)) ||
                               (WAIT && (IR[6:3] == 4'b0000)) ||
                               ((JMP || DJNZ) && (IR[7:6] == 2'b00)) ||
                               (HALT && (ARG == 8'h00));

    // Permission to execute at the upcoming rising edge.
    assign ready = !RESET && EXEC_EN && !halted && DELAY_ZERO;

    // A WAIT may only retire on a matching synchronized input level.
    // While waiting: no PC movement, delay reload, shifts, or counter writes.
    assign wait_match = (PIN_SAMPLE[IR[2:0]] == IR[7]);
    assign execute_action = ready && valid_instruction && !HALT &&
                            (!WAIT || wait_match);
    assign X_REG_LOAD     = execute_action && LDX;
    assign X_REG_DEC      = execute_action && DJNZ;
    assign RX_REG_SHIFT   = execute_action && IN;
    // Gate all new writes/shifts with execution, NOT just opcode decode.
    assign S_REG_LOAD     = execute_action && LDI;
    assign S_REG_SHIFT    = execute_action && OUT;
    assign O_BIT_WE       = execute_action && OUT;
    assign O_REG_WE       = execute_action && SET;
    assign OE_REG_WE      = execute_action && OE;
    assign DELAY_LOAD     = execute_action;
    assign PC_EN          = execute_action;

    // 0 selects PC+1; 1 selects JUMP_ADDR.
    // This selector can change during a delay; PC_EN=0 prevents PC movement.
    // The branch decision uses X before its same-edge decrement.
    assign PC_SOURCE = JMP || (DJNZ && X_GT_ONE);

    // HALT is an opcode decode. 'halted' remembers that HALT was executed.
    // An unsupported/malformed instruction also stops this teaching version.
    // It holds outputs; it does NOT implement the full core's fault/release logic.
    always @(posedge CLK) begin
        if (RESET)
            halted <= 1'b0;
        else if (ready && (HALT || !valid_instruction))
            halted <= 1'b1;
        // Otherwise retain the old halted flag.
    end
endmodule
