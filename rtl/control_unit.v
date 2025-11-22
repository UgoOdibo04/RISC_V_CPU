module control_unit (
    input  wire [6:0] opcode,

    output reg        branch,
    output reg        memread,
    output reg        memtoreg,
    output reg        memwrite,
    output reg        alusrc,
    output reg        regwrite
);

    always @(*) begin
        // Default NOP
        {alusrc, memtoreg, regwrite, memread, memwrite, branch} = 6'b000000;

        case (opcode)

            // R-type (ADD, SUB, OR, AND, etc.)
            7'b0110011 : 
                {alusrc, memtoreg, regwrite, memread, memwrite, branch} = 6'b001000;

            // LOAD (LB, LH, LW, LBU, LHU)
            7'b0000011 : 
                {alusrc, memtoreg, regwrite, memread, memwrite, branch} = 6'b111100;

            // STORE (SB, SH, SW)
            7'b0100011 : 
                {alusrc, memtoreg, regwrite, memread, memwrite, branch} = 6'b100010;

            // I-type ALU (ADDI, XORI, ANDI...)
            7'b0010011 :
                {alusrc, memtoreg, regwrite, memread, memwrite, branch} = 6'b101000;

            // BRANCH (BEQ, BNE, etc.)
            7'b1100011 :
                {alusrc, memtoreg, regwrite, memread, memwrite, branch} = 6'b100001;

        endcase
    end 

endmodule
