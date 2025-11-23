module bimodal_predictor #(
    parameter INDEX_BITS = 10    // index size (match BTB index for simplicity)
)(
    input  wire             clk,
    input  wire             reset,

    // Lookup
    input  wire [31:0]      pc,
    output wire             predict_taken,

    // Update interface (on actual branch outcome)
    input  wire             update_en,
    input  wire [31:0]      update_pc,
    input  wire             update_taken
);

    localparam N = (1 << INDEX_BITS);

    // index bits (word aligned)
    wire [INDEX_BITS-1:0] idx = pc[INDEX_BITS+1:2];
    wire [INDEX_BITS-1:0] update_idx = update_pc[INDEX_BITS+1:2];

    reg [1:0] counter [0:N-1]; // 2-bit saturating counters
    integer i;

    // reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < N; i = i + 1) counter[i] <= 2'b01; // weakly not taken as default
        end else if (update_en) begin
            if (update_taken) begin
                // increment towards taken
                case (counter[update_idx])
                    2'b00: counter[update_idx] <= 2'b01;
                    2'b01: counter[update_idx] <= 2'b10;
                    2'b10: counter[update_idx] <= 2'b11;
                    2'b11: counter[update_idx] <= 2'b11;
                endcase
            end else begin
                // decrement towards not-taken
                case (counter[update_idx])
                    2'b00: counter[update_idx] <= 2'b00;
                    2'b01: counter[update_idx] <= 2'b00;
                    2'b10: counter[update_idx] <= 2'b01;
                    2'b11: counter[update_idx] <= 2'b10;
                endcase
            end
        end
    end

    // predict: taken when MSB of counter is 1 (states 10 or 11)
    assign predict_taken = counter[idx][1];

endmodule
