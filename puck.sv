module puck (
    input logic clk, clk_1ms, reset,                     // Input signals
    input logic [9:0] x, y,                               // Position of the puck
    output logic puck_on,                                 // Output signal indicating puck presence
    output logic [11:0] rgb_puck,                         // Output RGB color of the puck
    input logic [9:0] x_paddle1, x_paddle2, y_paddle1, y_paddle2,  // Positions of paddles
    output reg [3:0] p1_score, p2_score,                  // Player scores
    input logic [1:0] game_state                          // Game state
);

    // Parameters defining display dimensions and puck/paddle sizes
    localparam int Hmax = 640;
    localparam int Vmax = 480;
    localparam int puck_width = 12;
    localparam int puck_height = 12;
    localparam int paddlewidth = 20;
    localparam int paddleheight = 80;

    // Direction of puck movement
    int dx = 1, dy = 1;

    // Registers to hold puck position
    logic [9:0] x_puck, y_puck;
        
    // Always block triggered on positive edge of 1ms clock
    always_ff @(posedge clk_1ms) begin
        if (!reset) begin
            // Reset puck position and scores
            x_puck <= Hmax/2;
            y_puck <= Vmax/2;
            p1_score <= 0;
            p2_score <= 0;    
        end
        else if (game_state == 2'b01) begin
            // Handle puck movement within boundaries and collisions
            if (y_puck == (puck_height/2)+1)    // Top boundary
                dy = -dy;
            if (y_puck == (Vmax-(puck_height/2)-1))    // Bottom boundary
                dy = -dy;

            // Handle paddle collisions
            if (x_puck > (x_paddle2-puck_width/2) && y_puck > (y_paddle2 - paddleheight/2) && y_puck < (y_paddle2 + paddleheight/2))
                dx = -dx;
            if (x_puck < (x_paddle1+puck_width/2) && y_puck > (y_paddle1 - paddleheight/2) && y_puck < (y_paddle1 + paddleheight/2))
                dx = -dx;
            
            // Check for score update and reset puck position
            if (x_puck == (Hmax -puck_width/2)) begin // Paddle2 missed the puck
                x_puck <= Hmax/2;
                y_puck <= Vmax/2;
                dy = -dy;
                dx = -dx; // Change the direction of puck
                p1_score <= p1_score + 1;
            end
            else if (x_puck == 0) begin // Paddle1 missed the puck
                x_puck <= Hmax/2;
                y_puck <= Vmax/2;
                dy = -dy;
                dx = -dx;
                p2_score <= p2_score + 1;
            end
            else begin
                // Move the puck
                x_puck <= x_puck + dx;
                y_puck <= y_puck - dy;    
            end
        end
        else begin // If game is not being played, maintain puck position
            x_puck <= x_puck;
            y_puck <= y_puck;
        end    
    end
        
    // Assign puck_on signal based on puck position
    assign puck_on = (x >= x_puck-(puck_width/2) && x <= x_puck+(puck_width/2) && y >= y_puck-(puck_height/2) && y <= y_puck+(puck_height/2)) ? 1'b1 : 1'b0;
    
    // Assign fixed RGB color to the puck
    assign rgb_puck = 12'b111111111111; // Silver = 12'b101110111011, skyblue=12'b100011001110, Gold =12'b111111010000
    
endmodule
