module adder_pc (
    input  wire [31:0] input1,
    input  wire [31:0] input2,
    output wire [31:0] sumout
);

    assign sumout = input1 + input2;

endmodule
