module pcplus4 (
  input [31:0] fromPC,
  output [31:0] nextPC
);

assign nextPC = 4 + fromPC;

endmodule 
