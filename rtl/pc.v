module pc (
    input        clock,
    input         reset,
    input   [31:0] next_pc,
    output reg  [31:0] pc
);

  always @(posedge clock or posedge reset) begin
        if (reset)
            pc <= 32'h00000000;   
        else
            pc <= next_pc;
    end

endmodule

