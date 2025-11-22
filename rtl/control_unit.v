module control_unit (
  input [6:0] opcode,
  output branch,
  output memread, 
  output memtoreg, 
  output [1:0] aluop,
  output memwrite,
  output alusrc,
  output regwrite
);

  always @(*) begin
    case(opcode)

      7'b0110011 : {alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop} <= 8'b001000_01;
      7'b0000011 : {alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop} <= 8'b111100_00;
      7'b0100011 : {alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop} <= 8'b100010_00;
      7'b0010011 : {alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop} <= 8'b101000_01;
      7'b1100011 : {alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop} <= 8'b101000_01;

    endcase
  end 



endmodule 
