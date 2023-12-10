`include "data.v"
`include "control.v"


module CPU(clock,reset);

    reg [31:0] PC;
    reg inst_wen, inst_ren;
    input clock, reset;
    wire [31:0] din, dout; 
    wire [5:0] wreg;
    wire [3:0] aluOp;
    wire rWrite, rDst, aluSrc, branch, bequal, memWrite, memToReg;
    wire [4:0] rdA, rdB;
    wire [31:0] wd;

    always @(negedge clock) begin
        PC = PC + 1;
    end

    always @(dout) begin   // MUX for wreg
        wreg = (rDst) ? dout[15:11] : dout[20:16];
    end

    assign PC = 32'b0;
    assign inst_ren = 1;
    assign inst_wen = 0;

    Memory InstMemory(.clock(clock),.reset(reset),.ren(inst_ren),.wen(inst_wen),.addr(PC),.din(din),.dout(dout));
    RegFile cpu_regs(.clock(clock), .reset(reset), .raA(dout[25:21]), .raB(dout[20:16]), .wa(wreg), .wen(rWrite), .wd(), .rdA(rdA), .rdB(rdB)); // for next
    ControlUnit cUnit(.opcode(dout[31:26]),.func(dout[5:0]),.aluOp(aluop), .rWrite(rWrite), .rDst(rDst), .aluSrc(aluSrc),
                  .branch(branch), .bequal(bequal), .memWrite(memWrite), .memToReg(memToReg));
    ALU alu ();






endmodule