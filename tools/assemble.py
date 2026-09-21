#!/usr/bin/env python3
"""Assemble PE16 source into a complete, HALT-padded instruction memory image.

Usage: python3 assemble.py examples/uart.asm --rev rev2 -o program.mem
Also writes program.lst with addresses, encodings, and source lines.

Labels are case sensitive; mnemonics are case insensitive. Use # or ; for
comments. Numeric operands accept decimal, 0x hexadecimal, or 0b binary.
"""

import argparse
import os
import tempfile
from pathlib import Path
import re
import sys


ASSEMBLER_VERSION = "0.2.0"  # REV2 grows; this is a tool version, not REV3.
PROGRAM_WORDS = 64
HALT_WORD = 0xC000
OPCODES = {
    "NOP": 0x0,
    "SET": 0x1,
    "OE": 0x2,
    "LDI": 0x3,
    "LDX": 0x4,
    "OUT": 0x5,
    "IN": 0x6,
    "WAIT": 0x7,
    "JMP": 0x8,
    "DJNZ": 0x9,
    "JZ": 0xA,
    "XOR": 0xB,
    "HALT": 0xC,
}
REVISIONS = {
    "rev1": frozenset({"SET", "OE", "JMP", "HALT"}),
    "rev2": frozenset({"SET", "OE", "JMP", "HALT", "LDI", "OUT",
                       "LDX", "DJNZ", "IN", "WAIT"}),
}

LABEL = re.compile(r"[A-Za-z_][A-Za-z_0-9]*")
INTEGER = re.compile(r"(?:[0-9]+|0[xX][0-9a-fA-F]+|0[bB][01]+)")


class AssemblerError(ValueError):
    """Source error with a one-based line number for editor-friendly output."""

    def __init__(self, line_number, message):
        self.line_number = line_number
        super().__init__(f"line {line_number}: {message}")


def _number(token, maximum, line_number, name):
    if not INTEGER.fullmatch(token):
        raise AssemblerError(line_number, f"{name} must be an integer, got {token!r}")
    base = 16 if token.lower().startswith("0x") else 2 if token.lower().startswith("0b") else 10
    value = int(token, base)
    if not 0 <= value <= maximum:
        raise AssemblerError(line_number, f"{name} must be in 0..{maximum}, got {value}")
    return value


def _instruction(text, labels, line_number, revision):
    delay = 0
    if "[" in text or "]" in text:
        suffix = re.fullmatch(r"([^\[\]]+)\[\s*([^\[\]]+?)\s*\]\s*", text)
        if suffix is None:
            raise AssemblerError(line_number, "expected one trailing delay suffix [0..15]")
        text = suffix.group(1).strip()
        delay = _number(suffix.group(2).strip(), 15, line_number, "delay")

    parts = text.split(None, 1)
    mnemonic = parts[0].upper()
    if mnemonic not in OPCODES:
        raise AssemblerError(line_number, f"unknown instruction {parts[0]!r}")
    if mnemonic not in REVISIONS[revision]:
        raise AssemblerError(line_number, f"{mnemonic} is not implemented in RTL revision {revision}")
    operand_text = parts[1].strip() if len(parts) == 2 else ""
    operands = [part.strip() for part in operand_text.split(",")] if operand_text else []
    expected = 0 if mnemonic in {"NOP", "HALT"} else 2 if mnemonic == "WAIT" else 1
    if len(operands) != expected or any(not operand for operand in operands):
        raise AssemblerError(line_number, f"{mnemonic} expects {expected} operand(s)")

    argument = 0
    if mnemonic == "HALT":
        if delay:
            raise AssemblerError(line_number, "HALT requires delay 0")
    elif mnemonic == "WAIT":
        pin = _number(operands[0], 7, line_number, "pin")
        level = _number(operands[1], 1, line_number, "level")
        argument = (level << 7) | pin
    elif mnemonic in {"OUT", "IN"}:
        argument = _number(operands[0], 7, line_number, "pin")
    elif mnemonic in {"JMP", "DJNZ", "JZ"}:
        target = operands[0]
        if target in labels:
            argument = labels[target]
        elif LABEL.fullmatch(target):
            raise AssemblerError(line_number, f"undefined label {target!r}")
        else:
            argument = _number(target, PROGRAM_WORDS - 1, line_number, "address")
    elif operands:
        argument = _number(operands[0], 255, line_number, "value")

    # Each operand has been checked before encoding, so all reserved argument
    # bits are necessarily zero. No raw-word directive can bypass those checks.
    return (OPCODES[mnemonic] << 12) | (delay << 8) | argument


