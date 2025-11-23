module hazard_unit (
    input  wire        MemReadE,
    input  wire [4:0]  RdE,
    input  wire [4:0]  Rs1D,
    input  wire [4:0]  Rs2D,

    output reg         PCWrite,
    output reg         IFID_Write,
    output reg         ControlStall
);

    always @(*) begin
        // defaults: no stall
        PCWrite     = 1'b1;
        IFID_Write  = 1'b1;
        ControlStall= 1'b0;

        // Load-use hazard: ID/EX holds a load and RdE matches Rs1D or Rs2D (and RdE != x0)
        if (MemReadE && (RdE != 5'd0) &&
            ((RdE == Rs1D) || (RdE == Rs2D))) begin
            // stall one cycle
            PCWrite      = 1'b0;  // freeze PC
            IFID_Write   = 1'b0;  // freeze IF/ID
            ControlStall = 1'b1;  // force ID control outputs to 0 (insert bubble)
        end
    end

endmodule
