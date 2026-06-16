module Timer(
    input logic reset,                       // Reset signal
    input clk,                               // Clock input
    output logic [59:0] timer,               // Output timer value
    output logic [6:0] seg_left,             // Output for the left segment display
    output logic [6:0] seg_right             // Output for the right segment display
);

// Counter to keep track of time
logic [31:0] count = 32'd0;

// Segments for displaying digits 0-9
logic [6:0] segments [0:9];

// Initialization block to assign segment values
initial begin
    seg_left <= 7'b1111111;                 // Clear left display
    seg_right <= 7'b1111111;                // Clear right display
    segments[0] = 7'b1000000;               // 0
    segments[1] = 7'b1111001;               // 1
    segments[2] = 7'b0100100;               // 2
    segments[3] = 7'b0110000;               // 3
    segments[4] = 7'b0011001;               // 4
    segments[5] = 7'b0010010;               // 5
    segments[6] = 7'b0000010;               // 6
    segments[7] = 7'b1111000;               // 7
    segments[8] = 7'b0000000;               // 8
    segments[9] = 7'b0011000;               // 9
end

// Always block to update timer and segment display values
always_ff @(posedge clk) begin
    count <= count + 32'd1;                 // Increment the count on every clock cycle
    
    // Check if reset signal is active
    if(~reset) begin
        seg_left <= 7'b1111111;             // Clear left display
        seg_right <= 7'b1111111;            // Clear right display
        timer <= 0;                         // Reset timer
        count <= 32'd0;                     // Reset count
    end
     
    // Check if count has reached 50 million (1 second)
    if(count == 32'd50000000) begin
        timer <= timer + 1;                 // Increment timer by 1
        count <= 0;                         // Reset count
        
        // Check if timer has exceeded 60 seconds
        if(timer > 60) begin
            timer <= 0;                     // Reset timer
            seg_left <= 7'b1111111;         // Clear left display
            seg_right <= 7'b1111111;        // Clear right display
        end
        
        // Display the appropriate segments based on the timer value
        case(timer)
            // Each case represents a specific timer value and its corresponding segment display
32'd0: begin seg_left <= segments[0]; seg_right <= segments[1];end
			32'd1: begin seg_left <= segments[0]; seg_right <= segments[2];end
			32'd2: begin seg_left <= segments[0]; seg_right <= segments[3];end
			32'd3: begin seg_left <= segments[0]; seg_right <= segments[4];end
			32'd4: begin seg_left <= segments[0]; seg_right <= segments[5];end
			32'd5: begin seg_left <= segments[0]; seg_right <= segments[6];end
			32'd6: begin seg_left <= segments[0]; seg_right <= segments[7];end
			32'd7: begin seg_left <= segments[0]; seg_right <= segments[8];end
			32'd8: begin seg_left <= segments[0]; seg_right <= segments[9];end
			32'd9: begin seg_left <= segments[1]; seg_right <= segments[0];end
			32'd10: begin seg_left <= segments[1]; seg_right <= segments[1];end
			32'd11: begin seg_left <= segments[1]; seg_right <= segments[2];end
			32'd12: begin seg_left <= segments[1]; seg_right <= segments[3];end
			32'd13: begin seg_left <= segments[1]; seg_right <= segments[4];end
			32'd14: begin seg_left <= segments[1]; seg_right <= segments[5];end
			32'd15: begin seg_left <= segments[1]; seg_right <= segments[6];end
			32'd16: begin seg_left <= segments[1]; seg_right <= segments[7];end
			32'd17: begin seg_left <= segments[1]; seg_right <= segments[8];end
			32'd18: begin seg_left <= segments[1]; seg_right <= segments[9];end
			32'd19: begin seg_left <= segments[2]; seg_right <= segments[0];end
			32'd20: begin seg_left <= segments[2]; seg_right <= segments[1];end
			32'd21: begin seg_left <= segments[2]; seg_right <= segments[2];end
			32'd22: begin seg_left <= segments[2]; seg_right <= segments[3];end
			32'd23: begin seg_left <= segments[2]; seg_right <= segments[4];end
			32'd24: begin seg_left <= segments[2]; seg_right <= segments[5];end
			32'd25: begin seg_left <= segments[2]; seg_right <= segments[6];end
			32'd26: begin seg_left <= segments[2]; seg_right <= segments[7];end
			32'd27: begin seg_left <= segments[2]; seg_right <= segments[8];end
			32'd28: begin seg_left <= segments[2]; seg_right <= segments[9];end
			32'd29: begin seg_left <= segments[3]; seg_right <= segments[0];end
			32'd30: begin seg_left <= segments[3]; seg_right <= segments[1];end
			32'd31: begin seg_left <= segments[3]; seg_right <= segments[2];end
			32'd32: begin seg_left <= segments[3]; seg_right <= segments[3];end
			32'd33: begin seg_left <= segments[3]; seg_right <= segments[4];end
			32'd34: begin seg_left <= segments[3]; seg_right <= segments[5];end
			32'd35: begin seg_left <= segments[3]; seg_right <= segments[6];end
			32'd36: begin seg_left <= segments[3]; seg_right <= segments[7];end
			32'd37: begin seg_left <= segments[3]; seg_right <= segments[8];end
			32'd38: begin seg_left <= segments[3]; seg_right <= segments[9];end
			32'd39: begin seg_left <= segments[4]; seg_right <= segments[0];end
			32'd40: begin seg_left <= segments[4]; seg_right <= segments[1];end
			32'd41: begin seg_left <= segments[4]; seg_right <= segments[2];end
			32'd42: begin seg_left <= segments[4]; seg_right <= segments[3];end
			32'd43: begin seg_left <= segments[4]; seg_right <= segments[4];end
			32'd44: begin seg_left <= segments[4]; seg_right <= segments[5];end
			32'd45: begin seg_left <= segments[4]; seg_right <= segments[6];end
			32'd46: begin seg_left <= segments[4]; seg_right <= segments[7];end
			32'd47: begin seg_left <= segments[4]; seg_right <= segments[8];end
			32'd48: begin seg_left <= segments[4]; seg_right <= segments[9];end
			32'd49: begin seg_left <= segments[5]; seg_right <= segments[0];end
			32'd50: begin seg_left <= segments[5]; seg_right <= segments[1];end
			32'd51: begin seg_left <= segments[5]; seg_right <= segments[2];end
			32'd52: begin seg_left <= segments[5]; seg_right <= segments[3];end
			32'd53: begin seg_left <= segments[5]; seg_right <= segments[4];end
			32'd54: begin seg_left <= segments[5]; seg_right <= segments[5];end
			32'd55: begin seg_left <= segments[5]; seg_right <= segments[6];end
			32'd56: begin seg_left <= segments[5]; seg_right <= segments[7];end
			32'd57: begin seg_left <= segments[5]; seg_right <= segments[8];end
			32'd58: begin seg_left <= segments[5]; seg_right <= segments[9];end
			32'd59: begin seg_left <= segments[6]; seg_right <= segments[0];end
		endcase
    end
end

endmodule
