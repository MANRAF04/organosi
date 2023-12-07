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
           output bequal,
           output memWrite,
           output memToReg, 
           );
		   
// Write the FSM code here
always @(*) begin
    assign rWrite = 0; 
    assign rDst = 0; 
    assign aluSrc = 0; 
    assign branch = 0; 
    assign memWrite = 0; 
    assign memToReg = 0;
    assign bequal = 0; 
    case (opcode)
        R_FORMAT:
            assign rWrite = 1; 
            assign rDst = 1; 
            case (func)
                ADD:
                    assign aluOp = 4'b0010;
                SUB:
                    assign aluOp = 4'b0110;
                OR:
                    assign aluOp = 4'b0001;
                AND:
                    assign aluOp = 4'b0000;
                SLT:
                    assign aluOp = 4'b0111;
                default: aluOp = 4'bx; 
            endcase
        LW:
            assign rWrite = 1; 
            assign aluSrc = 1; 
            assign memToReg = 1; 
            assign aluOp = 4'b0010;
        SW:
            assign rWrite = 1; 
            assign rDst = 1'bx; 
            assign aluSrc = 1; 
            assign memWrite = 1; 
            assign memToReg = 1'bx; 
            assign aluOp = 4'b0010;
        BNE:
            assign rWrite = 1; 
            assign rDst = 1; 
            assign aluOp = 4'b0110;
        BEQ:
            assign rWrite = 1; 
            assign rDst = 1; 
            assign aluOp = 4'b0110;
            assign bequal = 1;
        ADDI:
            assign rWrite = 1; 
            assign aluSrc = 1; 
            assign aluOp = 4'b0010; 
        default: 
    endcase
end


endmodule
