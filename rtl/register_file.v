module register_file(
  input [4:0] read_reg1
  input [4:0] read_reg2 

  input [4:0] write_reg
  input [31:0] write_data

  output [31:0] reg1_value
  output [31:0] reg2_value 
  
  input clock
  input regwrite
  input reset
);

   reg [31:0] reg_memory [31:0]
  
