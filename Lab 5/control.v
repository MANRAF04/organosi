// Module to control the data path. 
//                          Input: op, func of the inpstruction
//                          Output: all the control signals needed 
module ControlUnit(
           input [5:0] opcode, 
           input [5:0] func,
           output [3:0] aluOp,
           output rWrite;
           output rDst,
           output aluSrc,
           output branch,
           output memWrite,
           output memToReg, 
           );
		   
// Write the FSM code here
always @(*) begin
    case (opcode)
        R_FORMAT:
            assign rWrite = 1; 
            assign rDst = 1; 
            assign aluSrc = 0; 
            assign branch = 0; 
            assign memWrite = 0; 
            assign memToReg = 0; 
            assign aluOp = 4'b0010;
        LW:
            assign rWrite = 1; 
            assign rDst = 0; 
            assign aluSrc = 1; 
            assign branch = 0; 
            assign memWrite = 0; 
            assign memToReg = 1; 
            assign aluOp = 4'b0000;
        SW:
            assign rWrite = 1; 
            assign rDst = 1'bx; 
            assign aluSrc = 1; 
            assign branch = 0; 
            assign memWrite = 1; 
            assign memToReg = 1'bx; 
            assign aluOp = 4'b0000;
        BNE:
        BEQ:
            assign rWrite = 1; 
            assign rDst = 1; 
            assign aluSrc = 0; 
            assign branch = 0; 
            assign memWrite = 0; 
            assign memToReg = 0; 
            assign aluOp = 4'b0010;
        ADDI:
            assign rWrite = 1; 
            assign rDst = 0; 
            assign aluSrc = 1; 
            assign branch = 0; 
            assign memWrite = 0; 
            assign memToReg = 0; 
            assign aluOp = 4'b0000; 
        default: 
    endcase
end


endmodule