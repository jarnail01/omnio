# ✨ OMNIO
OMNIO is a programmable I/O ASIC specialized for emulating digital protocols such as SPI, I2C, UART, and custom interfaces. Similar to the PIO state machines on the RP2040, it contains four small cores with an instruction set designed for reading/writing pins and counting cycles with precise enough timing that a real protocol can be implemented in firmware rather than a fixed block of logic.

![OMNIO Core Block Diagram](docs/omnio-high-level-v2.png)
<div align="center">
  <em>Figure 1: OMNIO Core Block Diagram</em>
  <br>
  <br>
</div>

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
Every instruction is `{opcode[3:0], delay[3:0], argument[7:0]}`. An instruction performs its action on a rising clock edge, then waits `delay` additional clock edges before the next instruction can execute. Thus, ordinary instructions take exactly `1 + delay` clock cycles. A taken branch costs the same as an untaken one.
|Opcode|Instruction|Operation|Argument|
|:-----:|:-----------:|----------------------------------|----------|
|0000|`NOP`|No operation|0|
|0001|`SET`|Write the output pin register|8-bit value|
|0010|`OE`|Set which pins are driven or released|8-bit mask|
|0011|`LDI`|Load the transmit shift register|8-bit value|
|0100|`LDX`|Load the loop counter|8-bit value|
|0101|`OUT`|Shift out one bit onto a selected pin|3-bit value corresponding to pin 0 - 7|
|0110|`IN`|Sample a selected pin into the receive shift register|3-bit value corresponding to pin 0 - 7|
|0111|`WAIT`|Wait for a selected input pin to reach a specified level|[7] = level; [2:0] = pin|
|1000|`JMP`|Jump to a program address|address 0 - 63|
|1001|`DJNZ`|Decrement the loop counter, branch if it is nonzero|address 0 - 63|
|1010|`JZ`||address 0 - 63|
|1011|`XOR`||8-bit mask|
|1100|`HALT`|Stop execution until reset|0|
|1101|``||
|1110|``||
|1111|``||

### Example: UART Transmission
This program transmits 0x96 on pin 0 using an 8N1 frame: one start bit, eight data bits sent LSB first, and one stop bit.
```
SET 1         # Drive pin 1 high
OE 1 [15]     # Make pin 1 an output; wait 15 cycles (16 cycles total)
LDI 0x96      # Load 0x96 into S_REG
LDX 8         # Load 8 into X_REG
SET 0 [15]    # Pull pin 1 low; wait 15 cycles (16 cycles total)
bit:
  OUT 0 [14]  # Output the next bit in S_REG 
  DJNZ bit    # Decrement X_REG; repeat until all 8 bits are sent
SET 1 [15]    # Drive pin 1 high; wait 15 cycles (16 cycles total)
HALT          # End of program
```

## 🗃️ Registers
The following datapath registers keep track of data, loop counts, and how OMNIO reads from or drives its GPIO pins:
| Register | Purpose |
|:---:|---|
| `X_REG` | Loop counter. `LDX` loads the count. |
| `S_REG` | Serial transmit data. Holds data being shifted out through the configured output pin. |
| `RX_REG` | Receive data. `IN` samples selected input pin(s) and places the captured value here. |
| `OE_REG` | Output-enable. Controls whether each GPIO pin actively drives an output or not. |
| `O_REG` | Output value. Holds the values driven onto pins when the corresponding `OE_REG` bit is enabled. |

## ✔️ Verification and Testing
An FPGA is being used to test the RTL before the ASIC flow. Currently exploring formal methods, random constrained tests, and AI-assisted verification.

## 🎯 Personal Learning Outcomes
By the completion of this project, I should be able to:
- Translate system requirements into hardware architecture
- Design an instruction set based on the needs of real workloads, with both the microarchitecture and software in mind
- Implement SPI/I2C/UART receivers and transmitters using software-controlled I/O
- Write clean and modular Verilog RTL that others can easily understand
- Build a formal verification strategy and verify at multiple abstraction levels (individual modules, core, and the whole ASIC)
- Make quantitative PPA tradeoffs and design under real physical constraints
- Communicate hardware design documentation professionally (arch/timing diagrams, ISA documentation, decision documents, 

## ✍️ Author
**Jarnail Sanghera**

[Website](https://www.jarnailsanghera.com)

[LinkedIn](https://www.linkedin.com/in/jarnail-sanghera/)
