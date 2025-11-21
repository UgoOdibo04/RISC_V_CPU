module imeme (
  input [31:0] address,
  output [31:0] instruction
);
  // 2KB 32 Bits Wide
  reg [31:0] mem [0:511];

 initial begin
        $readmemh("imem.hex", mem);
    end

assign instruction = mem[address[31:2]];

endmodule 
