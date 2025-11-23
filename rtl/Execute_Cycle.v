module Execute_Cycle(

    // From ID/EX pipeline register
    input  wire [31:0] RD1E,
    input  wire [31:0] RD2E,
    input  wire [31:0] ImmE,
    input  wire [31:0] PCE,
    input  wire [31:0] PCPlus4E,

    input  wire [4:0]  Rs1E,
    input  wire [4:0]  Rs2E,
    input  wire [4:0]  RdE,
    input  wire [2:0]  Funct3E,
    input  wire [6:0]  Funct7E,
    input  wire [6:0]  OpcodeE,

    // Control
    input  wire        MemWriteE,
    input  wire        MemReadE,
    input  wire        MemToRegE,
    input  wire        ALUSrcE,
    input  wire        RegWriteE,
    input  wire        BranchE,
    input  wire [4:0]  ALUControlE,

    // Outputs to EX/MEM stage
    output wire [31:0] ALUResultE,
    output wire [31:0] WriteDataE,     
    output wire [31:0] BranchTargetE,
    output wire        PCSrcE          
);

    // 1) Choose ALU Second Operand (ALUSrc)
    wire [31:0] SrcBE;

    alusrc_mux ALUSRC_MUX (
        .register2(RD2E),
        .immediate(ImmE),
        .control_signal(ALUSrcE),
        .mux_out(SrcBE)
    );

    // 2) ALU
    alu ALU (
        .Reg1(RD1E),
        .Reg2(SrcBE),
        .AluOP(ALUControlE),
        .ALU_Result(ALUResultE),
        .zero_flag()            
    );

    // 3) Branch Comparator 
    wire branch_taken;

    branch_compare BCMP (
        .rs1(RD1E),
        .rs2(RD2E),
        .funct3(Funct3E),
        .branch(branch_taken)
    );

    // 4) Branch Target = PC + immediate
    adder_pc BranchAdder (
        .input1(PCE),
        .input2(ImmE),
        .sumout(BranchTargetE)
    );

    // 5) PCSrcE (branch decision)
    assign PCSrcE = BranchE & branch_taken;

    // 6) Pass store data into EX/MEM stage
    assign WriteDataE = RD2E;   // after forwarding, if added later

endmodule
