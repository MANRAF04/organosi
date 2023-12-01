// Define top-level testbench
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Top level has no inputs or outputs
// It only needs to instantiate CPU, Drive the inputs to CPU (clock, reset)
// and monitor the outputs. This is what all testbenches do

`include "library.v"


`timescale 1ns/1ps
`define clock_period 5
// Custom Macro for showcasing the array of registers
`define DISPLAY_ARRAY(arr, j_start, j_end) \
$display("###########################"); \
for (integer j = j_start; j < j_end; j = j + 1) begin \
    $display("array[%02d] = %d", j, arr[j]); \
end



module cpu_tb;

reg       clock, reset;    
reg   [4:0] raA, raB, wa;
reg         wen;
wire  [31:0] wd;
reg [31:0] wd_helper;
wire  [31:0] rdA, rdB;
integer i;
wire zero;
reg [3:0] op;


// Instantiate regfile module
RegFile regs(clock, reset, raA, raB, wa, wen, wd, rdA, rdB);

// YOU ALSO NEED TO INSTATIATE THE ALU HERE 
ALU #(32) alu(wd, zero, rdA, rdB, op);


initial begin  // Ta statements apo ayto to begin mexri to "end" einai seiriaka

   $dumpfile("alu_wave.vcd");       // Waveform Setup
   $dumpvars(0,cpu_tb);

  // Initialize the module 
   clock = 1'b0;       
   reset = 1'b0;  // Apply reset for a few cycles
   #(4*`clock_period) reset = 1'b1;
   

   // Force initialization of the Register File
   for (i = 0; i < 32; i = i+1)
      regs.mem[i] = i;   // Note that always R0 = 0 in MIPS 

      
  // Now apply some inputs. 
   #(2*`clock_period) //Addition
   raA = 5'd11; raB = 5'd2; op = 5'd2; wa = 5'd1; wen = 1'b1;
   
   #(`clock_period)`DISPLAY_ARRAY(regs.mem, 0, 32);

   #(2`clock_period) //Less than
   raA = 5'd7; raB = 5'd0; op = 4'd7; wa = 5'd2; wen = 1'b1;

   #(`clock_period)`DISPLAY_ARRAY(regs.mem, 0, 32);

   #(2`clock_period) //Bitwise AND
   raA = 5'd7; raB = 5'd0; op = 4'd0; wa = 5'd5; wen = 1'b1;

   #(`clock_period)`DISPLAY_ARRAY(regs.mem, 0, 32);

   #(2`clock_period) //Bitwise OR
   raA = 5'd8; raB = 5'd16; op = 4'd1; wa = 5'd31; wen = 1'b1;

   #(2`clock_period) //Less than
   raA = 5'd0; raB = 5'd7; op = 4'd7;wa = 5'd3; wen = 1'b1; // for test

   #(2`clock_period) //Non implemented operation
   raA = 5'd7; raB = 5'd0; op = 4'd5; wa = 5'd16; wen = 1'b1;

   #(2`clock_period) //Less than
   raA = 5'd7; raB = 5'd0; op = 4'd7; wa = 5'd0; wen = 1'b1;

   #(2`clock_period) //Bitwise NOR
   raA = 5'd23; raB = 5'd17; op = 4'd12; wa = 5'd4; wen = 1'b1;

   #(2`clock_period) //Non implemented operation
   raA = 5'd23; raB = 5'd17; op = 4'd13; wa = 5'd9; wen = 1'b1;

   #(2`clock_period) //Addition with x
   raA = 5'd9; raB = 5'd17; op = 4'd2; wa = 5'd25; wen = 1'b1;

   #(2`clock_period) //Addition with overflow
   raA = 5'd4; raB = 5'd4; op = 4'd2; wa = 5'd28; wen = 1'b1;

   #(`clock_period)`DISPLAY_ARRAY(regs.mem, 0, 32);

   #(2`clock_period) reset = 1'b0; wen = 1'b1;

   #(`clock_period)`DISPLAY_ARRAY(regs.mem, 0, 32);

   #(20 *`clock_period) $finish;

end 

// initial $monitor("time(%0.2t): R: %h clk: %h rdA = %h, wd = %h",
// $time, reset, clock, rdA, wd);

// Generate clock by inverting the signal every half of clock period
always 
   #(`clock_period / 2) clock = ~clock;  
   
endmodule 