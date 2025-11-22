module pc_mux(
    input  wire [31:0] branch_target,
    input  wire [31:0] pc_plus4,
    input  wire        control_signal,  // branch_taken
    output wire [31:0] mux_out
);

    assign mux_out = (control_signal == 1'b1) ? branch_target : pc_plus4;         // normal sequential PC

endmodule
