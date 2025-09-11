module score_display (
    input clk, clk_1ms, reset,            // Input signals
    input [3:0] p1_score, p2_score,       // Player scores
    output reg [6:0] seg1, seg2           // Output segment displays
);

// Array to store segment values for digits 0-9
logic [6:0] segments [0:9];

// Initialization block to assign segment values
initial begin
    seg1 <= 7'b1111111;                  // Clear display 1
    seg2 <= 7'b1111111;                  // Clear display 2
    segments[0] = 7'b1000000;            // 0
    segments[1] = 7'b1111001;            // 1
    segments[2] = 7'b0100100;            // 2
    segments[3] = 7'b0110000;            // 3
    segments[4] = 7'b0011001;            // 4
    segments[5] = 7'b0010010;            // 5
    segments[6] = 7'b0000010;            // 6
    segments[7] = 7'b1111000;            // 7
    segments[8] = 7'b0000000;            // 8
    segments[9] = 7'b0011000;            // 9
end

// Always block to update segment display based on player scores
always_ff @ (*) begin
    // Reset displays if reset signal is active
    if (!reset) begin
        seg1 = 7'b1111111;
        seg2 = 7'b1111111;
    end
    else begin
        // Update display 1 based on player 2 score
        case (p2_score)
            4'h0 : seg1 = segments[0];  // 0
            4'h1 : seg1 = segments[1];  // 1
            4'h2 : seg1 = segments[2];  // 2
            4'h3 : seg1 = segments[3];  // 3
            4'h4 : seg1 = segments[4];  // 4
            4'h5 : seg1 = segments[5];  // 5
            4'h6 : seg1 = segments[6];  // 6
            4'h7 : seg1 = segments[7];  // 7
            4'h8 : seg1 = segments[8];  // 8
            4'h9 : seg1 = segments[9];  // 9
            default : seg1 = 7'b1111111; // Clear if not a valid digit
        endcase

        // Update display 2 based on player 1 score
        case (p1_score)
            4'h0 : seg2 = segments[0];  // 0
            4'h1 : seg2 = segments[1];  // 1
            4'h2 : seg2 = segments[2];  // 2
            4'h3 : seg2 = segments[3];  // 3
            4'h4 : seg2 = segments[4];  // 4
            4'h5 : seg2 = segments[5];  // 5
            4'h6 : seg2 = segments[6];  // 6
            4'h7 : seg2 = segments[7];  // 7
            4'h8 : seg2 = segments[8];  // 8
            4'h9 : seg2 = segments[9];  // 9
            default : seg2 = 7'b1111111; // Clear if not a valid digit
        endcase
    end
end

endmodule

