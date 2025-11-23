module Fetch_Cycle(
    input  wire        clk,
    input  wire        reset,

    // branch resolution inputs from EX stage
    input  wire        BranchResolvedE, // 1 when EX resolved a branch (taken or not)
    input  wire        PCSrcE,          // 1 if branch taken (resolved)
    input  wire [31:0] PCTargetE,       // resolved branch target (valid if PCSrcE==1)
    input  wire [31:0] BranchPCE,       // PC of branch instruction in EX (for predictor update)

    // Fetch outputs (to IF/ID)
    output wire [31:0] InstrD,
    output wire [31:0] PCD,
    output wire [31:0] PCPlus4D
    output wire FlushD
);

    // Internal wires
    wire [31:0] PCF;
    wire [31:0] PCNextF;
    wire [31:0] PCPlus4F;
    wire [31:0] InstrF;

    // Predictor signals
    wire predicted_taken;
    wire btb_hit;
    wire [31:0] predicted_target;

    
    // 1) PC + 4 adder
    pcplus4 PCAdder (
        .fromPC(PCF),
        .nextPC(PCPlus4F)
    );

    // 2) Branch predictor (lookup in IF)
    // Tune INDEX_BITS to your resource/accuracy tradeoff (e.g. 8 = 256 entries)
    branch_predictor #(.INDEX_BITS(8)) PRED (
        .clk(clk),
        .reset(reset),
        .pc_if(PCF),
        .predicted_taken(predicted_taken),
        .btb_hit(btb_hit),
        .predicted_target(predicted_target),

        // update interface (driven when EX resolves a branch)
        .update_en(BranchResolvedE),
        .update_pc(BranchPCE),
        .update_taken(PCSrcE),
        .update_target(PCTargetE)
    );

    
    // 3) Next PC selection logic
    // Priority:
    //  1) If EX just resolved a branch (BranchResolvedE) -> use resolved PC (take or not)
    //  2) else if predictor says taken && BTB hit -> use predicted_target
    //  3) else use PC+4
    reg [31:0] next_pc_muxed;
    always @(*) begin
        if (BranchResolvedE) begin
            // EX resolved a branch; resolution wins (fix pipeline immediately)
            if (PCSrcE) begin
                // actual branch taken -> go to resolved target
                next_pc_muxed = PCTargetE;
            end else begin
                // actual branch not taken -> go to sequential PC+4
                next_pc_muxed = PCPlus4F;
            end
        end else begin
            // no resolution this cycle: use predictor
            if (predicted_taken && btb_hit) begin
                next_pc_muxed = predicted_target;
            end else begin
                next_pc_muxed = PCPlus4F;
            end
        end
    end


    // 4) PC Register (supports stall via pc_write externally
    pc ProgramCounter (
        .clock(clk),
        .reset(reset),
        .next_pc(PCNextF),
        .pc(PCF)
    );

    // Feed chosen next pc into PCNextF
    assign PCNextF = next_pc_muxed;

    // ------------------------------
    // 5) Instruction Memory
    // ------------------------------
    imem InstructionMemory (
        .address(PCF),
        .instruction(InstrF)
    );

    // 6) IF/ID pipeline register
    IF_ID IFID (
        .clk(clk),
        .reset(reset),
        .write_enable(1'b1), 
        .instr_in(InstrF),
        .flush(FlushD),             
        .pc_in(PCF),
        .pcplus4_in(PCPlus4F),

        .instr_out(InstrD),
        .pc_out(PCD),
        .pcplus4_out(PCPlus4D)
    );

endmodule
