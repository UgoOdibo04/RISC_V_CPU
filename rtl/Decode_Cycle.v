module Decode_Cycle(
    input  wire        clk,
    input  wire        reset,

    // From IF/ID pipeline register
    input  wire [31:0] InstrD,
    input  wire [31:0] PCD,
    input  wire [31:0] PCPlus4D,

    // Writeback stage signals
    input  wire        RegWriteW,
    input  wire [4:0]  WriteRegW,
    input  wire [31:0] WriteDataW,

    // Outputs to ID/EX pipeline register
    output wire [31:0] RD1D,
    output wire [31:0] RD2D,
    output wire [31:0] ImmD,
    output wire [4:0]  Rs1D,
    output wire [4:0]  Rs2D,
    output wire [4:0]  RdD,
    output wire [2:0]  Funct3D,
    output wire [6:0]  Funct7D,
    output wire [6:0]  OpcodeD,

    // Control signals
    output wire        MemWriteD,
    output wire        MemReadD,
    output wire        MemToRegD,
    output wire        ALUSrcD,
    output wire        RegWriteD,
    output wire        BranchD,
    output wire [4:0]  ALUControlD
);

    // 1. Extract instruction fields
    assign OpcodeD = InstrD[6:0];
    assign RdD     = InstrD[11:7];
    assign Funct3D = InstrD[14:12];
    assign Rs1D    = InstrD[19:15];
    assign Rs2D    = InstrD[24:20];
    assign Funct7D = InstrD[31:25];

   
    // 2. Register File
    register_file RF (
        .read_reg1(Rs1D),
        .read_reg2(Rs2D),
        .reg1_value(RD1D),
        .reg2_value(RD2D),

        .regwrite(RegWriteW),
        .write_reg(WriteRegW),
        .write_data(WriteDataW),

        .clock(clk),
        .reset(reset)
    );

    // 3. Immediate Generator
    immediate_generator IMMGEN (
        .instruction(InstrD),
        .immediate(ImmD)
    );

    // 4. Main Control Unit
    control_unit CU (
        .opcode(OpcodeD),
        
        .branch(BranchD),
        .memread(MemReadD),
        .memtoreg(MemToRegD),
        .memwrite(MemWriteD),
        .alusrc(ALUSrcD),
        .regwrite(RegWriteD)
    );

    // 5. ALU Control Unit
    alu_control ALUCTRL (
        .opcode(OpcodeD),
        .func3(Funct3D),
        .func7(Funct7D),
        .alu_control(ALUControlD)
    );

endmodule
