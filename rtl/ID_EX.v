module ID_EX (
    input  wire        clk,
    input  wire        reset,

    // From Decode Stage (ID)
    input  wire [31:0] RD1D,
    input  wire [31:0] RD2D,
    input  wire [31:0] ImmD,
    input  wire [31:0] PCD,
    input  wire [31:0] PCPlus4D,

    input  wire [4:0]  Rs1D,
    input  wire [4:0]  Rs2D,
    input  wire [4:0]  RdD,
    input  wire [2:0]  Funct3D,
    input  wire [6:0]  Funct7D,
    input  wire [6:0]  OpcodeD,

    // Control signals from Decode stage
    input  wire        MemWriteD,
    input  wire        MemReadD,
    input  wire        MemToRegD,
    input  wire        ALUSrcD,
    input  wire        RegWriteD,
    input  wire        BranchD,
    input  wire [4:0]  ALUControlD,

    // Outputs into Execute Stage (EX)
    output reg [31:0] RD1E,
    output reg [31:0] RD2E,
    output reg [31:0] ImmE,
    output reg [31:0] PCE,
    output reg [31:0] PCPlus4E,

    output reg [4:0]  Rs1E,
    output reg [4:0]  Rs2E,
    output reg [4:0]  RdE,
    output reg [2:0]  Funct3E,
    output reg [6:0]  Funct7E,
    output reg [6:0]  OpcodeE,

    // Control signals latched for EX stage
    output reg        MemWriteE,
    output reg        MemReadE,
    output reg        MemToRegE,
    output reg        ALUSrcE,
    output reg        RegWriteE,
    output reg        BranchE,
    output reg [4:0]  ALUControlE
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            RD1E        <= 32'b0;
            RD2E        <= 32'b0;
            ImmE        <= 32'b0;
            PCE         <= 32'b0;
            PCPlus4E    <= 32'b0;

            Rs1E        <= 5'b0;
            Rs2E        <= 5'b0;
            RdE         <= 5'b0;
            Funct3E     <= 3'b0;
            Funct7E     <= 7'b0;
            OpcodeE     <= 7'b0;

            MemWriteE   <= 1'b0;
            MemReadE    <= 1'b0;
            MemToRegE   <= 1'b0;
            ALUSrcE     <= 1'b0;
            RegWriteE   <= 1'b0;
            BranchE     <= 1'b0;
            ALUControlE <= 5'b0;
        end
        else begin
            RD1E        <= RD1D;
            RD2E        <= RD2D;
            ImmE        <= ImmD;
            PCE         <= PCD;
            PCPlus4E    <= PCPlus4D;

            Rs1E        <= Rs1D;
            Rs2E        <= Rs2D;
            RdE         <= RdD;
            Funct3E     <= Funct3D;
            Funct7E     <= Funct7D;
            OpcodeE     <= OpcodeD;

            MemWriteE   <= MemWriteD;
            MemReadE    <= MemReadD;
            MemToRegE   <= MemToRegD;
            ALUSrcE     <= ALUSrcD;
            RegWriteE   <= RegWriteD;
            BranchE     <= BranchD;
            ALUControlE <= ALUControlD;
        end
    end

endmodule

