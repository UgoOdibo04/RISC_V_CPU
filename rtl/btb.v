module btb #(
    parameter INDEX_BITS = 10,                   // 1024 entries by default
    parameter TAG_BITS = 32 - INDEX_BITS - 2
)(
    input  wire             clk,
    input  wire             reset,

    // Lookup (combinational)
    input  wire [31:0]      pc,           // PC to lookup
    output wire             hit,
    output wire [31:0]      target_out,

    // Update (on branch resolution)
    input  wire             update_en,    // when 1, write BTB entry
    input  wire [31:0]      update_pc,
    input  wire [31:0]      update_target,
    input  wire             update_valid  // when 1, set valid; 0 clears entry
);

    localparam N = (1 << INDEX_BITS);

    // index and tag extraction
    wire [INDEX_BITS-1:0] idx   = update_en ? update_pc[INDEX_BITS+1:2] : pc[INDEX_BITS+1:2];
    wire [TAG_BITS-1:0]   tag   = update_en ? update_pc[31:INDEX_BITS+2] : pc[31:INDEX_BITS+2];

    // storage arrays
    reg [TAG_BITS-1:0]    tag_array [0:N-1];
    reg [31:0]            target_array [0:N-1];
    reg                   valid_array  [0:N-1];

    integer i;
    // reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < N; i = i + 1) begin
                tag_array[i]    <= {TAG_BITS{1'b0}};
                target_array[i] <= 32'b0;
                valid_array[i]  <= 1'b0;
            end
        end else if (update_en) begin
            // write entry at update index
            tag_array[idx]    <= update_pc[31:INDEX_BITS+2];
            target_array[idx] <= update_target;
            valid_array[idx]  <= update_valid;
        end
    end

    // combinational lookup
    wire [TAG_BITS-1:0] stored_tag = tag_array[pc[INDEX_BITS+1:2]];
    wire                stored_valid = valid_array[pc[INDEX_BITS+1:2]];
    wire [31:0]         stored_target = target_array[pc[INDEX_BITS+1:2]];

    assign hit = stored_valid && (stored_tag == pc[31:INDEX_BITS+2]);
    assign target_out = stored_target;

endmodule
