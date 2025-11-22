module mem_mux (
    input  wire [31:0] read_data,
    input  wire [31:0] ALU_Result,
    input  wire        control_signal,   // mem_to_reg
    output wire [31:0] mux_out
);

    // mem_to_reg:
    //   0 → ALU result
    //   1 → loaded data
    assign mux_out = (control_signal == 1'b1) ? read_data : ALU_Result;

endmodule
