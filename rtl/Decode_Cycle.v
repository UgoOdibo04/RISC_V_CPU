module Decode_Cycle(
    input  wire        clk,
    input  wire        reset,

    // Inputs from IF/ID
    input  wire [31:0] InstrD,
    input  wire [31:0] PCD,
    input  wire [31:0] PCPlus4D,

    // Write-back stage (to write result into regfile)
    input  wire        RegWriteW,  
    input  wire [4:0]  WriteRegW, 
    input  wire [31:0] WriteDataW,  

    // Stall control (from hazard unit) - when asserted, ID outputs should be NOP
    input  wire        ControlStall,

    // Decoded outputs (to ID/EX register)
    output wire [31:0] RD1D,
    output wire [31:0] RD2D,
    output wire [31:0] ImmD,
    output wire [31:0] PCD_out,
    output wire [31:0] PCPlus4D_out,

    output wire [4:0]  Rs1D,
    output wire [4:0]  Rs2D,
    output wire [4:0]  RdD,
    output wire [2:0]  Funct3D,
    output wire [6:0]  Funct7D,
    output wire [6:0]  OpcodeD,

    // Control signals (after masking with ControlStall)
    output wire        ALUSrcD,
    output wire        MemToRegD,
    output wire        RegWriteD,
    output wire        MemReadD,
    output wire        MemWriteD,
    output wire        BranchD,
    output wire        JumpD,
    output wire [4:0]  ALUControlD
);

    // 1) Instruction field decode (combinational)
    assign OpcodeD = InstrD[6:0];
    assign RdD     = InstrD[11:7];
    assign Funct3D = InstrD[14:12];
    assign Rs1D    = InstrD[19:15];
    assign Rs2D    = InstrD[24:20];
    assign Funct7D = InstrD[31:25];

    // expose PC/PC+4 to ID/EX
    assign PCD_out      = PCD;
    assign PCPlus4D_out = PCPlus4D;

    // 2) Register file (2-read, 1-write). Writes happen in WB stage.
    wire [31:0] rf_rdata1, rf_rdata2;
    register_file RF (
        .read_reg1(Rs1D),
        .read_reg2(Rs2D),
        .reg1_value(rf_rdata1),
        .reg2_value(rf_rdata2),

        .regwrite(RegWriteW),
        .write_reg(WriteRegW),
        .write_data(WriteDataW),

        .clock(clk),
        .reset(reset)
    );

    assign RD1D = rf_rdata1;
    assign RD2D = rf_rdata2;

    // 3) Immediate generator
    wire [31:0] imm_raw;
    immediate_generator IMMGEN (
        .instruction(InstrD),
        .immediate(imm_raw)
    );

    assign ImmD = imm_raw;

    // 4) Main control unit (raw signals)
    wire alu_src_raw, memtoreg_raw, regwrite_raw, memread_raw, memwrite_raw, branch_raw, jump_raw;

    control_unit CU (
        .opcode(OpcodeD),

        .branch(branch_raw),
        .memread(memread_raw),
        .memtoreg(memtoreg_raw),
        .memwrite(memwrite_raw),
        .alusrc(alu_src_raw),
        .regwrite(regwrite_raw)
    );

    // 5) ALU control unit
    wire [4:0] alu_control_raw;
    alu_control ALUCTRL (
        .opcode(OpcodeD),
        .func3(Funct3D),
        .func7(Funct7D),
        .alu_control(alu_control_raw)
    );

    // 6) Mask control signals with ControlStall to inject a NOP
    assign ALUSrcD    = ControlStall ? 1'b0 : alu_src_raw;
    assign MemToRegD  = ControlStall ? 1'b0 : memtoreg_raw;
    assign RegWriteD  = ControlStall ? 1'b0 : regwrite_raw;
    assign MemReadD   = ControlStall ? 1'b0 : memread_raw;
    assign MemWriteD  = ControlStall ? 1'b0 : memwrite_raw;
    assign BranchD    = ControlStall ? 1'b0 : branch_raw;
    assign JumpD      = ControlStall ? 1'b0 : 1'b0; // set to 0 by default; update if CU supplies jump
    assign ALUControlD= ControlStall ? 5'b0  : alu_control_raw;

endmodule
