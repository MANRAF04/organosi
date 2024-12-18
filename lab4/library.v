`timescale 1ns/1ps


// ALU Module. Inputs: inA, inB. Output: out. 
// Operations: bitwise and (op = 0)
//             bitwise or  (op = 1)
//             addition (op = 2)
//             subtraction (op = 6)
//             slt  (op = 7)
//             nor (op = 12)


module ALU   #(parameter N = 8)(out, zero, inA, inB, op);

  output [N-1:0] out;
  output zero;
  input  [N-1:0] inA, inB;
  input    [3:0] op;
  reg    [N-1:0] result;


  always @(*) begin
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
        result = {N{1'bx}};     // Don't care x result
    endcase

  end
  // Zero flag
  assign zero = (result == 0) ? 1 : 0;

  // Get the result as an output
  assign out = result;
endmodule



// Register File Module. Read ports: address raA, data rdA
//                            address raB, data rdB
//                Write port: address wa, data wd, enable wen.


module RegFile (clk, reset, raA, raB, wa, wen, wd, rdA, rdB);

  input clk;
  input reset;
  input [4:0] raA, raB;
  input [4:0] wa;
  input wen;
  input [31:0] wd;
  output  [31:0] rdA, rdB;
  reg [31:0] mem [0: 31];  // array of 32 32-bit registers
  integer i;


  always @(negedge clk or negedge reset) begin
    if (!reset) begin     // RESET mem to 0
        for (i = 0; i < 32; i = i + 1) begin
          mem[i] <= 0;
        end
      end

    else begin
      if (wen) begin
        mem[wa] <= wd;    // Write the data to the needed mem[wa] register
      end
    end
  end

  // Assign the 2 reading outputs from the array
  assign rdA = mem[raA];
  assign rdB = mem[raB];

endmodule