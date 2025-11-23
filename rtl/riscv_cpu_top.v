module riscv_cpu_top (
    input  wire        clk,
    input  wire        reset
);

    // IF stage wires / predictor
    wire [31:0] PCF, PCNextF, PCPlus4F, InstrF;
    wire        predicted_taken;
    wire        btb_hit;
    wire [31:0] predicted_target;

    // Hazard / flush control signals
    wire        PCWrite;
    wire        IFID_Write;
    wire        ControlStall;
    wire        FlushD, FlushE, CorrectPCSelect;

    // Predictor update / branch resolution wires
    wire        BranchResolvedE;    // pulse when EX resolves a branch (we drive from EX)
    wire        PCSrcE;             // actual branch outcome from EX
    wire [31:0] PCTargetE;          // actual branch target from EX
    wire [31:0] BranchPCE;          // PC of branch instruction (from ID/EX->EX, PCE)

    // IF: PC + predictor logic
    pcplus4 pcadder (
        .fromPC(PCF),
        .nextPC(PCPlus4F)
    );

    // Branch predictor instance (tune INDEX_BITS)
    branch_predictor #(.INDEX_BITS(8)) PRED (
        .clk(clk),
        .reset(reset),
        .pc_if(PCF),
        .predicted_taken(predicted_taken),
        .btb_hit(btb_hit),
        .predicted_target(predicted_target),

        .update_en(BranchResolvedE),
        .update_pc(BranchPCE),
        .update_taken(PCSrcE),
        .update_target(PCTargetE)
    );

    // Next-PC mux (handles predictor vs. resolution)
    reg [31:0] next_pc_muxed;
    always @(*) begin
        // Default: sequential
        next_pc_muxed = PCPlus4F;
        // If a branch resolution just happened in EX, resolution wins
        if (BranchResolvedE) begin
            if (PCSrcE)
                next_pc_muxed = PCTargetE;   // actual taken
            else
                next_pc_muxed = PCPlus4F;    // actual not taken -> PC+4
        end
        else begin
            // No resolution: follow predictor when BTB hit AND predictor says taken
            if (predicted_taken && btb_hit)
                next_pc_muxed = predicted_target;
            else
                next_pc_muxed = PCPlus4F;
        end
    end

    // PC register (supports stall via PCWrite)
    pc ProgramCounter (
        .clock(clk),
        .reset(reset),
        .pc_write(PCWrite),
        .next_pc(PCNextF),
        .pc(PCF)
    );

    // Connect chosen next PC
    assign PCNextF = next_pc_muxed;

    // Instruction memory (combinational read)
    imem IMEM (
        .address(PCF),
        .instruction(InstrF)
    );

    // IF/ID pipeline register (supports stall and flush)
    wire [31:0] InstrD, PCD, PCPlus4D;
    IF_ID IFID (
        .clk(clk),
        .reset(reset),
        .write_enable(IFID_Write),
        .flush(FlushD),
        .instr_in(InstrF),
        .pc_in(PCF),
        .pcplus4_in(PCPlus4F),

        .instr_out(InstrD),
        .pc_out(PCD),
        .pcplus4_out(PCPlus4D)
    );

    // ID stage wires
    // Writeback interface to regfile
    wire        RegWriteW;
    wire [4:0]  WriteRegW;
    wire [31:0] WriteDataW;

    // Decode outputs to ID/EX
    wire [31:0] RD1D, RD2D, ImmD;
    wire [31:0] PCD_out, PCPlus4D_out;
    wire [4:0]  Rs1D, Rs2D, RdD;
    wire [2:0]  Funct3D;
    wire [6:0]  Funct7D;
    wire [6:0]  OpcodeD;
    wire        ALUSrcD, MemToRegD, RegWriteD, MemReadD, MemWriteD, BranchD, JumpD;
    wire [4:0]  ALUControlD;

    // Decode stage
    Decode_Cycle ID_STAGE (
        .clk(clk),
        .reset(reset),

        // IF/ID inputs
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),

        // WB writeback inputs to regfile
        .RegWriteW(RegWriteW),
        .WriteRegW(WriteRegW),
        .WriteDataW(WriteDataW),

        // hazard control (mask controls to inject NOP)
        .ControlStall(ControlStall),

        // outputs to ID/EX
        .RD1D(RD1D),
        .RD2D(RD2D),
        .ImmD(ImmD),
        .PCD_out(PCD_out),
        .PCPlus4D_out(PCPlus4D_out),
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .RdD(RdD),
        .Funct3D(Funct3D),
        .Funct7D(Funct7D),
        .OpcodeD(OpcodeD),

        .ALUSrcD(ALUSrcD),
        .MemToRegD(MemToRegD),
        .RegWriteD(RegWriteD),
        .MemReadD(MemReadD),
        .MemWriteD(MemWriteD),
        .BranchD(BranchD),
        .JumpD(JumpD),
        .ALUControlD(ALUControlD)
    );

    // ID/EX pipeline register
    wire [31:0] RD1E, RD2E, ImmE, PCE, PCPlus4E;
    wire [4:0]  Rs1E, Rs2E, RdE;
    wire [2:0]  Funct3E;
    wire [6:0]  Funct7E;
    wire [6:0]  OpcodeE;
    wire        MemWriteE, MemReadE, MemToRegE, ALUSrcE, RegWriteE, BranchE;
    wire [4:0]  ALUControlE;

    ID_EX IDEX (
        .clk(clk),
        .reset(reset),
        .flush(FlushE),

        .RD1D(RD1D),
        .RD2D(RD2D),
        .ImmD(ImmD),
        .PCD(PCD_out),
        .PCPlus4D(PCPlus4D_out),

        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .RdD(RdD),
        .Funct3D(Funct3D),
        .Funct7D(Funct7D),
        .OpcodeD(OpcodeD),

        .MemWriteD(MemWriteD),
        .MemReadD(MemReadD),
        .MemToRegD(MemToRegD),
        .ALUSrcD(ALUSrcD),
        .RegWriteD(RegWriteD),
        .BranchD(BranchD),
        .ALUControlD(ALUControlD),

        .RD1E(RD1E),
        .RD2E(RD2E),
        .ImmE(ImmE),
        .PCE(PCE),
        .PCPlus4E(PCPlus4E),

        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdE(RdE),
        .Funct3E(Funct3E),
        .Funct7E(Funct7E),
        .OpcodeE(OpcodeE),

        .MemWriteE(MemWriteE),
        .MemReadE(MemReadE),
        .MemToRegE(MemToRegE),
        .ALUSrcE(ALUSrcE),
        .RegWriteE(RegWriteE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE)
    );

    // Hazard unit now that ID/EX outputs exist
    hazard_unit HAZ (
        .MemReadE(MemReadE),
        .RdE(RdE),
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),

        .PCWrite(PCWrite),
        .IFID_Write(IFID_Write),
        .ControlStall(ControlStall)
    );

    // EX stage
    wire [31:0] ALUResultE, WriteDataE, BranchTargetE;
    wire        PCSrcE_internal;

    // Execute_Cycle previously defined expects PCE etc.
    Execute_Cycle EXE (
        .RD1E(RD1E),
        .RD2E(RD2E),
        .ImmE(ImmE),
        .PCE(PCE),
        .PCPlus4E(PCPlus4E),

        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdE(RdE),
        .Funct3E(Funct3E),
        .Funct7E(Funct7E),
        .OpcodeE(OpcodeE),

        .MemWriteE(MemWriteE),
        .MemReadE(MemReadE),
        .MemToRegE(MemToRegE),
        .ALUSrcE(ALUSrcE),
        .RegWriteE(RegWriteE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),

        .ALUResultE(ALUResultE),
        .WriteDataE(WriteDataE),
        .BranchTargetE(BranchTargetE),
        .PCSrcE(PCSrcE_internal)
    );

  
    assign BranchResolvedE = BranchE; // pulse when EX contains branch instruction
    assign PCSrcE = PCSrcE_internal;
    assign PCTargetE = BranchTargetE;
    // BranchPCE should be the PC of the branch instruction (PCE from ID/EX)
    assign BranchPCE = PCE;

    // EX/MEM pipeline register
    wire [31:0] ALUResultM, WriteDataM, BranchTargetM;
    wire [4:0]  RdM;
    wire        MemWriteM, MemReadM, MemToRegM, RegWriteM, PCSrcM;

    EX_MEM EXMEM (
        .clk(clk),
        .reset(reset),

        .ALUResultE(ALUResultE),
        .WriteDataE(WriteDataE),
        .BranchTargetE(BranchTargetE),
        .PCSrcE(PCSrcE_internal),
        .RdE(RdE),

        .MemWriteE(MemWriteE),
        .MemReadE(MemReadE),
        .MemToRegE(MemToRegE),
        .RegWriteE(RegWriteE),

        .ALUResultM(ALUResultM),
        .WriteDataM(WriteDataM),
        .BranchTargetM(BranchTargetM),
        .PCSrcM(PCSrcM),
        .RdM(RdM),

        .MemWriteM(MemWriteM),
        .MemReadM(MemReadM),
        .MemToRegM(MemToRegM),
        .RegWriteM(RegWriteM)
    );

    // MEM stage - data memory
    wire [31:0] ReadDataM;
    data_memory DMEM (
        .clock(clk),
        .reset(reset),

        .memwrite(MemWriteM),
        .memread(MemReadM),

        .address(ALUResultM),
        .write_data(WriteDataM),
        .write_mask(4'b1111),   // NOTE: replace if you have store_unit -> mem_wmask
        .read_data(ReadDataM)
    );

    // Pass signals into MEM/WB
    wire [31:0] ReadDataW, ALUResultW;
    wire [4:0]  RdW;
    wire        RegWriteW_internal, MemToRegW_internal;

    MEM_WB MEMWB (
        .clk(clk),
        .reset(reset),

        .ReadDataM(ReadDataM),
        .ALUResultM(ALUResultM),
        .RdM(RdM),
        .RegWriteM(RegWriteM),
        .MemToRegM(MemToRegM),

        .ReadDataW(ReadDataW),
        .ALUResultW(ALUResultW),
        .RdW(RdW),
        .RegWriteW(RegWriteW_internal),
        .MemToRegW(MemToRegW_internal)
    );

    // Writeback stage
    wire [31:0] WB_WriteData;
    Writeback_Cycle WB (
        .ReadDataW(ReadDataW),
        .ALUResultW(ALUResultW),
        .RdW(RdW),
        .RegWriteW(RegWriteW_internal),
        .MemToRegW(MemToRegW_internal),

        .WriteRegW(WriteRegW),
        .WriteEnableW(RegWriteW),
        .WriteDataW(WB_WriteData)
    );

    // Expose WriteDataW to register file via Decode_Cycle top-level instantiation
    assign WriteDataW = WB_WriteData;
    assign RegWriteW = RegWriteW_internal;

    flush_unit FLUSH (
        .BranchResolvedE(BranchResolvedE),
        .PCSrcE(PCSrcE),
        .predicted_takenF(predicted_taken),
        .predicted_targetF(predicted_target),
        .PCTargetE(PCTargetE),

        .FlushD(FlushD),
        .FlushE(FlushE),
        .CorrectPCSelect() // not used separately; handled in next_pc_mux logic above
    );

endmodule

