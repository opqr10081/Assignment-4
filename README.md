# Assignment-4

Computer Architecture assignment about pipelined MIPS datapath, early branch resolution, and data forwarding.

## Problem 1: Early Branch Resolution

The branch decision is made in the Decode stage.

```verilog
wire bne_D = (instr_D[31:26] == 6'b000101);

assign pc_src_D = branch_D &
    (bne_D ? ~(rd1_D == rd2_D)
           :  (rd1_D == rd2_D));
