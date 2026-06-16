module clock_divider(
    input clk,                  // Input clock signal
    output logic clk_1ms = 0   // Output clock divided by 1ms
    );
    
    // Counter to keep track of the number of clock cycles
    logic [27:0] i = 0;
    
    // Always block sensitive to the positive edge of the clock
    always_ff @ (posedge clk)
    begin
        // Check if the counter has reached the desired number of clock cycles
        if (i == 124999) // Approximately 1ms (given a 100MHz clock)
        begin
            // Reset the counter
            i <= 0;
            // Toggle the 1ms clock signal
            clk_1ms = ~clk_1ms;
        end
        else
            // Increment the counter if the desired number of clock cycles hasn't been reached yet
            i <= i + 1;
    end
    
endmodule
