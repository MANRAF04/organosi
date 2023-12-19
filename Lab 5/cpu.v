`include "data.v"
`include "control.v"


module CPU(clock,reset);

    reg [31:0] PC = 32'h0;
    reg inst_wen = 0, inst_ren = 1;
    input clock, reset;
    wire [31:0] din, dout, mdout; 
    reg [4:0] wreg;
    wire [3:0] aluOp;
    wire rWrite, rDst, aluSrc, branch, memWrite, memToReg, memRead;
    wire [31:0] rdA, rdB;
    wire [31:0] aluOut;
    reg [31:0] signXt, inB, wd;
    wire zero;

    always @(posedge clock, negedge reset) begin
        if (!reset)
            PC <= -1;
        else if (PC == -1)
            PC <= 0;
        else 
            PC <= PC + 4;
    end
        
    always @(dout,rDst) begin   // MUX for wreg
        wreg <= (rDst) ? dout[15:11] : dout[20:16];
        signXt[15:0] <= dout[15:0];
        signXt[31:16] <= {16{dout[15]}};
    end

    always @(rdB, signXt, aluSrc) begin // MUX for inB
        inB <= (aluSrc) ? (signXt) : (rdB);
    end

    always @(aluOut, mdout, memToReg) begin // MUX for write data
        wd <= (memToReg) ? (mdout) : (aluOut);
    end
    
    always @(posedge clock) begin
        if((zero^dout[26]) & branch) begin
            signXt = signXt<<2;   // (signXt *= 4)
            PC = PC + signXt - 4;
        end
    end

//                                divide PC with for to go to the right inst. memory data array index
    Memory cpu_IMem(.clock(clock),.reset(reset),.ren(inst_ren),.wen(inst_wen),.addr({2'b0, PC[31:2]}),.din(din),.dout(dout));

    RegFile cpu_regs(.clock(clock), .reset(reset), .raA(dout[25:21]), .raB(dout[20:16]), .wa(wreg), .wen(rWrite), .wd(wd), .rdA(rdA), .rdB(rdB));

    ControlUnit cUnit(.opcode(dout[31:26]),.func(dout[5:0]),.aluOp(aluOp), .rWrite(rWrite), .rDst(rDst), .aluSrc(aluSrc),
                      .branch(branch), .memWrite(memWrite), .memToReg(memToReg), .memRead(memRead));

    ALU #(32) alu(.out(aluOut),.zero(zero), .inA(rdA), .inB(inB), .op(aluOp));

    Memory cpu_DMem(.clock(clock), .reset(reset), .ren(memRead), .wen(memWrite),.addr(aluOut),.din(rdB),.dout(mdout));
    
endmodule