def _assemble(source, revision):
    """Return exactly 64 16-bit words, resolving forward and backward labels."""
    if revision not in REVISIONS:
        raise ValueError(f"Unknown RTL revision: {revision}")
    labels = {}
    instructions = []
    for line_number, original in enumerate(source.splitlines(), start=1):
        text = re.split(r"[#;]", original, maxsplit=1)[0].strip()
        if not text:
            continue
        # Permit labels on their own lines, or directly before an instruction.
        while ":" in text:
            name, text = text.split(":", 1)
            name, text = name.strip(), text.strip()
            if not LABEL.fullmatch(name):
                raise AssemblerError(line_number, f"invalid label {name!r}")
            if name in labels:
                raise AssemblerError(line_number, f"duplicate label {name!r}")
            if len(instructions) >= PROGRAM_WORDS:
                raise AssemblerError(line_number, "label address exceeds instruction memory")
            labels[name] = len(instructions)
        if text:
            if len(instructions) >= PROGRAM_WORDS:
                raise AssemblerError(line_number, "program exceeds 64 instruction words")
            instructions.append((line_number, text))

    words = [_instruction(text, labels, line_number, revision) for line_number, text in instructions]
    return words + [HALT_WORD] * (PROGRAM_WORDS - len(words)), instructions


def assemble(source, revision="rev2"):
    """Return 64 words for the selected implemented RTL subset."""
    return _assemble(source, revision)[0]


def make_outputs(source, revision):
    """Validate once and return plain hexadecimal memory and readable listing."""
    words, instructions = _assemble(source, revision)
    memory = "".join(f"{word:04X}\n" for word in words)
    lines = source.splitlines()
    listing = [f"PE16 assembler {ASSEMBLER_VERSION} | RTL {revision} | {len(instructions)}/64 instructions",
               "ADDR  HEX   LINE  SOURCE  (addresses are hexadecimal word indices)"]
    for address, word in enumerate(words):
        if address < len(instructions):
            line, _ = instructions[address]
            listing.append(f"{address:02X}    {word:04X}  {line:4d}  {lines[line - 1].strip()}")
        else:
            listing.append(f"{address:02X}    {word:04X}     -  HALT ; padding")
    return memory, "\n".join(listing) + "\n"


def write_outputs(items):
    """Stage both files before replacing either; atomic replacement per file.

    This is not a multi-file filesystem transaction. A replacement I/O failure
    may leave only one output updated; all errors return failure to the caller.
    """
    pending = []
    try:
        for path, content in items:
            path.parent.mkdir(parents=True, exist_ok=True)
            with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8",
                                             dir=path.parent, delete=False) as temp:
                temporary = Path(temp.name)
                pending.append((temporary, path))
                temp.write(content)
        for temporary, path in pending:
            os.replace(temporary, path)
    finally:
        for temporary, _ in pending:
            temporary.unlink(missing_ok=True)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", action="version", version=ASSEMBLER_VERSION)
    parser.add_argument("source", type=Path, help="Assembly source")
    parser.add_argument("--rev", required=True, choices=sorted(REVISIONS),
                        help="Implemented RTL revision, not the full draft ISA")
    parser.add_argument("-o", "--output", type=Path, required=True, help="64-word .mem output")
    parser.add_argument("--listing", type=Path, help="Listing path; default: output with .lst suffix")
    args = parser.parse_args(argv)
    listing = args.listing or args.output.with_suffix(".lst")
    try:
        # Prevent accidental replacement of source or overlap between outputs.
        paths = [args.source.resolve(), args.output.resolve(), listing.resolve()]
        if len(set(paths)) != 3:
            raise ValueError("Source, memory output, and listing must be distinct files")
        existing = [p for p in paths if p.exists()]
        for i, path in enumerate(existing):
            if any(path.samefile(other) for other in existing[i + 1:]):
                raise ValueError("Source and output paths must not alias the same file")
        source = args.source.read_text(encoding="utf-8")
        memory, text = make_outputs(source, args.rev)
        write_outputs([(paths[1], memory), (paths[2], text)])
    except AssemblerError as exc:
        print(f"{args.source}:{exc.line_number}: {str(exc).split(': ', 1)[1]}", file=sys.stderr)
        print("Assembly failed; existing outputs were not changed.", file=sys.stderr)
        return 1
    except (OSError, UnicodeError, ValueError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1
    print(f"Assembled RTL {args.rev}: {args.output} and {listing}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
