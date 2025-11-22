module mem_mux(
  input [31:0] read_data, ALU_Result
  input control_signal
  output [31:0] mux_out

);
  assign mux_out = (control_signal == 1'b0) ? read_data : ALU_Result;
  

endmodule
