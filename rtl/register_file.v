module register_file(

  //Read Ports
  input [4:0] read_reg1
  input [4:0] read_reg2 
  output [31:0] reg1_value
  output [31:0] reg2_value 

  //Write Ports
  input regwrite
  input [4:0] write_reg
  input [31:0] write_data

  //Resets
  input clock
  input reset
);

  reg [31:0] reg_memory [31:0];
  integer i; 
  //Fill all Registers with 0
  always @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                reg_memory[i] <= 32'b0;
        end
  end 
    else if(regwrite) begin
      reg_memory[write_reg] <= write_data;
    end
  end 
   
  assign reg1_value = reg_memory[read_reg1];
  assign reg2_value = reg_memory[read_reg2];

endmodule 
