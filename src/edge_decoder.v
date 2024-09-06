
module edge_decoder (
    input wire clk,               // Clock signal
    input wire reset,             // Reset signal
    input wire [8:0] in_signals,  // 9 input signals
    output reg [3:0] event_num    // 4-bit output representing detected event
);

    // Registers to hold the previous state of the input signals
    //reg [8:0] prev_signals;

    // Edge detection logic
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            //prev_signals <= 9'b0;
            event_num <= 4'd0;
        end else begin
            //prev_signals <= in_signals; // Store the previous input states

            // Check for rising edge on each input signal
            if (in_signals[0])      event_num <= 4'd0;
            else if (in_signals[1]) event_num <= 4'd1;
            else if (in_signals[2]) event_num <= 4'd2;
            else if (in_signals[3]) event_num <= 4'd3;
            else if (in_signals[4]) event_num <= 4'd4;
            else if (in_signals[5]) event_num <= 4'd5;
            else if (in_signals[6]) event_num <= 4'd6;
            else if (in_signals[7]) event_num <= 4'd7;
            else if (in_signals[8]) event_num <= 4'd8;
            else event_num <= 4'd0; // No edge detected
        end
    end
endmodule
