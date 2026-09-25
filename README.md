# ✨ OMNIO
OMNIO is a programmable I/O ASIC specialized for emulating digital protocols such as SPI, I2C, UART, and custom interfaces. Similar to the PIO state machines on the RP2040, it contains four small cores with an instruction set designed for reading/writing pins and counting cycles with precise enough timing that a real protocol can be implemented in firmware rather than a fixed block of logic.

The current microarchitecture plan (subject to change):
- 4 independent cores
- a shared memory array (at least 32x16 bits)
- input/output FIFOs
- fractional clock divider for slower protocols like UART with exact baud rates

The goal is to at least support the following protocols:
- UART, SPI, and I2C
- low-speed USB
- 10Mbit Ethernet

This project is being developed for the [Jane Street Protocol Emulator ASIC Competition](https://blog.janestreet.com/protocol-emulator-asic-competition/), targeting Tiny Tapeout on IHP's 130 nm CMOS5L process.

Deadline: January 18, 2027. Target shuttle: March 2027 CMOS5L.

## 🌟 Repository Structure
- `rtl`: Verilog source modules, including [`PROTOCOL_TOP.v`](rtl/PROTOCOL_TOP.v)
- `tools`: Python assembler
- `docs/decisions`: architecture decision records
- `tests`: SystemVerilog testbenches and Python assembler tests
- `tests/examples`: Assembly programs
- `asic`: ASIC flow configuration and constraints

## 📄 Instruction Set
|Instruction|Operation|
|-----------|----------------------------------|
|`SET`|Write the output pin register|
|`OE`|Set which pins are driven or released|
|`LDI`|Load the transmit shift register|
|`OUT`|Shift out one bit onto a selected pin|
|`LDX`|Load the loop counter|
|`DJNZ`|Decrement the loop counter, branch if it is nonzero|
|`IN`|Sample a selected pin into the receive shift register|
|`WAIT`|Wait for a selected input pin to reach a specified level|
|`JMP`|Jump to a program address|
|`HALT`|Stop execution until reset|

### Example: UART Transmission
This program transmits 0x96 on pin 0 using an 8N1 frame: one start bit, eight data bits sent LSB first, and one stop bit.
```
SET 1
OE 1 [15]
LDI 0x96
LDX 8
SET 0 [15]
bit:
  OUT 0 [14]
  DJNZ bit
SET 1 [15]
HALT
```

## ✔️ Verification and Testing
An FPGA is being used to test the RTL before the ASIC flow. Currently exploring formal methods, random constrained tests, and AI-assisted verification.

### ✍️ Authors
Jarnail Sanghera https://www.jarnailsanghera.com

https://www.linkedin.com/in/jarnail-sanghera/
