module data_memory (
    input  wire        clock,
    input  wire        reset,

    // control signals
    input  wire        memwrite,
    input  wire        memread,

    // address and data
    input  wire [31:0] address,      // byte address from ALU
    input  wire [31:0] write_data,   // store_unit output
    input  wire [3:0]  write_mask,   // store_unit output (byte enables)

    // output data
    output wire [31:0] read_data
);

    // 128 words = 512 bytes
    reg [31:0] D_Memory [0:127];

    integer i;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 128; i = i + 1)
                D_Memory[i] <= 32'b0;
        end
        else if (memwrite) begin
        
            // Masked write
            // SB, SH, SW support
            if (write_mask[0]) D_Memory[address[31:2]][7:0]   <= write_data[7:0];
            if (write_mask[1]) D_Memory[address[31:2]][15:8]  <= write_data[15:8];
            if (write_mask[2]) D_Memory[address[31:2]][23:16] <= write_data[23:16];
            if (write_mask[3]) D_Memory[address[31:2]][31:24] <= write_data[31:24];
        end
    end


    // Combinational read
    assign read_data = memread ? D_Memory[address[31:2]] : 32'b0;

endmodule
