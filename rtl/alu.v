module alu (
  input [31:0] Reg1,
  input [31:0] Reg2,
  input [3:0] AluOP,
  output reg [31:0] ALU_Result, 
  output reg zero_flag 
);

  always @(*)
    begin

      case (AluOP)
        4'b0000: ALU_Result = Reg1&Reg2;
        4'b0001: ALU_Result = Reg1|Reg2;
        4'b0010: ALU_Result = Reg1+Reg2;
        4'b0100: ALU_Result = Reg1-Reg2;
        4'b0011: ALU_Result = Reg1<<Reg2;
        4'b0101: ALU_Result = Reg1>>Reg2;
        4'b0110: ALU_Result = Reg1*Regs;
        4'b0111: ALU_Result = Reg1^Reg2;
        4'b1000: begin
          if(Reg1<Reg2)
            ALU_Result = 1; 
          else
            ALU_Result = 0;

          endcase 

          if(ALU_Result == 0)
            zero_flag = 1;
          else 
            zero_flag = 0;
        end
  endmodule 

  
