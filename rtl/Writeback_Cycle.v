module Writeback_Cycle (
    input  wire [31:0] ReadDataW,
    input  wire [31:0] ALUResultW,
    input  wire [4:0]  RdW,
    input  wire        RegWriteW,
    input  wire        MemToRegW,

    // Outputs to register file
    output wire [4:0]  WriteRegW,
    output wire        WriteEnableW,
    output wire [31:0] WriteDataW
);

    // Writeback mux
    assign WriteDataW = (MemToRegW == 1'b1) 
                        ? ReadDataW       // load instruction
                        : ALUResultW;     // ALU result

    // Pass-through destination register + write enable
    assign WriteRegW    = RdW;
    assign WriteEnableW = RegWriteW;

endmodule
