module alusrc_mux (
    input  wire [31:0] register2,
    input  wire [31:0] immediate,
    input  wire        control_signal,
    output wire [31:0] mux_out
);

    // ALUSrc = 1 → use immediate
    // ALUSrc = 0 → use rs2_value
    assign mux_out = (control_signal == 1'b1) ? immediate : register2;

endmodule
