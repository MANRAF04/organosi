// Module to control the data path. 
//                          Input: op, func of the inpstruction
//                          Output: all the control signals needed 
module ControlUnit(
           input [5:0] opcode, 
           input [5:0] func,
           output [3:0] aluOp,
           output rWrite,
           output rDst,
           output aluSrc,
           output branch,
           output bequal,
           output memWrite,
           output memToReg
           );
`include "constants.vh"
		   
// Write the FSM code here
always @(*) begin
    rWrite = 0; 
    rDst = 0; 
    aluSrc = 0; 
    branch = 0; 
    memWrite = 0; 
    memToReg = 0;
    bequal = 0; 
    case (opcode)
        R_FORMAT:
            rWrite = 1; 
            rDst = 1; 
        LW:
             rWrite = 1; 
             aluSrc = 1; 
             memToReg = 1; 
             aluOp = 4'b0010;
        SW:
             rWrite = 1; 
             rDst = 1'bx; 
             aluSrc = 1; 
             memWrite = 1; 
             memToReg = 1'bx; 
             aluOp = 4'b0010;
        BNE:
             rWrite = 1; 
             rDst = 1; 
             aluOp = 4'b0110;
        BEQ:
             rWrite = 1; 
             rDst = 1; 
             aluOp = 4'b0110;
             bequal = 1;
        ADDI:
             rWrite = 1; 
             aluSrc = 1; 
             aluOp = 4'b0010; 
        default: 
    endcase
end

always @(*) begin
    case (func)
        ADD:
            aluOp = 4'b0010;
        SUB:
            aluOp = 4'b0110;
        OR:
            aluOp = 4'b0001;
        AND:
            aluOp = 4'b0000;
        SLT:
            aluOp = 4'b0111;
        default: aluOp = 4'bx; 
    endcase
end


endmodule
