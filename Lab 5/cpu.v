`include "data.v"
`include "control.v"


module CPU(clock,reset);

    reg [31:0] PC = 32'b0;
    reg inst_wen = 0, inst_ren = 1;
    input clock, reset;
    wire [31:0] din, dout, mdout; 
    reg [4:0] wreg;
    wire [3:0] aluOp;
    wire rWrite, rDst, aluSrc, branch, bequal, memWrite, memToReg, memRead;
    wire [31:0] rdA, rdB;
    wire [31:0] aluOut;
    reg [31:0] signXt, inB, wd;
    wire zero;

    always @(negedge clock) begin
        PC = PC + 4;
    end

    always @(dout) begin   // MUX for wreg
        wreg = (rDst) ? dout[15:11] : dout[20:16];
        signXt = dout[15:0] << 1;
    end

    always @(rdB, signXt) begin // MUX for inB
        inB = (aluSrc) ? (signXt) : (rdB);
    end

    always @(aluOut, mdout) begin // MUX for write data
        wd = (memToReg) ? (aluOut) : (mdout);
    end
    
    always @(PC,signXt) begin
        if ((zero^dout[26]) & branch) begin //Alliws zero^bequal 8a to doyme
            PC = PC + signXt<<2;
        end
    end

    Memory InstMemory(.clock(clock),.reset(reset),.ren(inst_ren),.wen(inst_wen),.addr({2'b0, PC[31:2]}),.din(din),.dout(dout));
    RegFile cpu_regs(.clock(clock), .reset(reset), .raA(dout[25:21]), .raB(dout[20:16]), .wa(wreg), .wen(rWrite), .wd(wd), .rdA(rdA), .rdB(rdB));
    ControlUnit cUnit(.opcode(dout[31:26]),.func(dout[5:0]),.aluOp(aluOp), .rWrite(rWrite), .rDst(rDst), .aluSrc(aluSrc),
                      .branch(branch), .bequal(bequal), .memWrite(memWrite), .memToReg(memToReg), .memRead(memRead));
    ALU #(32) alu(.out(aluOut),.zero(zero), .inA(rdA), .inB(inB), .op(aluOp));
    Memory DataMemory(.clock(clock), .reset(reset), .ren(memRead), .wen(memWrite),.addr(aluOut),.din(rdB),.dout(mdout));
    


endmodule