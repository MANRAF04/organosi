// Define top-level testbench
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Top level has no inputs or outputs
// It only needs to instantiate CPU, Drive the inputs to CPU (clock, reset)
// and monitor the outputs. This is what all testbenches do

`include "library.v"

`timescale 1ns/1ps
`define clock_period 5

module cpu_tb;

reg       clock, reset;    // Clock and reset signals
reg   [4:0] raA, raB, wa;
reg         wen;
output wire   [31:0] wd;
reg [31:0] wd_helper;
wire  [31:0] rdA, rdB;
integer i;
wire zero;
reg [3:0] op;


// Instantiate regfile module
RegFile regs(clock, reset, raA, raB, wa, wen, wd_helper, rdA, rdB);

// YOU ALSO NEED TO INSTATIATE THE ALU HERE 
ALU #(32) alu(wd, zero, rdA, rdB, op);



initial begin  // Ta statements apo ayto to begin mexri to "end" einai seiriaka

   // for (i = 0; i < 32; i = i + 1) begin
   //    $monitor("array[%d] = %h", i, regs.mem[i]);
   // end

  // Initialize the module 
   clock = 1'b0;       
   reset = 1'b0;  // Apply reset for a few cycles
   #(4.25*`clock_period) reset = 1'b1;
   

   // Force initialization of the Register File
   for (i = 0; i < 32; i = i+1)
      regs.mem[i] = i;   // Note that always R0 = 0 in MIPS 

      
  // Now apply some inputs. 
  // You SHOULD EXTEND this part of the code with extra inputs
   raA = 32'h1; raB = 32'h13; 
   #(2*`clock_period) raA = 32'hA; raB = 32'h1F; 
   #(2*`clock_period) wa = 32'h0A; wd_helper = 32'hAA; wen = 1'b1;
   #(4 *`clock_period) $finish;

end 

initial $monitor("time(%0.2t): R: %h clk: %h rdA = %h, wd = %h, wd_helper: %h",
$time, reset, clock, rdA, wd, wd_helper);



// Generate clock by inverting the signal every half of clock period
always 
   #(`clock_period / 2) clock = ~clock;  
   
endmodule
