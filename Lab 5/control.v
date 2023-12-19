`include "constants.vh"
// Module to control the data path. 
//                          Input: op, func of the inpstruction
//                          Output: all the control signals needed 
module ControlUnit(
           input [5:0] opcode, 
           input [5:0] func,
           output reg [3:0] aluOp,
           output reg rWrite,
           output reg rDst,
           output reg aluSrc,
           output reg branch,
           output reg memWrite,
           output reg memRead,
           output reg memToReg
           );
		   
// Write the FSM code here
always @(*) begin
    rWrite = 0; 
    rDst = 0; 
    aluSrc = 0; 
    branch = 0; 
    memWrite = 0; 
    memToReg = 0;
    memRead = 0;

    case (opcode)
        (`R_FORMAT): begin 
            rWrite = 1; 
            rDst = 1; 
            case (func)
                (`ADD):
                    aluOp = 4'b0010;
                (`SUB):
                    aluOp = 4'b0110;
                (`OR):
                    aluOp = 4'b0001;
                (`AND):
                    aluOp = 4'b0000;
                (`SLT):
                    aluOp = 4'b0111;
                default: aluOp = 4'bx; 
            endcase
        end
        (`LW): begin
            rWrite = 1; 
            aluSrc = 1; 
            memToReg = 1; 
            memRead = 1;
            aluOp = 4'b0010;
        end
        (`SW): begin
            rDst = 1'bx; 
            aluSrc = 1; 
            memWrite = 1; 
            memToReg = 1'bx; 
            aluOp = 4'b0010;
        end
        (`BNE): begin
            rWrite = 1; 
            rDst = 1'bx;
            branch = 1'b1;
            memToReg = 1'bx;
            aluOp = 4'b0110;
        end
        (`BEQ): begin
            rWrite = 1; 
            rDst = 1'bx;
            branch = 1'b1;
            memToReg = 1'bx; 
            aluOp = 4'b0110;
        end
        (`ADDI): begin
            rWrite = 1; 
            aluSrc = 1; 
            aluOp = 4'b0010;
        end 
        default:
            aluOp = 4'bx;
    endcase
end

endmodule