module alu_control (
  // Opcode and Funcs
  input  [6:0] opcode,
  input  [2:0] func3,
  input  [6:0] func7,
  // Alu Control Output 
  output reg [4:0] alu_control,
  output reg       regwrite
);

  // ALU operation definitions
  localparam AND  = 5'd0;
  localparam OR   = 5'd1;
  localparam ADD  = 5'd2;
  localparam SUB  = 5'd3;
  localparam SLL  = 5'd4;
  localparam SRL  = 5'd5;
  localparam SRA  = 5'd6;
  localparam XOR  = 5'd7;
  localparam SLT  = 5'd9;
  localparam SLTU = 5'd10;
  
  always @(*) begin 
    // Default values
    alu_control = ADD;
    regwrite    = 1'b0;
    
    case (opcode)
      // R-Type Instructions 
      7'b0110011: begin 
        regwrite = 1'b1;
        case (func3)
          3'b000: alu_control = (func7 == 7'b0000000) ? ADD : SUB;  // ADD or SUB
          3'b001: alu_control = SLL;
          3'b010: alu_control = SLT;
          3'b011: alu_control = SLTU;
          3'b100: alu_control = XOR;
          3'b101: alu_control = (func7 == 7'b0000000) ? SRL : SRA;
          3'b110: alu_control = OR;
          3'b111: alu_control = AND;
        endcase
      end
           
      // I-Type Instructions
      7'b0010011: begin
        regwrite = 1'b1;
        case (func3)
          3'b000: alu_control = ADD;
          3'b010: alu_control = SLT;
          3'b011: alu_control = SLTU;
          3'b100: alu_control = XOR;
          3'b110: alu_control = OR;
          3'b111: alu_control = AND;
          3'b001: alu_control = SLL;
          3'b101: alu_control = (func7 == 7'b0000000) ? SRL : SRA;  // Note: was SRR, should be SRA
        endcase
      end
      
      // Load Instruction 
      7'b0000011: begin
        regwrite    = 1'b1;
        alu_control = ADD;
      end 
      
      // Store Instruction 
      7'b0100011: begin 
        regwrite    = 1'b0;
        alu_control = ADD;
      end 
      
      // Branch Instructions
      7'b1100011: begin
        regwrite = 1'b0;
        case (func3)
          3'b000: alu_control = SUB;   // BEQ
          3'b001: alu_control = SUB;   // BNE
          3'b100: alu_control = SLT;   // BLT
          3'b101: alu_control = SLT;   // BGE (using flags)
          3'b110: alu_control = SLTU;  // BLTU
          3'b111: alu_control = SLTU;  // BGEU
        endcase
      end 
      
      // JAL (Note: duplicate opcode with JALR below - should be 7'b1100111 for JALR)
      7'b1101111: begin 
        regwrite    = 1'b1;
        alu_control = ADD;  
      end

      //Jalr
      7'b1100111: begin
        regwrite    = 1'b1;
        alu_control = ADD;\
      end 
      
      // LUI
      7'b0110111: begin 
        regwrite    = 1'b1;
        alu_control = ADD; 
      end
      
      // ECALL/EBREAK
      7'b1110011: begin 
        regwrite    = 1'b1;
        alu_control = ADD;  
      end 
      
    endcase
  end
  
endmodule
