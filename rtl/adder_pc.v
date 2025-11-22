module adder_pc(input1, input2, sumout);

  input [31:0] input1, input2l;
  output [31:0] sumout;



  assign sumout = input1 + input2;

endmodule
