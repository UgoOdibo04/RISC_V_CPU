module mem (
  input clock,
  input reset, 
  input memwrite,
  input memread,
  input [31:0] read_address, 
  input  [31:0] write_data, 
  output [31:0] data_out, 
);
reg [31:0] D_Memory [127:0];
  integer k

  always @(posedge clock or posedge reset)
    being
    if(reset)
      begin 
        for(k = 0; k < 128; k = k +1) begin 
          D_Memory[k] <= 32'b00;
        end
      end 
  else if(memwrite) begin 
    D_Memory[read_address] <= write_data;
  end
  end
  assign data_out = (memread) ? D_Memory[read_address] : 32'b00;
  


  end module 
