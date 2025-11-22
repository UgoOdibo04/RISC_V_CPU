module instruction_mem (
  input clock,
  input reset,
  input [31:0] address,
  output reg [31:0] instruction,
  integer i
);
  // 2KB 32 Bits Wide
  reg [31:0] mem [0:511];

  always @(posedge clock or posedge reset)
    begin 
      if(reset)
        begin
          for(i = 0; i < 512; i = i+1) begin 
            mem[i] <= 32'b00;
          end 
          else 
            instruction <= mem[address];
        end 

endmodule 
