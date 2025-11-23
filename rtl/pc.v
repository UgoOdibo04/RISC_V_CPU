module pc(
    input  wire        clock,
    input  wire        reset,
    input  wire        pc_write,   // NEW
    input  wire [31:0] next_pc,
    output reg  [31:0] pc
);
    always @(posedge clock or posedge reset) begin
        if (reset)
            pc <= 32'h00000000;
        else if (pc_write)
            pc <= next_pc;
        // else keep old pc (stall)
    end
endmodule
