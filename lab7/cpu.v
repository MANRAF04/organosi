/***********************************************************************************************/
/*********************************  MIPS 5-stage pipeline implementation ***********************/
/***********************************************************************************************/

`timescale 1ns/1ps

module cpu(input clock, input reset);
 reg [31:0] PC;
 wire [31:0] PC_jump; 
 reg [31:0] IFID_PC, IDEX_PC;
 reg [31:0] IFID_instr;
 reg [31:0] IDEX_rdA, IDEX_rdB, IDEX_signExtend, IDEX_Shamt;
 reg [4:0]  IDEX_instr_rt, IDEX_instr_rs, IDEX_instr_rd;                            
 reg        IDEX_RegDst, IDEX_ALUSrc, IDEX_ALUSrc_Shift, IDEX_Branch, IDEX_Branch_on_Zero;
 reg [1:0]  IDEX_ALUcntrl;
 reg        IDEX_MemRead, IDEX_MemWrite; 
 reg        IDEX_MemToReg, IDEX_RegWrite;                
 reg [4:0]  EXMEM_RegWriteAddr; 
 reg [31:0] EXMEM_ALUOut;
 reg        EXMEM_Zero;
 reg [31:0] EXMEM_MemWriteData, EXMEM_PC_label;
 reg        EXMEM_MemRead, EXMEM_MemWrite, EXMEM_RegWrite, EXMEM_MemToReg, EXMEM_Branch, EXMEM_Branch_on_Zero;
 reg [31:0] MEMWB_DMemOut;
 reg [4:0]  MEMWB_RegWriteAddr; 
 reg [31:0] MEMWB_ALUOut;
 reg        MEMWB_MemToReg, MEMWB_RegWrite;               
 reg        Iren = 1'b1,Iwen = 1'b0;
 wire [31:0] din,mdout, signExtend_Shift, PC_label, PC_no_jump, comp_inA, comp_inB, forward_reg_data;
 wire [31:0] instr, MemWriteData, ALUInA, ALUInB, ALUOut, rdA, rdB, signExtend, DMemOut, wRegData, PCIncr, shamt;
 wire Zero, Zero4Branch, RegDst, MemRead, MemWrite, MemToReg, ALUSrc, RegWrite, Jump, PCSrc, Branch, Branch_on_Zero, PC_write, IFID_write, bubble_idex, hazard_signal, ALUSrc_Shift;
 wire [5:0] opcode, func; 
 reg [5:0] IDEX_opcode, EXMEM_opcode;
 wire [4:0] instr_rs, instr_rt, instr_rd, RegWriteAddr;
 wire [3:0] ALUOp;
 wire [1:0] ALUcntrl, fA, fB;
 // wire fC, fD;
 wire [15:0] imm;

 
 

/***************** Instruction Fetch Unit (IF)  ****************/
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)     
       PC <= -1;     
    else if (PC == -1)
       PC <= 0;
    else if (PC_write == 1'b1)
       PC <= (Jump) ? (PC_jump) : (PC_no_jump);
  end
  
  // IFID pipeline register
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)     
      begin
       IFID_PC <= 32'b0;    
       IFID_instr <= 32'b0;
    end 
    else if (IFID_write == 1'b1) 
      begin
       IFID_PC <= PC + 4;
       IFID_instr <= (instr);
    end
  end

assign PC_no_jump = (PCSrc) ? (EXMEM_PC_label) : (PC + 4);
  
// TO FILL IN: Instantiate the Instruction Memory here 
Memory cpu_IMem(clock,reset,Iren,Iwen,{2'b0, PC[31:2]},din,instr);  
  

/***************** Instruction Decode Unit (ID)  ****************/
assign opcode = IFID_instr[31:26];
assign func = IFID_instr[5:0];
assign instr_rs = IFID_instr[25:21];
assign instr_rt = IFID_instr[20:16];
assign instr_rd = IFID_instr[15:11];
assign imm = IFID_instr[15:0];
assign signExtend = {{16{imm[15]}}, imm};
assign shamt = {{27{1'b0}}, IFID_instr[10:6]};   // shamt should be a 32-bit unsigned int 
assign PC_jump = {IFID_PC[31:28], (IFID_instr[25:0] << 2)}; // for jump instructions

//assign comp_inA = (fC) ? (EXMEM_ALUOut) : (rdA);
//assign comp_inB = (fD) ? (EXMEM_ALUOut) : (rdB);


// Register file
RegFile cpu_regs(clock, reset, instr_rs, instr_rt, MEMWB_RegWriteAddr, MEMWB_RegWrite, wRegData, rdA, rdB);

// ID Forward Unit
//ID_forwarding_unit cpu_ifu (fC, fD, PCSrc, IDEX_instr_rd, instr_rt, instr_rs); // SHOULD BE EXMEM_instr_rd !!

  // IDEX pipeline register
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)
      begin
       IDEX_PC <= 1'b0;
       IDEX_rdA <= 32'b0;    
       IDEX_rdB <= 32'b0;
       IDEX_signExtend <= 32'b0;
       IDEX_instr_rd <= 5'b0;
       IDEX_instr_rs <= 5'b0;
       IDEX_instr_rt <= 5'b0;
       IDEX_RegDst <= 1'b0;
       IDEX_ALUcntrl <= 2'b0;
       IDEX_ALUSrc <= 1'b0;
       IDEX_MemRead <= 1'b0;
       IDEX_MemWrite <= 1'b0;
       IDEX_MemToReg <= 1'b0;                  
       IDEX_RegWrite <= 1'b0;
       IDEX_ALUSrc_Shift <= 1'b0;
       IDEX_Shamt <= 1'b0;
       IDEX_Branch <= 1'b0;
       IDEX_Branch_on_Zero <= 1'b0;
       IDEX_opcode <= 1'b0;
    end
    else if (Jump || bubble_idex || hazard_signal) begin
      IDEX_RegDst <= 1'b0;
      IDEX_ALUcntrl <= 2'b00;
      IDEX_ALUSrc <= 1'b0;
      IDEX_ALUSrc_Shift <= 1'b0;
      IDEX_MemRead <= 1'b0;
      IDEX_MemWrite <= 1'b0;
      IDEX_MemToReg <= 1'b0;
      IDEX_RegWrite <= 1'b0;
      IDEX_Branch <= 1'b0;
      IDEX_Branch_on_Zero <= 1'b0;
    end 
    else 
      begin
       IDEX_PC <= IFID_PC;
       IDEX_rdA <= rdA;
       IDEX_rdB <= rdB;
       IDEX_signExtend <= signExtend;
       IDEX_instr_rd <= instr_rd;
       IDEX_instr_rs <= instr_rs;
       IDEX_instr_rt <= instr_rt;
       IDEX_Shamt <= shamt;
       IDEX_ALUSrc_Shift <= ALUSrc_Shift; //EX
       IDEX_RegDst <= RegDst;             //EX
       IDEX_ALUcntrl <= ALUcntrl;         //EX
       IDEX_ALUSrc <= ALUSrc;             //EX
       IDEX_Branch <= Branch;           //MEM
       IDEX_Branch_on_Zero <= Branch_on_Zero;
       IDEX_opcode <= opcode;
       IDEX_MemRead <= MemRead;           //MEM
       IDEX_MemWrite <= MemWrite;         //MEM
       IDEX_MemToReg <= MemToReg;         //WB             
       IDEX_RegWrite <= RegWrite;         //WB
    end
  end

// Main Control Unit 
control_main control_main (RegDst,
                  MemRead,
                  MemWrite,
                  MemToReg,
                  ALUSrc,
                  RegWrite,
                  Jump,
                  Branch,
                  Branch_on_Zero,
                  bubble_idex,
                  ALUcntrl,
                  opcode);
                  
// TO FILL IN: Instantiation of Control Unit that generates stalls
hazard_unit cpu_hu(IFID_write, PC_write, hazard_signal, IDEX_MemRead, IDEX_instr_rt, instr_rs, instr_rt);


                           
/***************** Execution Unit (EX)  ****************/
assign PC_label = (IDEX_signExtend << 2) + (IDEX_PC); 

// ALUSrc_Shift Mux + Forward A Mux
assign ALUInA = (ALUSrc_Shift) ? (IDEX_Shamt) :
                (fA == 2'b00) ? (IDEX_rdA) : 
                (fA == 2'b01) ? (forward_reg_data) : (EXMEM_ALUOut);

// Forward B Mux
assign MemWriteData = (fB == 2'b00) ? (IDEX_rdB) : 
                      (fB == 2'b01) ? (forward_reg_data) : (EXMEM_ALUOut);

// IDEX_AluSrc Mux
assign ALUInB = (IDEX_ALUSrc)  ? (IDEX_signExtend) : (MemWriteData); 


//  ALU
ALU  #(32) cpu_alu(ALUOut, Zero, ALUInA, ALUInB, ALUOp);

assign RegWriteAddr = (IDEX_RegDst==1'b0) ? IDEX_instr_rt : IDEX_instr_rd;

 // EXMEM pipeline register
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)     
      begin
       EXMEM_ALUOut <= 32'b0;    
       EXMEM_RegWriteAddr <= 5'b0;
       EXMEM_MemWriteData <= 32'b0;
       EXMEM_Zero <= 1'b0;
       EXMEM_MemRead <= 1'b0;
       EXMEM_MemWrite <= 1'b0;
       EXMEM_MemToReg <= 1'b0;                  
       EXMEM_RegWrite <= 1'b0;
       EXMEM_PC_label <= 1'b0;
       EXMEM_Branch <= 1'b0;
       EXMEM_Branch_on_Zero <= 1'b0;
       EXMEM_opcode <= 1'b0;
      end 
    else 
      begin
       EXMEM_ALUOut <= ALUOut;    
       EXMEM_RegWriteAddr <= RegWriteAddr;
       EXMEM_MemWriteData <= MemWriteData; 
       EXMEM_Zero <= Zero;
       EXMEM_MemRead <= IDEX_MemRead;   //MEM
       EXMEM_MemWrite <= IDEX_MemWrite; //MEM
       EXMEM_PC_label <= PC_label;      //MEM
       EXMEM_Branch <= IDEX_Branch;     //MEM
       EXMEM_Branch_on_Zero <= IDEX_Branch_on_Zero; //MEM
       EXMEM_opcode <= IDEX_opcode;
       EXMEM_MemToReg <= IDEX_MemToReg; //WB                 
       EXMEM_RegWrite <= IDEX_RegWrite; //WB
      end
  end
  
  // ALU control
  control_alu control_alu(ALUOp, ALUSrc_Shift, IDEX_ALUcntrl, IDEX_signExtend[5:0]);
  
   // TO FILL IN: Instantiation of control logic for Forwarding goes here
  EX_forwarding_unit cpu_efu(fA, fB, EXMEM_RegWrite, EXMEM_RegWriteAddr, MEMWB_RegWrite,
                         MEMWB_RegWriteAddr, IDEX_instr_rt, IDEX_instr_rs);

  
/***************** Memory Unit (MEM)  ****************/  
assign Zero4Branch = (EXMEM_Branch_on_Zero) ? (EXMEM_Zero) : (~(EXMEM_Zero));
assign PCSrc = (EXMEM_Branch) && (EXMEM_Zero ^ EXMEM_opcode[0]);

// Data memory 1KB
// Instantiate the Data Memory here 
Memory cpu_DMem(clock, reset, EXMEM_MemRead, EXMEM_MemWrite, EXMEM_ALUOut, EXMEM_MemWriteData, DMemOut);


// MEMWB pipeline register
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)     
      begin
       MEMWB_DMemOut <= 32'b0;    
       MEMWB_ALUOut <= 32'b0;
       MEMWB_RegWriteAddr <= 5'b0;
       MEMWB_MemToReg <= 1'b0;                  
       MEMWB_RegWrite <= 1'b0;
      end 
    else 
      begin
       MEMWB_DMemOut <= DMemOut;
       MEMWB_ALUOut <= EXMEM_ALUOut;
       MEMWB_RegWriteAddr <= EXMEM_RegWriteAddr;
       MEMWB_MemToReg <= EXMEM_MemToReg;    //WB              
       MEMWB_RegWrite <= EXMEM_RegWrite;    //WB
      end
  end
  

/***************** WriteBack Unit (WB)  ****************/  
// TO FILL IN: Write Back logic 
assign wRegData = (MEMWB_MemToReg) ? (MEMWB_DMemOut) : (MEMWB_ALUOut);
assign forward_reg_data = (MEMWB_MemToReg) ? MEMWB_DMemOut : MEMWB_ALUOut;

endmodule
