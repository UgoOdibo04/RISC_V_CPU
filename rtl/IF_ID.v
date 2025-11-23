module IF_ID (
    input  wire        clk,
    input  wire        reset,
    input wire         write_enable,
    input  wire [31:0] instr_in,
    input  wire [31:0] pc_in,
    input  wire [31:0] pcplus4_in,

    output reg [31:0] instr_out,
    output reg [31:0] pc_out,
    output reg [31:0] pcplus4_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            instr_out     <= 32'b0;
            pc_out        <= 32'b0;
            pcplus4_out   <= 32'b0;
        end
        else if (write_enable) begin
            instr_out     <= instr_in;
            pc_out        <= pc_in;
            pcplus4_out   <= pcplus4_in;
        end
    end

endmodule

