module Memory_Cycle (
    input  wire        clk,
    input  wire        reset,

    // From EX/MEM pipeline register
    input  wire [31:0] ALUResultM,
    input  wire [31:0] WriteDataM,
    input  wire [4:0]  RdM,
    input  wire        MemWriteM,
    input  wire        MemReadM,
    input  wire        MemToRegM,
    input  wire        RegWriteM,

    // To MEM/WB pipeline register
    output wire [31:0] ReadDataM_Out,
    output wire [31:0] ALUResultM_Out,
    output wire [4:0]  RdM_Out,
    output wire        RegWriteM_Out,
    output wire        MemToRegM_Out
);

    // 1) Data Memory Instance
    data_memory DMEM (
        .clock(clk),
        .reset(reset),

        .address(ALUResultM),
        .write_data(WriteDataM),
        .write_mask(4'b1111),          // for full 32-bit word writes
        .memwrite(MemWriteM),
        .memread(MemReadM),

        .read_data(ReadDataM_Out)
    );

    // 2) Pass-through to WB stage
    assign ALUResultM_Out = ALUResultM;
    assign RdM_Out        = RdM;
    assign RegWriteM_Out  = RegWriteM;
    assign MemToRegM_Out  = MemToRegM;

endmodule
