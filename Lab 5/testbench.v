// Define top-level testbench
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Top level has no inputs or outputs
// It only needs to instantiate CPU, Drive the inputs to CPU (clock, reset)
// and monitor the outputs. This is what all testbenches do

`include "constants.vh"    // Header file with opcodes
`include "cpu.v"
`timescale 1ns/1ps

module cpu_tb;

integer   i;
reg      clock, reset;    // Clock and reset signals

// Instantiate CPU here with name cpu0
CPU cpu0(clock, reset);

// Initialization and signal generation
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
always begin
    #(`clock_period / 2) clock = ~clock;
end


// Generate clock and reset signal here

  // Initialize Register File with initial values. 
  // cpu0 is the name of the cpu instance
  // cpu_regs is the name of the register file instance in the CPU verilog file 
  // data[] is the register file array 
initial begin

  $dumpfile("cpu_tb.vcd");       // Waveform Setup
  $dumpvars(0,cpu_tb);

  for (i = 0; i < 32; i++)
    $dumpvars(2, cpu0.cpu_IMem.data[i]);
  for (i = 0; i < 32; i++)
    $dumpvars(2, cpu0.cpu_regs.data[i]);
  for (i = 0; i < 32; i++)
    $dumpvars(2, cpu0.cpu_DMem.data[i]);


  clock = 1'b0;

  // Initialize Instruction Memory. You have to develop "program.hex" as a text file 
  // which containsthe instruction opcodes as 32-bit hexadecimal values.
  

  // Edw, to "program.hex" einai ena arxeio pou prepei na brisketai sto 
  // directory pou trexete th Verilog kai na einai ths morfhs:
  
  // @0    00000000
  // @1    20100009
  // @2    00000000
  // @3    00000000
  // ...
  
  // H aristerh sthlh, meta to @, exei th dieythynsh ths mnhmhs (hex),
  // kai h deksia sthlh ta dedomena sth dieythynsh ayth (pali hex).
  // Sto paradeigma pio panw, oi lekseis stis dieythynseis 0, 8 kai 12
  // einai 0, kai sth dieythynsh 4 exei thn timh 32'h20100009. An o PC
  // diabasei thn dieythynsh 4, h timh ekei exei thn entolh
  //   addi $16 <- $0 + 9

  // To deytero orisma ths $readmemh einai pou akribws brisketai h mnhmh
  // pou tha arxikopoihthei. Sto paradeigma, to "dat0" einai to onoma pou
  // dwsame sto instance tou datapath. To "mem" einai to onoma pou exei
  // to instance ths mnhmhs MESA sto datapath, kai to "data" einai to 
  // onoma pou exei to pragmatiko array ths mhnhs mesa sto module ths.
  // An exete dwsei diaforetika onomata, allakste thn $readmemh.

  // Enallaktika, an sas boleyei perissotero, yparxei h entolh $readmemb
  // me thn akribws idia syntaksh. H aristerh sthlh tou arxeiou exei
  // thn idia morfh (dieythynseis se hex), alla h deksia sthlh exei
  // ta dedomena sto dyadiko. Etsi h add mporouse na einai:

  // @4    00100000000100000000000000001001

  // ... h kai akoma kalytera:
  
  // @4    001000_00000_10000_0000000000001001

  // (h Verilog epitrepei diaxwristika underscores).

  $readmemh("program.hex", cpu0.cpu_IMem.data, 31, 0);
  reset = 1'b0;
  #(0.75*`clock_period) reset = 1'b1;
  for (i = 0; i < 32; i = i+1)
    cpu0.cpu_regs.data[i] = i;   // Note that R0 = 0 in MIPS 
  

  // Termatismos ekteleshs:
  #(20 * `clock_period)  reset = 1'b0;
  #(6 * `clock_period)  $finish;

end  // initial 

endmodule
