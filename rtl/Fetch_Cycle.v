module Fetch_Cycle(
    input  wire        clk,
    input  wire        reset,
    input  wire        PCSrcE,        // branch control from EX
    input  wire [31:0] PCTargetE,     // branch target from EX

    output wire [31:0] InstrD,        // IF/ID outputs
    output wire [31:0] PCD,
    output wire [31:0] PCPlus4D
);

    // Internal wires
    wire [31:0] PCF;
    wire [31:0] PCNextF;
    wire [31:0] PCPlus4F;
    wire [31:0] InstrF;

    // PC + 4
    pcplus4 PCAdder (
        .fromPC(PCF),
        .nextPC(PCPlus4F)
    );
    // Select next PC
    pc_mux NextPCMux (
        .branch_target(PCTargetE),
        .pc_plus4(PCPlus4F),
        .control_signal(PCSrcE),
        .mux_out(PCNextF)
    );
    // PC Register
    pc ProgramCounter (
        .clock(clk),
        .reset(reset),
        .next_pc(PCNextF),
        .pc(PCF)
    );

    // Instruction Memory
    imem InstructionMemory (
        .address(PCF),
        .instruction(InstrF)
    );
  
 // IF/ID Pipeline Register
    IF_ID if_id_reg (
        .clk(clk),
        .reset(reset),
        .instr_in(InstrF),
        .pc_in(PCF),
        .pcplus4_in(PCPlus4F),

        .instr_out(InstrD),
        .pc_out(PCD),
        .pcplus4_out(PCPlus4D)
    );

endmodule
