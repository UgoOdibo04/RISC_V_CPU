module alusrc_mux(
  input [31:0] register2, immediate
  input control_signal
  output [31:0] mux_out

);
  assign mux_out = (control_signal == 1'b1) ? register2 : immediate;
  

endmodule
