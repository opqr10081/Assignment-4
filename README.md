# Assignment-4

Computer Architecture assignment about pipelined MIPS datapath, early branch resolution, and data forwarding.

---

## Problem 1: Early Branch Resolution

The branch decision is made in the Decode stage.

```verilog
wire bne_D = (instr_D[31:26] == 6'b000101);

assign pc_src_D = branch_D &
    (bne_D ? ~(rd1_D == rd2_D)
           :  (rd1_D == rd2_D));
```

This logic supports both `beq` and `bne`.

For `beq`, the branch is taken when the two register values are equal.

```text
beq: rd1_D == rd2_D
```

For `bne`, the branch is taken when the two register values are not equal.

```text
bne: rd1_D != rd2_D
```

The opcode of `bne` is `000101`, so the signal `bne_D` becomes 1 when the instruction in the Decode stage is a `bne` instruction.

---

## Problem 2: Data Forwarding

### Assembly Code

```mips
addi $t0, $0, 10
addi $t1, $0, 5
bne  $t0, $t1, -3
addi $t2, $0, 0x99
```

The last instruction is a CANARY instruction.  
It must never execute.

---

## Register Addresses

| Register | Address |
|---|---:|
| $t0 | 8 |
| $t1 | 9 |
| $t2 | 10 |
| $t3 | 11 |

---

## Machine Code Conversion

### 1. `addi $t0, $0, 10`

I-type instruction format:

```text
opcode | rs | rt | immediate
```

For this instruction:

```text
opcode = 001000
rs     = $0  = 0
rt     = $t0 = 8
imm    = 10  = 0x000A
```

Hex machine code:

```text
2008000A
```

---

### 2. `addi $t1, $0, 5`

For this instruction:

```text
opcode = 001000
rs     = $0  = 0
rt     = $t1 = 9
imm    = 5   = 0x0005
```

Hex machine code:

```text
20090005
```

---

### 3. `bne $t0, $t1, -3`

For this instruction:

```text
opcode = 000101
rs     = $t0 = 8
rt     = $t1 = 9
imm    = -3
```

The immediate value `-3` is represented as a 16-bit two's complement value:

```text
-3 = 0xFFFD
```

Hex machine code:

```text
1509FFFD
```

---

### 4. `addi $t2, $0, 0x99`

For this instruction:

```text
opcode = 001000
rs     = $0  = 0
rt     = $t2 = 10
imm    = 0x0099
```

Hex machine code:

```text
200A0099
```

---

## Instruction Memory

| Address | Instruction | Hex |
|---|---|---|
| 0x00 | `addi $t0, $0, 10` | `2008000A` |
| 0x04 | `addi $t1, $0, 5` | `20090005` |
| 0x08 | `bne $t0, $t1, -3` | `1509FFFD` |
| 0x0C | `addi $t2, $0, 0x99` | `200A0099` |

The instruction memory is initialized as follows:

```verilog
RAM[0] = 32'h2008000A; // addi $t0, $0, 10
RAM[1] = 32'h20090005; // addi $t1, $0, 5
RAM[2] = 32'h1509FFFD; // bne $t0, $t1, -3
RAM[3] = 32'h200A0099; // addi $t2, $0, 0x99
```

---

## Branch Target Calculation

The `bne` instruction is located at address `0x08`.

The branch target address is calculated using:

```text
PC + 4 + (sign-extended immediate << 2)
```

For this instruction:

```text
PC = 0x08
PC + 4 = 0x0C
immediate = -3
immediate << 2 = -12
target address = 0x0C - 0x0C = 0x00
```

Therefore, when the branch is taken, the PC jumps back to address `0x00000000`.

---

## Expected Simulation Result

After the first two instructions execute:

```text
$t0 = 0x0000000A
$t1 = 0x00000005
```

The branch instruction compares `$t0` and `$t1`.

```text
$t0 != $t1
10 != 5
```

Therefore, the `bne` instruction must be taken.

The PC should jump back to address `0x00000000`.

The CANARY instruction:

```mips
addi $t2, $0, 0x99
```

must never execute.

Therefore, `$t2` must never become:

```text
0x00000099
```

---

## Verification

A correct pipelined MIPS datapath should show the following result:

```text
$t0 = 0x0000000A
$t1 = 0x00000005
$t2 != 0x00000099
```

If `$t2` becomes `0x00000099`, then the branch was not taken correctly or the forwarding/stall logic is incorrect.

---

## Data Forwarding and Stall Explanation

Since the branch decision is made in the Decode stage, the branch instruction may need values that have not yet been written back to the register file.

The instruction sequence is:

```mips
addi $t0, $0, 10
addi $t1, $0, 5
bne  $t0, $t1, -3
```

The `bne` instruction depends on `$t0` and `$t1`.

If the Decode stage compares old register values, the branch decision may be wrong.

Therefore, forwarding or stalling is required so that the `bne` instruction compares the correct values.

The correct comparison is:

```text
$t0 = 10
$t1 = 5
$t0 != $t1
```

So the branch must be taken.

---

## Files

```text
Assignment-4/
├── README.md
└── src/
    └── imem.v
```

`imem.v` contains the instruction memory initialized with the test program machine code.

---

## Conclusion

This assignment verifies early branch resolution for `bne` and data forwarding behavior in a pipelined MIPS datapath.

The program repeatedly branches back to address `0x00000000`.

The CANARY instruction should never execute.

Final expected condition:

```text
$t2 never reaches 0x00000099
```
