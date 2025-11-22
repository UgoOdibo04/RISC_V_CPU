module immediate_generator(
    input  wire [31:0] instruction,
    output reg  [31:0] immediate
);

    wire [6:0] opcode = instruction[6:0];

    always @(*) begin
        case (opcode)

            // -----------------------------
            // I-type (ADDI, LW, JALR, etc.)
            // imm[31:0] = sign-extend(instr[31:20])
            // -----------------------------
            7'b0000011,   // LOAD
            7'b0010011,   // I-type ALU (ADDI, ANDI, etc.)
            7'b1100111:   // JALR
                immediate = {{20{instruction[31]}}, instruction[31:20]};

            // -----------------------------
            // S-type (stores)
            // imm[31:0] = sign-extend({instr[31:25], instr[11:7]})
            // -----------------------------
            7'b0100011:
                immediate = {{20{instruction[31]}},
                              instruction[31:25],
                              instruction[11:7]};

            // -----------------------------
            // B-type (branches)
            // imm = { instr[31], instr[7], instr[30:25], instr[11:8], 0 }
            // -----------------------------
            7'b1100011:
                immediate = {{19{instruction[31]}},
                              instruction[31],
                              instruction[7],
                              instruction[30:25],
                              instruction[11:8],
                              1'b0};

            // -----------------------------
            // U-type (LUI, AUIPC)
            // imm = instr[31:12] << 12
            // -----------------------------
            7'b0110111,  // LUI
            7'b0010111:  // AUIPC
                immediate = {instruction[31:12], 12'b0};

            // -----------------------------
            // J-type (JAL)
            // imm = { instr[31], instr[19:12], instr[20], instr[30:21], 0 }
            // -----------------------------
            7'b1101111:
                immediate = {{11{instruction[31]}},
                              instruction[31],
                              instruction[19:12],
                              instruction[20],
                              instruction[30:21],
                              1'b0};

            default:
                immediate = 32'b0;
        endcase
    end

endmodule
