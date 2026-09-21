# 📦 OMNIO
OMNIO is a programmable I/O ASIC specialized for emulating digital protocols such as SPI, I2C, UART, and custom interfaces. Similar to the PIO state machines on the RP2040, it contains a small CPU with an instruction set designed for reading/writing pins and counting cycles with precise enough timing that a real protocol can be implemented in firmware rather than a fixed block of logic.

This project is being developed for the [Jane Street Protocol Emulator ASIC Competition](https://blog.janestreet.com/protocol-emulator-asic-competition/), targeting Tiny Tapeout on IHP's 130 nm CMOS5L process.

Deadline: January 18, 2027. Target shuttle: March 2027 CMOS5L.

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

## 🌟 Highlights
- s

## ℹ️ Overview
A paragraph explaining your work, who you are, and why you made it.

### ✍️ Authors
Mention who you are and link to your GitHub or organization's website.
