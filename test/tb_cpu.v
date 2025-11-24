`timescale 1ns/1ps

module tb_cpu;

    reg clk;
    reg reset;

    // Instantiate your RISC-V CPU top module
    cpu_top DUT (
        .clk(clk),
        .reset(reset)
    );

    // Clock generator
    always #5 clk = ~clk; // 100 MHz clock

    initial begin
        $display("Starting RISC-V CPU simulation...");

        clk = 0;
        reset = 1;
        #20 reset = 0;

        // Run simulation for some time
        #2000;

        $display("Finished simulation.");
        $stop;
    end

endmodule

