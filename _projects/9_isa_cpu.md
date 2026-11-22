---
layout: page
title: 16-bit Single-Cycle CPU in Verilog
description: A custom 16-bit instruction set and the single-cycle processor that runs it, from opcode map to waveform-verified Verilog and an FPGA demo.
img: assets/img/projects/thumb-cpu-16bit.webp
importance: 3
category: coursework
writeup: true
github: https://github.com/nsriad/16bit-ISA-CPU
code_label: Verilog source
facts:
  - { label: Tools, value: "Verilog · Icarus Verilog · Quartus · DE10-Lite FPGA" }
  - { label: ISA, value: "16 opcodes · 4 formats · 8 registers" }
  - { label: Memory, value: "1K × 16-bit words, linear addressing" }
  - { label: Design, value: "**Single-cycle**: one instruction per clock", highlight: true }
  - { label: Verified, value: "**Every opcode** in simulation, ALU on real hardware", highlight: true }
---

{% include site/project_parts/facts.liquid %}

{% include site/project_parts/sectionnav.liquid %}

This project designs a small computer from scratch: first the **instruction set** (what instructions exist and how each is encoded in 16 bits), then a **processor** in Verilog that fetches, decodes and executes one instruction every clock cycle. The result runs real programs with branches, loops and function calls, and every module is checked against simulation waveforms.

## The instruction set

### Four instruction formats

Every instruction is exactly 16 bits. The top four bits are always the opcode, so decoding starts the same way for all of them.

<div class="pj-caption">Table 1. Instruction formats</div>

| Format | [15:12] | [11:9] | [8:6] | [5:3] | [2:0] | Used by |
|:--|:-:|:-:|:-:|:-:|:-:|:--|
| R-type | opcode | rd | rs1 | rs2 | 000 | ADD, SUB, AND, OR, CMP |
| I-type | opcode | rd | 0 | imm8 | | ADDI, ORI, LUI, LD, ST |
| B-type | opcode | signed offset | | | | BEQ, BLT |
| J-type | opcode | absolute address | | | | JMP, CALL, RET, HALT |
{: .pj-table}

### Sixteen opcodes

Four opcode bits give exactly 16 instructions, enough to cover arithmetic, logic, memory, control flow and a halt.

<div class="pj-caption">Table 2. Opcode map</div>

| Opcode | Instr. | Fmt | Operation |
|:-:|:--|:-:|:--|
| 0000 | ADD | R | rd ← rs1 + rs2 |
| 0001 | SUB | R | rd ← rs1 − rs2 |
| 0010 | AND | R | rd ← rs1 & rs2 |
| 0011 | OR | R | rd ← rs1 \| rs2 |
| 0100 | CMP | R | set N/Z/P from rs1 − rs2 |
| 0101 | ADDI | I | rd ← rd + imm8 |
| 0110 | ORI | I | rd ← rd \| imm8 |
| 0111 | LUI | I | rd ← imm8 ≪ 8 |
| 1000 | LD | I | rd ← mem[base + imm8] |
| 1001 | ST | I | mem[base + imm8] ← rs |
| 1010 | BEQ | B | if Z: PC ← PC + 1 + offset |
| 1011 | BLT | B | if N: PC ← PC + 1 + offset |
| 1100 | JMP | J | PC ← address |
| 1101 | CALL | J | LR ← PC + 1, PC ← address |
| 1110 | RET | J | PC ← LR |
| 1111 | HALT | J | stop |
{: .pj-table}

### Registers, flags and memory

There are eight 16-bit general-purpose registers, **R0–R7**. R0 always reads zero, and R7 doubles as the **link register** that `CALL` and `RET` use. The program counter steps one word at a time through a linear memory of 1024 sixteen-bit words.

A 3-bit **NZP register** remembers whether the last result was negative, zero or positive:

$$
\begin{aligned}
N &= 1 \;\text{ if } r < 0, \\
Z &= 1 \;\text{ if } r = 0, \\
P &= 1 \;\text{ if } r > 0.
\end{aligned}
$$

`CMP` subtracts two registers only to set these flags, and the two branches read them. With operand swapping, that's enough for every comparison a language needs.

### Building 16-bit constants

Immediates are only 8 bits wide, so a full 16-bit constant takes two instructions: `LUI` fills the upper byte, then `ORI` fills the lower one.

$$
X = (\text{imm}_{\text{upper}} \ll 8) \;\big|\; \text{imm}_{\text{lower}}
$$

## Processor design

### Datapath

The processor is **single-cycle**: in one clock it fetches an instruction, reads registers, computes in the ALU, touches memory if needed, and writes the result back.

{% include site/project_parts/figure.liquid src="/assets/img/projects/cpu-16bit/datapath.webp" n=1 width=720 caption="Datapath. The control unit decodes the opcode and drives every multiplexer and write-enable; the next-PC mux chooses between PC + 1, a branch target and a jump address." %}

- **Fetch.** The PC addresses instruction memory, and an adder prepares PC + 1.
- **Register file.** Two read ports and one write port, so an R-type instruction reads both operands and writes its result in the same cycle.
- **ALU and flags.** Add, subtract, AND, OR and compare, producing a 16-bit result plus N/Z/P.
- **Memory.** `LD` and `ST` use base + offset addressing; reads are combinational and writes happen on the clock edge.
- **Write-back.** A multiplexer picks the ALU result, the loaded word or the `LUI` value.

### Control unit

A single combinational `case` statement turns the 4-bit opcode into the signals that steer the datapath:

