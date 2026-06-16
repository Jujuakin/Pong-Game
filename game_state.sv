module game_state(
    input clk, clk_1ms, reset,                   // Input signals
    input [3:0] p1_score, p2_score,              // Player scores
    input [59:0] timer,                          // Timer value
    output reg [1:0] game_state                  // Output game state
    );

    // Constants for game states
    logic [3:0] win = 4'b1001;                    // Number of goals to win
    logic [1:0] playing = 2'b01;                  // Playing state
    logic [1:0] p1win = 2'b10;                    // Player 1 win state
    logic [1:0] p2win = 2'b11;                    // Player 2 win state
    
    // Always block triggered on the positive edge of the clock
    always_ff @ (posedge clk)
    begin
        // Reset the game state if reset signal is asserted
        if (!reset)
            game_state = 0;
        else 
        begin
            // Check if the timer has exceeded 60 units
            if (timer > 60)
            begin
                // Determine the game state based on player scores
                if (p1_score > p2_score)
                    game_state = p1win;          // Player 1 won
                else if (p1_score == p2_score)
                    game_state = playing;         // Still playing
                else
                    game_state = p2win;          // Player 2 won
            end
            // Check if any player has reached the winning score
            else if (p1_score == win)
                game_state = p1win;              // Player 1 won
            else if (p2_score == win)
                game_state = p2win;              // Player 2 won
            else 
                game_state = playing;            // Still playing
        end
    end

endmodule
