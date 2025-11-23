module branch_predictor #(
    parameter INDEX_BITS = 10
)(
    input  wire             clk,
    input  wire             reset,

    // Lookup (IF stage)
    input  wire [31:0]      pc_if,
    output wire             predicted_taken,
    output wire             btb_hit,
    output wire [31:0]      predicted_target,

    // Update (on branch resolution)
    input  wire             update_en,     // 1 when updating predictor and BTB
    input  wire [31:0]      update_pc,     // branch PC resolved
    input  wire             update_taken,  // actual outcome
    input  wire [31:0]      update_target  // branch target (valid even if not taken)
);

    // instantiate BTB
    btb #(.INDEX_BITS(INDEX_BITS)) BTB0 (
        .clk(clk),
        .reset(reset),
        .pc(pc_if),
        .hit(btb_hit),
        .target_out(predicted_target),
        .update_en(update_en),
        .update_pc(update_pc),
        .update_target(update_target),
        .update_valid(update_taken) // set BTB entry valid only when branch was taken
    );

    // instantiate bimodal predictor
    bimodal_predictor #(.INDEX_BITS(INDEX_BITS)) PRED0 (
        .clk(clk),
        .reset(reset),
        .pc(pc_if),
        .predict_taken(predicted_taken),
        .update_en(update_en),
        .update_pc(update_pc),
        .update_taken(update_taken)
    );

endmodule
