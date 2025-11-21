module instruction_fetch (
  input              clock,
  input              reset,
  input              pc_source,
  input  [31:0]      branch_target,
  output [31:0]      pc_output,
  output [31:0]      instruction_output
); 
  
  wire [31:0] next_pc;
  wire [31:0] pc_plus4;
  
  // PC + 4 adder
  assign pc_plus4 = pc_output + 32'd4;  
  
  // PC MUX: select between branch target or PC+4
  assign next_pc = pc_source ? branch_target : pc_plus4;
  
  // Program Counter register
  pc_reg PC (
    .clk(clock),              
    .reset(reset),
    .next_pc(next_pc),
    .pc(pc_output)
  );
  
  // Instruction memory
  imem IMEM (
    .address(pc_output),
    .instruction(instruction_output)  
  );
  
endmodule
