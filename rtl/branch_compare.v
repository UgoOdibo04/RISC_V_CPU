module branch_compare (
    input  wire [31:0] rs1,
    input  wire [31:0] rs2,
    input  wire [2:0]  funct3,
    output reg         branch
);

    always @(*) begin
        case (funct3)
            3'b000: branch = (rs1 == rs2);                          // BEQ
            3'b001: branch = (rs1 != rs2);                          // BNE
            3'b100: branch = ($signed(rs1) <  $signed(rs2));        // BLT
            3'b101: branch = ($signed(rs1) >= $signed(rs2));        // BGE
            3'b110: branch = (rs1 <  rs2);                          // BLTU
            3'b111: branch = (rs1 >= rs2);                          // BGEU
            default: branch = 1'b0;
        endcase
    end

endmodule
