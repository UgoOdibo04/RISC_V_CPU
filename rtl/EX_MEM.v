module EX_MEM (
    input  wire        clk,
    input  wire        reset,

    // From EX stage
    input  wire [31:0] ALUResultE,
    input  wire [31:0] WriteDataE,
    input  wire [31:0] BranchTargetE,
    input  wire        PCSrcE,
    input  wire [4:0]  RdE,

    // Control
    input  wire        MemWriteE,
    input  wire        MemReadE,
    input  wire        MemToRegE,
    input  wire        RegWriteE,

    // Outputs to MEM stage
    output reg [31:0] ALUResultM,
    output reg [31:0] WriteDataM,
    output reg [31:0] BranchTargetM,
    output reg        PCSrcM,
    output reg [4:0]  RdM,

    // Control forwarded
    output reg        MemWriteM,
    output reg        MemReadM,
    output reg        MemToRegM,
    output reg        RegWriteM
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ALUResultM    <= 32'b0;
            WriteDataM    <= 32'b0;
            BranchTargetM <= 32'b0;
            PCSrcM        <= 1'b0;
            RdM           <= 5'b0;

            MemWriteM     <= 1'b0;
            MemReadM      <= 1'b0;
            MemToRegM     <= 1'b0;
            RegWriteM     <= 1'b0;
        end
        else begin
            ALUResultM    <= ALUResultE;
            WriteDataM    <= WriteDataE;
            BranchTargetM <= BranchTargetE;
            PCSrcM        <= PCSrcE;
            RdM           <= RdE;

            MemWriteM     <= MemWriteE;
            MemReadM      <= MemReadE;
            MemToRegM     <= MemToRegE;
            RegWriteM     <= RegWriteE;
        end
    end

endmodule

