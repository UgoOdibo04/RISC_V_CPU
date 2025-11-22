module control_unit (
  input [6:0] opcode,
  output branch,
  output memread, 
  output memtoreg, 
  output memwrite,
  output alusrc,
  output regwrite
);

  always @(*) begin
    case(opcode)

      7'b0110011 : {alusrc, memtoreg, regwrite, memread, memwrite, branch} <= 6'b001000;
      7'b0000011 : {alusrc, memtoreg, regwrite, memread, memwrite, branch} <= 6'b111100;
      7'b0100011 : {alusrc, memtoreg, regwrite, memread, memwrite, branch} <= 6'b100010;
      7'b0010011 : {alusrc, memtoreg, regwrite, memread, memwrite, branch} <= 6'b101000;
      7'b1100011 : {alusrc, memtoreg, regwrite, memread, memwrite, branch} <= 6'b101000;

    endcase
  end 



endmodule 
