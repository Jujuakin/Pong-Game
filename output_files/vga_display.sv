module vga_display(
    input logic clk, reset, sw1,            // Input signals
    input logic [9:0] x, y,                 // Position of point
    input logic video_on,                   // Video enable signal
    output logic [11:0] rgb,                // Output RGB color
    input logic clk_1ms,                    // 1ms clock signal
    input logic paddle1_on, paddle2_on, puck_on,  // Control signals for paddle and puck
    input logic [11:0] rgb_paddle1, rgb_paddle2, rgb_puck,  // RGB values for paddle and puck
    input logic [1:0] game_state,           // Game state
    input logic [3:0] p1_score, p2_score,   // Player scores
    output logic [7:0] score1,              // Output for player 1 score
    output logic [7:0] score2               // Output for player 2 score
);

    // Internal signals and parameters
    logic [11:0] rgb_reg;
    localparam int Hmax = 640;
    localparam int Vmax = 480;
    localparam int X_blocksize = 50;
    localparam int Y_blocksize = 50;
    logic [9:0] x_block_left = X_blocksize / 2;  // Starting position of left block
    logic [9:0] x_block_right = Hmax - X_blocksize / 2;  // Starting position of right block
    logic [9:0] y_block = Vmax - Y_blocksize / 2;  // Starting position of both blocks
    logic [3:0] last_p1_score = 0, last_p2_score = 0;
    logic [11:0] corner_color_left = {4'h6, 8'hF9};  // Light blue
    logic [11:0] corner_color_right = {4'h6, 8'hF9};  // Light blue

    // Always block triggered on the positive edge of the clock
    always_ff @(posedge clk) begin
        if (!reset) begin
            // Reset all values
            rgb_reg <= 12'h000;
            corner_color_left <= 12'h00F;
            corner_color_right <= 12'h00F;
            last_p1_score <= 0;
            last_p2_score <= 0;
        end else begin
            // Update RGB based on game state
            if (game_state == 2'b01) begin
                if (paddle1_on) begin
                    rgb_reg <= rgb_paddle1;
                end else if (paddle2_on) begin
                    rgb_reg <= rgb_paddle2;
                end else if (puck_on) begin
                    rgb_reg <= rgb_puck;
                end else begin
                    rgb_reg <= 12'h000;
                end
            end else if (game_state == 2'b10) begin
                rgb_reg <= rgb_paddle1;
            end else if (game_state == 2'b11) begin
                rgb_reg <= rgb_paddle2;
            end else begin
                rgb_reg <= 12'h000;
            end

            // Update corner colors based on score change
            if (p1_score != last_p1_score) begin
                corner_color_left <= {corner_color_left[11:8], corner_color_left[7:2] + 4'd1}; // Increase blue component by 1
                last_p1_score <= p1_score;
            end

            if (p2_score != last_p2_score) begin
                corner_color_right <= {corner_color_right[11:8], corner_color_right[7:2] + 4'd1}; // Increase blue component by 1
                last_p2_score <= p2_score;
            end

            // Update color of blocks and slow down darkening of blue blocks
            if (sw1 == 1) begin
                // Set the color of the left block
                if (x < X_blocksize && y >= Vmax - Y_blocksize) begin
                    rgb_reg[11:0] <= corner_color_left;
                end

                // Set the color of the right block
                if (x >= Hmax - X_blocksize && y >= Vmax - Y_blocksize) begin
                    rgb_reg[11:0] <= corner_color_right;
                end

                // Slow down darkening of blue blocks
                if (corner_color_right[7:4] > 4'd1) begin
                    corner_color_right[7:4] <= corner_color_right[7:4] - 4'd1;
                end

                if (corner_color_left[7:4] > 4'd1) begin
                    corner_color_left[7:4] <= corner_color_left[7:4] - 4'd1;
                end
            end
        end
    end

    // Assign RGB output based on video enable signal
    assign rgb = (video_on) ? rgb_reg : 12'b0;

endmodule

