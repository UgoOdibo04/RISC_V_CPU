module id (
    // clock / reset
    input  wire        clock,
    input  wire        reset,

    // inputs from IF/ID
    input  wire [31:0] instr_in,
    input  wire [31:0] pc_in,

    // write-back (from WB stage)
    input  wire [4:0]  wb_rd,
    input  wire [31:0] wb_data,
    input  wire        wb_regwrite,

    // decoded outputs (to EX stage / ID/EX register)
    output wire [31:0] rs1_val,
    output wire [31:0] rs2_val,
    output wire [31:0] imm_out,

    // instruction fields (convenience outputs)
    output wire [4:0]  rs1,
    output wire [4:0]  rs2,
    output wire [4:0]  rd,
    output wire [2:0]  funct3,
    output wire [6:0]  funct7,
    output wire [6:0]  opcode,

    // control signals (to be latched into ID/EX)
    output wire        alu_src,
    output wire        mem_to_reg,
    output wire        regwrite,
    output wire        memread,
    output wire        memwrite,
    output wire        branch,
    output wire        jump,
    output wire [4:0]  alu_control
);

    // Instruction field decoding (combinational)
    assign opcode = instr_in[6:0];
    assign rd     = instr_in[11:7];
    assign funct3 = instr_in[14:12];
    assign rs1    = instr_in[19:15];
    assign rs2    = instr_in[24:20];
    assign funct7 = instr_in[31:25];
  
    // Register file: 2 read ports, 1 write port (synchronous write)
    regfile RF (
        .clock(clock),
        .reset(reset),
        .read_reg1(rs1),
        .read_reg2(rs2),
        .reg1_value(rs1_val),
        .reg2_value(rs2_val),
        .regwrite(wb_regwrite),
        .write_reg(wb_rd),
        .write_data(wb_data)
    );

    
    // Immediate generator
    imm_gen IMMGEN (
        .instr(instr_in),
        .imm(imm_out)
    );
  
    // Main control unit
    control_unit CU (
        .opcode(opcode),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .regwrite(regwrite),
        .memread(memread),
        .memwrite(memwrite),
        .branch(branch),
        .jump(jump)
    );

  
    // ALU control: maps opcode/funct3/funct7 -> alu_control code
    alu_control ALUCTRL (
        .opcode(opcode),
        .func3(funct3),
        .func7(funct7),
        .alu_control(alu_control)
    );

endmodule
