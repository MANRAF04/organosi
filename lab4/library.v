  
`timescale 1ns/1ps




// ALU Module. Inputs: inA, inB. Output: out. 
// Operations: bitwise and (op = 0)
//             bitwise or  (op = 1)
//             addition (op = 2)
//             subtraction (op = 6)
//             slt  (op = 7)
//             nor (op = 12)
module ALU (out, zero, inA, inB, op);
  parameter N = 8;
  output [N-1:0] out;
  output zero;
  input  [N-1:0] inA, inB;
  input    [3:0] op;

  reg    [N-1:0] result;
 // PLACE YOUR VERILOG CODE HERE
  always @* begin
    case (op)
      4'b0000: // bitwise and
        result = inA & inB;
      4'b0001: // bitwise or
        result = inA | inB;
      4'b0010: // addition
        result = inA + inB;
      4'b0110: // subtraction
        result = inA - inB;
      4'b0111: // slt (set if less than)
        result = (inA < inB) ? 1 : 0;
      4'b1100: // nor
        result = ~(inA | inB);
      default: // Default case
        result = 1;
    endcase

  end
  // Zero flag
  assign zero = (result == 0) ? 1 : 0;

  assign out = result;
endmodule



// Register File Module. Read ports: address raA, data rdA
//                            address raB, data rdB
//                Write port: address wa, data wd, enable wen.
// module RegFile (clock, reset, raA, raB, wa, wen, wd, rdA, rdB);

 // PLACE YOUR VERILOG CODE HERE
 // Remember that the register file should be written at the negative edge of the input clock 

// endmodule
