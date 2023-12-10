// This file contains library modules to be used in your design. 
`timescale 1ns/1ps

// Small ALU. 
//     Inputs: inA, inB, op. 
//     Output: out, zero
// Operations: bitwise and (op = 0)
//             bitwise or  (op = 1)
//             addition (op = 2)
//             subtraction (op = 6)
//             slt  (op = 7)
//             nor (op = 12)

module ALU  #(parameter N = 8)(out, zero, inA, inB, op);

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


// Register File. Input ports: address raA, data rdA
//                            address raB, data rdB
//                Write port: address wa, data wd, enable wen.

module RegFile (clock, reset, raA, raB, wa, wen, wd, rdA, rdB);

  input clock;
  input reset;
  input [4:0] raA, raB;
  input [4:0] wa;
  input wen;
  input [31:0] wd;
  output  [31:0] rdA, rdB;
  reg [31:0] data [0: 31];  // array of 32 32-bit registers
  integer i;


  always @(negedge clock or negedge reset) begin
    if (!reset) begin     // RESET data to 0
        for (i = 0; i < 32; i = i + 1) begin
          data[i] <= 0;
        end
      end

    else begin
      if (wen) begin
        data[wa] <= wd;    // Write the data to the needed data[wa] register
      end
    end
  end

  // Assign the 2 reading outputs from the array
  assign rdA = data[raA];
  assign rdB = data[raB];

endmodule


// Memory (active 1024 words, from 10 address ).
// Read : enable ren, address addr, data dout
// Write: enable wen, address addr, data din.
module Memory (clock, reset, ren, wen, addr, din, dout);

  input clock, reset;
  input         ren, wen;
  input  [31:0] addr, din;
  output [31:0] dout;
  reg [31:0] data[4095:0];
  wire [31:0] dout;


  always @(ren or wen)   // It does not correspond to hardware. Just for error detection
    if (ren & wen)
      $display ("\nMemory ERROR (time %0d): ren and wen both active!\n", $time);


  always @(posedge ren or posedge wen) begin // It does not correspond to hardware. Just for error detection
    if (addr[31:10] != 0)
      $display("Memory WARNING (time %0d): address msbs are not zero\n", $time);
  end  

  assign dout = ((wen==1'b0) && (ren==1'b1)) ? data[addr[9:0]] : 32'bx;
    
  always @(negedge clock)
   begin
    if ((wen == 1'b1) && (ren==1'b0) && reset)
        data[addr[9:0]] = din;
   end

endmodule