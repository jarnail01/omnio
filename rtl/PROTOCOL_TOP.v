`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/18/2026 12:45:53 PM
// Design Name: 
// Module Name: PROTOCOL_TOP
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


module PROTOCOL_TOP #(
    parameter MEM_FILE = "program.mem",
    parameter integer DIV_INT = 54,
    parameter integer FRAC_BITS = 8,
    parameter integer DIV_FRAC = 65
) (
    input  wire       CLK,
    input  wire       RESET,
    inout  wire [7:0] PINS,
    output wire       HALTED
);
    wire EXEC_EN;
    CLK_DIV #(
        .DIV_INT(DIV_INT), .FRAC_BITS(FRAC_BITS), .DIV_FRAC(DIV_FRAC)
    ) u_clk_div (
        .CLK(CLK), .RESET(RESET), .EXEC_EN(EXEC_EN)
    );

    // Instruction address, instruction word, and decoded data fields.
    wire [5:0]  PC_ADDR;
    wire [15:0] IR;
    wire [7:0]  ARG;
    wire [5:0]  JUMP_ADDR;

    // PC controls.
    wire PC_EN;
    wire PC_SOURCE;

    // Delay loading and completion feedback.
    wire [3:0] DELAY_COUNT;
    wire       DELAY_LOAD;
    wire       DELAY_ZERO;

    // Raw decodes are available as internal signals for simulation/debugging.
    // They do not directly enable any register writes.
    wire LDX, DJNZ, IN, WAIT;
    wire X_REG_LOAD, X_REG_DEC, RX_REG_SHIFT;
    wire X_GT_ONE;
    wire [7:0] X_VALUE;
    wire [7:0] RX_VALUE;
    wire [7:0] PIN_SAMPLE;
    wire LDI;
    wire OUT;
    wire S_REG_LOAD;
    wire S_REG_SHIFT;
    wire O_BIT_WE;
    wire [7:0] S_VALUE;

    wire SET;
    wire OE;
    wire JMP;
    wire HALT;

    // Gated register write enables and stored pin state.
    wire       O_REG_WE;
    wire       OE_REG_WE;
    wire [7:0] O_VALUE;
    wire [7:0] OE_VALUE;

    // Named connections use .MODULE_PORT(top_level_wire).
    // 1. PC selects an instruction address.
    PC u_pc (
        .CLK        (CLK),
        .RESET      (RESET),
        .PC_EN      (PC_EN),
        .PC_SOURCE  (PC_SOURCE),
        .JUMP_ADDR  (JUMP_ADDR),
        .PC_ADDR    (PC_ADDR)
    );

    // 2. Combinational ROM presents the instruction at that address.
    IMEM #(.MEM_FILE(MEM_FILE)) u_imem (
        .PC_ADDR    (PC_ADDR),
        .IR         (IR)
    );

    // 3. Decode the instruction and allow execution only when ready.
    CU_DCDR u_cu_dcdr (
        .EXEC_EN     (EXEC_EN),
        .CLK         (CLK),
        .RESET       (RESET),
        .IR          (IR),
        .DELAY_ZERO  (DELAY_ZERO),
        .X_GT_ONE    (X_GT_ONE),
        .PIN_SAMPLE  (PIN_SAMPLE),
        .LDX         (LDX),
        .DJNZ        (DJNZ),
        .IN          (IN),
        .WAIT        (WAIT),
        .X_REG_LOAD  (X_REG_LOAD),
        .X_REG_DEC   (X_REG_DEC),
        .RX_REG_SHIFT(RX_REG_SHIFT),
        .DELAY_COUNT (DELAY_COUNT),
        .ARG         (ARG),
        .JUMP_ADDR   (JUMP_ADDR),
        .SET         (SET),
        .OE          (OE),
        .LDI         (LDI),
        .OUT         (OUT),
        .S_REG_LOAD  (S_REG_LOAD),
        .S_REG_SHIFT (S_REG_SHIFT),
        .O_BIT_WE    (O_BIT_WE),
        .JMP         (JMP),
        .HALT        (HALT),
        .O_REG_WE    (O_REG_WE),
        .OE_REG_WE   (OE_REG_WE),
        .DELAY_LOAD  (DELAY_LOAD),
        .PC_EN       (PC_EN),
        .PC_SOURCE   (PC_SOURCE),
        .halted      (HALTED)
    );

    // 4. Load the extra delay on execution; count down on subsequent execution ticks.
    DELAY u_delay (
        .EXEC_EN     (EXEC_EN),
        .CLK         (CLK),
        .RESET       (RESET),
        .DELAY_LOAD  (DELAY_LOAD),
        .DELAY_COUNT (DELAY_COUNT),
        .DELAY_ZERO  (DELAY_ZERO)
    );

    // 5. SET writes all values; OUT writes one pin from the old S_VALUE[0].
    O_REG u_o_reg (
        .CLK      (CLK),
        .RESET    (RESET),
        .O_REG_WE (O_REG_WE),
        .O_BIT_WE (O_BIT_WE),
        .PIN_SEL  (ARG[2:0]),
        .S_BIT    (S_VALUE[0]),
        .ARG      (ARG),
        .O_VALUE  (O_VALUE)
    );

    // 6. OE writes which pins are allowed to drive.
    OE_REG u_oe_reg (
        .CLK       (CLK),
        .RESET     (RESET),
        .OE_REG_WE (OE_REG_WE),
        .ARG       (ARG),
        .OE_VALUE  (OE_VALUE)
    );

    // 7. The data register loads on LDI and shifts once per executed OUT.
    // Nonblocking assignments make O_REG capture the old bit on that same edge.
    S_REG u_s_reg (
        .CLK         (CLK),
        .RESET       (RESET),
        .S_REG_LOAD  (S_REG_LOAD),
        .S_REG_SHIFT (S_REG_SHIFT),
        .ARG         (ARG),
        .S_VALUE     (S_VALUE)
    );

    X_REG u_x_reg (
        .CLK(CLK), .RESET(RESET), .ARG(ARG),
        .X_REG_LOAD(X_REG_LOAD), .X_REG_DEC(X_REG_DEC),
        .X_VALUE(X_VALUE), .X_GT_ONE(X_GT_ONE)
    );

    // Sample the actual pin bus, not just our output latch.
    // Synchronizers run every system clock, including WAIT, delay, and HALT.
    INPUT_SYNC u_input_sync (
        .CLK(CLK), .RESET(RESET), .PIN_IN(PINS), .PIN_SAMPLE(PIN_SAMPLE)
    );

    RX_REG u_rx_reg (
        .CLK(CLK), .RESET(RESET), .RX_REG_SHIFT(RX_REG_SHIFT),
        .RX_BIT(PIN_SAMPLE[ARG[2:0]]), .RX_VALUE(RX_VALUE)
    );

    // Eight independent top-level tri-state drivers.
    // This generate loop creates eight connections in hardware; it is not
    // a loop that runs over eight clock cycles.
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : pin_drivers
            assign PINS[i] = OE_VALUE[i] ? O_VALUE[i] : 1'bz;
        end
    endgenerate

    // Reset clears the OE register on a rising edge, releasing all pins.
    // HALT leaves both output registers unchanged, preserving the pin state.
endmodule
