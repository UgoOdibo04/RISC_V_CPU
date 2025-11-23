module flush_unit (
    input  wire        BranchResolvedE,
    input  wire        PCSrcE,              // actual branch taken?
    input  wire        predicted_takenF,    // predicted taken?
    input  wire [31:0] predicted_targetF,   // predicted target
    input  wire [31:0] PCTargetE,           // actual target

    output reg         FlushD,              // flush IF/ID
    output reg         FlushE,              // flush ID/EX
    output reg         CorrectPCSelect      // override PC mux
);

    always @(*) begin
        // defaults
        FlushD          = 1'b0;
        FlushE          = 1'b0;
        CorrectPCSelect = 1'b0;

        if (BranchResolvedE) begin
            // Mispredict conditions:
            // 1) predicted_taken != actual_taken
            // 2) predicted_taken AND predicted_target != actual_target
            if ((predicted_takenF != PCSrcE) ||
                (predicted_takenF && (predicted_targetF != PCTargetE))) begin

                FlushD          = 1'b1;  // kill IF/ID
                FlushE          = 1'b1;  // kill ID/EX
                CorrectPCSelect = 1'b1;  // force PC to actual target or PC+4
            end
        end
    end

endmodule
