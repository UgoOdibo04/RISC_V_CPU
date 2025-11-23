module IF_ID (
    input  wire        clk,
    input  wire        reset,
    input  wire        write_enable, // IFID_Write from hazard unit
    input  wire        flush,        // FlushD from flush unit

    input  wire [31:0] instr_in,
    input  wire [31:0] pc_in,
    input  wire [31:0] pcplus4_in,

    output reg  [31:0] instr_out,
    output reg  [31:0] pc_out,
    output reg  [31:0] pcplus4_out
);

    // A clean NOP encoding to use when flushing (ADDI x0,x0,0) or zero
    localparam [31:0] NOP_INSTR = 32'h00000013;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            instr_out   <= 32'b0;
            pc_out      <= 32'b0;
            pcplus4_out <= 32'b0;
        end
        else if (flush) begin
            // On flush, inject a NOP into decode stage
            instr_out   <= NOP_INSTR;
            pc_out      <= 32'b0;
            pcplus4_out <= 32'b0;
        end
        else if (write_enable) begin
            // Normal operation: latch new IF outputs
            instr_out   <= instr_in;
            pc_out      <= pc_in;
            pcplus4_out <= pcplus4_in;
        end
        // else: write_enable == 0 -> hold previous values (stall)
    end

endmodule
