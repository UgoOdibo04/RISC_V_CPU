module register_file(

    // Read ports
    input  wire [4:0]  read_reg1,
    input  wire [4:0]  read_reg2,
    output wire [31:0] reg1_value,
    output wire [31:0] reg2_value,

    // Write port
    input  wire        regwrite,
    input  wire [4:0]  write_reg,
    input  wire [31:0] write_data,

    // Control
    input  wire        clock,
    input  wire        reset
);

    // 32 registers, 32-bit each
    reg [31:0] reg_memory [0:31];
    integer i;

    // ---------------------------
    // RESET: fill registers with 0
    // ---------------------------
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                reg_memory[i] <= 32'b0;
        end 
        else if (regwrite) begin
            if (write_reg != 0)      // x0 must stay zero
                reg_memory[write_reg] <= write_data;
        end
    end

    // Asynchronous read ports
    assign reg1_value = reg_memory[read_reg1];
    assign reg2_value = reg_memory[read_reg2];

endmodule
