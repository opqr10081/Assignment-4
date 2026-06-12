module imem(input  [5:0] addr,
            output [31:0] instr);

    reg [31:0] RAM [0:63];

    initial begin
        RAM[0] = 32'h2008000A; // addi $t0, $0, 10
        RAM[1] = 32'h20090005; // addi $t1, $0, 5
        RAM[2] = 32'h1509FFFD; // bne $t0, $t1, -3
        RAM[3] = 32'h200A0099; // addi $t2, $0, 0x99
    end

    assign instr = RAM[addr];

endmodule
