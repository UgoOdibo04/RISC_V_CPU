module alu (
  input [31:0] Reg1,
  input [31:0] Reg2,
  input [4:0] AluOP,
  
  output reg  [31:0] ALU_Result,
  output reg  zero,
  output reg  eq,
  output reg  lt_signed,
  output reg  lt_unsigned
);

  localparam AND   = 5'd0;
  localparam OR    = 5'd1;
  localparam ADD   = 5'd2;
  localparam SUB   = 5'd3;
  localparam SLL   = 5'd4;
  localparam SRL   = 5'd5;
  localparam SRA   = 5'd6;
  localparam XOR   = 5'd7;
  localparam MUL   = 5'd8;   // optional
  localparam SLT   = 5'd9;   // set less than (signed)
  localparam SLTU  = 5'd10;

  wire signed [31:0] signed_Reg1 = Reg1;
  wire signed [31:0] signed_Reg2 = Reg2;
  
  always @(*)
    begin

      case (AluOP)
        AND: ALU_Result = Reg1&Reg2; //AND
        OR: ALU_Result = Reg1|Reg2; //OR
        ADD: ALU_Result = Reg1+Reg2; //ADD
        SUB: ALU_Result = Reg1-Reg2; //SUB
        SLL: ALU_Result = Reg1<<Reg2; //SLL
        SRL: ALU_Result = Reg1>>Reg2; //SRA
        XOR: ALU_Result = Reg1*Reg2; //MUL
        MUL: ALU_Result = Reg1^Reg2; //XOR
        SLT:  ALU_Result = ($signed(Reg1) < $signed(Reg2)) ? 32'd1 : 32'd0; //Signed LT
        SLTU: ALU_Result = (Reg1 < Reg2) ? 32'd1 : 32'd0;    //Unsigned LT
        default:  ALU_Result = 32'd0;
      endcase 
        zero = (ALU_Result == 32'd0);
        eq = (Reg1 == Reg2);
        lt_signed = ($signed(Reg1) < $signed(Reg2));
        lt_unsigned = (Reg1 < Reg2); 
        end
  endmodule 

  