<div class="pj-caption">Table 3. Main control signals</div>

| Signal | Meaning |
|:--|:--|
| RegWrite | write the result into rd |
| ALUSrc | use the immediate instead of rs2 |
| MemWrite / MemToReg | store to memory / load from memory |
| NZP_we | update the flags |
| Branch, BranchCond | conditional branch, testing Z (BEQ) or N (BLT) |
| Jump, Call, Ret | change the PC; CALL also writes PC + 1 into R7 |
| Halt | freeze the PC |
{: .pj-table}

### Next-PC selection

$$
\text{PC}_{\text{next}} =
\begin{cases}
\text{target} & \text{JMP, CALL} \\
\text{LR} & \text{RET} \\
\text{PC} + 1 + \text{offset} & \text{taken branch} \\
\text{PC} & \text{HALT} \\
\text{PC} + 1 & \text{otherwise}
\end{cases}
$$

## Programming with it

Here is how familiar code maps onto the instruction set. Only two branches exist (on *equal* and on *less than*), so the other comparisons come from swapping operands or skipping over a jump.

<details class="pj-more" markdown="1">
<summary>Comparisons: ==, !=, &lt;, &lt;=, &gt;, &gt;=</summary>

```nasm
; a in R2, b in R3
CMP  R2, R3      ; flags from a - b
BEQ  L_eq        ; a == b
BLT  L_lt        ; a <  b
; a <= b : BEQ L ; BLT L     (either one)
; a >  b : CMP R3, R2 ; BLT L   (b < a)
; a >= b : CMP R2, R3 ; BLT skip ; JMP L ; skip:
; a != b : BEQ skip ; JMP L ; skip:
```
</details>

<details class="pj-more" markdown="1">
<summary>A for-loop: sum = 0 + 1 + … + 4</summary>

```nasm
        ADDI R1, 0       ; i = 0      (R1 starts at 0)
        ADDI R3, 5       ; limit = 5
LOOP:   CMP  R1, R3
        BLT  BODY        ; i < 5 ?
        JMP  END
BODY:   ADD  R2, R2, R1  ; sum += i
        ADDI R1, 1       ; i++
        JMP  LOOP
END:    HALT
```
</details>

<details class="pj-more" markdown="1">
<summary>A function call and return</summary>

```nasm
        CALL FUNC        ; R7 <- PC + 1, jump to FUNC
        ...              ; execution continues here after RET
FUNC:   ADD  R4, R1, R1  ; function body
        RET              ; PC <- R7
```
</details>

## Verification

Each module was simulated on its own with Icarus Verilog and inspected as waveforms, then the whole CPU was run on a test program.

### Module tests

{% include site/project_parts/figure.liquid src="/assets/img/projects/cpu-16bit/alu-waveform.webp" n=2 width=900 caption="ALU: for each operation code the result and the N/Z/P flags follow the inputs, including the overflow-to-negative cases." %}

{% include site/project_parts/figure.liquid src="/assets/img/projects/cpu-16bit/control-waveform.webp" n=3 width=900 caption="Control unit: all sixteen opcodes (0000–f000) in sequence, each producing the expected combination of control signals." %}

### The whole processor

A short program exercises arithmetic, a compare, a branch that is *not* taken, a function call and return, a jump and a halt:

<div class="pj-caption">Table 4. Execution trace</div>

| PC | Instruction | Effect |
|--:|:--|:--|
| 0 | LUI R1, 0 | R1 ← 0 |
| 1 | ADDI R1, 5 | R1 ← 5 |
| 2 | ADDI R2, 3 | R2 ← 3 |
| 3 | ADD R3, R1, R2 | R3 ← 8 |
| 4 | CMP R1, R2 | 5 − 3 > 0, so P = 1 |
| 5 | BLT −2 | not taken (N = 0) |
| 6 | CALL 10 | LR ← 7, PC ← 10 |
| 10 | ADD R4, R1, R1 | R4 ← 10 (function body) |
| 11 | RET | PC ← 7 |
| 7 | JMP 12 | PC ← 12 |
| 12 | HALT | stop |
{: .pj-table}

{% include site/project_parts/figure.liquid src="/assets/img/projects/cpu-16bit/full-cpu-waveform.webp" n=4 width=760 caption="Full-CPU waveform: the PC runs 0 → 6, jumps to 10 (a, b), returns to 7, jumps to 12 (c) and halts, with register writes and flags matching Table 4." %}

### On real hardware

As a hardware check, the ALU was synthesized for an Intel MAX 10 FPGA (DE10-Lite board) with switches as inputs and LEDs as outputs. It uses **25 of 49,760 logic elements** (under 1%) and no registers, and every operation on the board matched the simulation.

## Takeaways

- **Design the ISA for the hardware.** A fixed opcode position and fixed-width fields make the decoder a single small `case` statement.
- **Two branches go a long way.** `BEQ` and `BLT` plus operand swapping cover all six comparisons.
- **Single-cycle is simple but slow.** The clock must fit the longest path (fetch, ALU, memory, write-back) for every instruction.
- **Next steps:** a pipelined version with hazard handling, a hardware stack, shift and multiply instructions, and the full CPU on the FPGA.

## Code

<div class="pj-note pj-ref" markdown="1">
<i class="fa-solid fa-microchip"></i> **Source:** all Verilog modules (ALU, register file, control unit, memories, NZP register, top level), testbenches and the FPGA demo are in [nsriad/16bit-ISA-CPU](https://github.com/nsriad/16bit-ISA-CPU).
</div>

{% include site/lightbox.liquid %}
