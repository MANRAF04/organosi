`include "constants.h"
`timescale 1ns/1ps

/************** Main control in ID pipe stage  *************/
module control_main(output reg RegDst,
                output reg PCSrc,  
                output reg MemRead,
                output reg MemWrite,  
                output reg MemToReg,  
                output reg ALUSrc, 
                output reg RegWrite,
                output reg Jump,  
                output reg [1:0] ALUcntrl,
                input Branch_Zero,  
                input [5:0] opcode);

  always @(*) begin
    RegDst = 1'b0;
    MemRead = 1'b0;
    MemWrite = 1'b0;
    MemToReg = 1'b0;
    ALUSrc = 1'b0;
    RegWrite = 1'b0; 
    PCSrc =   1'b0;   
    Jump = 1'b0;  
    ALUcntrl  = 2'b00;
    
     case (opcode)
      `R_FORMAT: 
      /* TO FILL IN: The control signal values in each and every case */
          begin 
            RegDst = 1'b1;
            RegWrite = 1'b1; 
            ALUcntrl  = 2'b10;             
          end
       `LW :   
           begin 
            MemRead = 1'b1;
            MemToReg = 1'b1;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
           end
        `SW :   
           begin 
            RegDst = 1'bx;
            ALUSrc = 1'b1;
            MemWrite = 1'b1;
            MemToReg = 1'bx;
           end
       `BEQ:  
           begin 
            RegWrite = 1'b1;
            RegDst = 1'bx;
            PCSrc = (Branch_Zero) ? 1'b1 : 1'b0;
            MemToReg = 1'bx;
            ALUcntrl = 2'b01;
           end
        `BNE:
          begin
            RegWrite = 1'b1;
            RegDst = 1'bx;
            PCSrc = (!Branch_Zero) ? 1'b1 : 1'b0;
            MemToReg = 1'bx;
            ALUcntrl = 2'b01;
          end
        `ADDI:
          begin
            RegWrite = 1'b1;
            ALUSrc = 1'b1;
            ALUcntrl = 2'b00;
          end
        `J:
          begin
            Jump = 1'b1;
            RegDst = 1'bx;
            ALUSrc = 1'bx;
            PCSrc = 1'bx;
            MemToReg = 1'bx;
            ALUcntrl = 2'bx;
          end
       default:
           begin
            MemToReg = 1'b0;
           end
      endcase
    end // always
endmodule


/**************** Module for Bypass Detection in EX pipe stage goes here  *********/
// TO FILL IN: Module details 
// endmodule          
module forwarding_unit (
  output reg [1:0] fA,
  output reg [1:0] fB,
  input EXMEM_RegWrite,
  input [4:0] EXMEM_instr_rd,
  input MEMWB_RegWrite,
  input [4:0] MEMWB_instr_rd,
  input [4:0] IDEX_instr_rt,
  input [4:0] IDEX_instr_rs
);

always @(*) begin

    fA = 2'b00;
    fB = 2'b00;

    //EXMEM
    if (EXMEM_RegWrite == 1 && EXMEM_instr_rd != 0 && (EXMEM_instr_rd == IDEX_instr_rs)) begin
        fA = 2'b10;
    end
    if (EXMEM_RegWrite == 1 && EXMEM_instr_rd != 0 && EXMEM_instr_rd == IDEX_instr_rt) begin
        fB = 2'b10;
    end

    //MEMWB
    if (MEMWB_RegWrite == 1 && MEMWB_instr_rd != 0 && MEMWB_instr_rd == IDEX_instr_rs && (EXMEM_instr_rd != IDEX_instr_rs || EXMEM_RegWrite == 0)) begin
        fA = 2'b01;
    end
    if (MEMWB_RegWrite == 1 && MEMWB_instr_rd != 0 && MEMWB_instr_rd == IDEX_instr_rt && (EXMEM_instr_rd != IDEX_instr_rt || EXMEM_RegWrite == 0)) begin
        fB = 2'b01;
    end
end

endmodule


/**************** Module for Stall Detection in ID pipe stage goes here  *********/
// TO FILL IN: Module details 
module hazard_unit (
    output reg IFID_write,
    output reg PC_write,
    output reg bubble_idex,
    input PCSrc,
    input IDEX_MemRead,
    input [4:0] IDEX_instr_rt,
    input [4:0] instr_rs,
    input [4:0] instr_rt);

always @(*) begin

  bubble_idex = 0;
  IFID_write = 1;
  PC_write = 1;

  if (PCSrc) begin
    bubble_idex = 1;
    IFID_write = 0;
    PC_write = 0;
  end

  if ((IDEX_MemRead) && ((IDEX_instr_rt == instr_rs) || (IDEX_instr_rt == instr_rt))) begin
    bubble_idex = 1;
    IFID_write = 0;
    PC_write = 0;
  end

end

endmodule

/************** control for ALU control in EX pipe stage  *************/
module control_alu(output reg [3:0] ALUOp,                  
               output reg ALUSrc_Shift, 
               input [1:0] ALUcntrl,
               input [5:0] func);

  always @(ALUcntrl or func)  
    begin
      ALUSrc_Shift = 1'b0;
      case (ALUcntrl)
        2'b10: 
           begin
             case (func)
              6'b100000: ALUOp  = 4'b0010; // add
              6'b100010: ALUOp = 4'b0110; // sub
              6'b100100: ALUOp = 4'b0000; // and
              6'b100101: ALUOp = 4'b0001; // or
              6'b100110: ALUOp = 4'b0100; // xor
              6'b100111: ALUOp = 4'b1100; // nor
              6'b101010: ALUOp = 4'b0111; // slt
              6'b000000: begin // sll
                ALUOp = 4'b1000; 
                ALUSrc_Shift = 1'b1;
              end 
              6'b000100: begin // sllv
                ALUOp = 4'b1000; 
              end 
              default: ALUOp = 4'b0000;       
             endcase 
          end   
        2'b00: 
              ALUOp  = 4'b0010; // add
        2'b01: 
              ALUOp = 4'b0110; // sub
        default:
              ALUOp = 4'b0000; 
     endcase
    end
endmodule