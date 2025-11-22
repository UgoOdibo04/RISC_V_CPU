module pc_mux(
  input [31:0] sum_branch, pc,
  input control_signal,
  output [31:0] mux_out

);
  assign mux_out = (control_signal == 1'b1) ? sum_branch : pc;
  

endmodule
