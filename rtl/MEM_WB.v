module MEM_WB (
    input  wire        clk,
    input  wire        reset,

    // From MEM stage
    input  wire [31:0] ReadDataM,
    input  wire [31:0] ALUResultM,
    input  wire [4:0]  RdM,
    input  wire        RegWriteM,
    input  wire        MemToRegM,

    // Outputs to WB stage
    output reg [31:0] ReadDataW,
    output reg [31:0] ALUResultW,
    output reg [4:0]  RdW,
    output reg        RegWriteW,
    output reg        MemToRegW
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ReadDataW   <= 32'b0;
            ALUResultW  <= 32'b0;
            RdW         <= 5'b0;
            RegWriteW   <= 1'b0;
            MemToRegW   <= 1'b0;
        end
        else begin
            ReadDataW   <= ReadDataM;
            ALUResultW  <= ALUResultM;
            RdW         <= RdM;
            RegWriteW   <= RegWriteM;
            MemToRegW   <= MemToRegM;
        end
    end

endmodule
