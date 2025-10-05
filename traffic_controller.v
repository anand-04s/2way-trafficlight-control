// traffic_controller.v
// Simple 2-way traffic light controller (pure Verilog, synthesizable)

`timescale 1ns/1ps

module traffic_controller #(
    parameter GREEN_CYCLES  = 100,
    parameter YELLOW_CYCLES = 20,
    parameter ALLRED_CYCLES = 10
)(
    input  clk,
    input  rst,                 // synchronous active-high reset
    output reg [2:0] ns_light,  // {R, Y, G}
    output reg [2:0] ew_light   // {R, Y, G}
);

    // State encoding
    parameter S_NS_GREEN  = 3'd0;
    parameter S_NS_YELLOW = 3'd1;
    parameter S_ALL_RED_1 = 3'd2;
    parameter S_EW_GREEN  = 3'd3;
    parameter S_EW_YELLOW = 3'd4;
    parameter S_ALL_RED_2 = 3'd5;

    reg [2:0] state;
    reg [31:0] counter; // 32-bit counter for timing

    // Sequential logic
    always @(posedge clk) begin
        if (rst) begin
            state   <= S_NS_GREEN;
            counter <= 0;
        end else begin
            case (state)
                S_NS_GREEN: begin
                    if (counter >= GREEN_CYCLES - 1) begin
                        state   <= S_NS_YELLOW;
                        counter <= 0;
                    end else counter <= counter + 1;
                end

                S_NS_YELLOW: begin
                    if (counter >= YELLOW_CYCLES - 1) begin
                        state   <= S_ALL_RED_1;
                        counter <= 0;
                    end else counter <= counter + 1;
                end

                S_ALL_RED_1: begin
                    if (counter >= ALLRED_CYCLES - 1) begin
                        state   <= S_EW_GREEN;
                        counter <= 0;
                    end else counter <= counter + 1;
                end

                S_EW_GREEN: begin
                    if (counter >= GREEN_CYCLES - 1) begin
                        state   <= S_EW_YELLOW;
                        counter <= 0;
                    end else counter <= counter + 1;
                end

                S_EW_YELLOW: begin
                    if (counter >= YELLOW_CYCLES - 1) begin
                        state   <= S_ALL_RED_2;
                        counter <= 0;
                    end else counter <= counter + 1;
                end

                S_ALL_RED_2: begin
                    if (counter >= ALLRED_CYCLES - 1) begin
                        state   <= S_NS_GREEN;
                        counter <= 0;
                    end else counter <= counter + 1;
                end

                default: begin
                    state   <= S_NS_GREEN;
                    counter <= 0;
                end
            endcase
        end
    end

    // Combinational logic for light outputs
    always @(*) begin
        ns_light = 3'b100; // default: Red
        ew_light = 3'b100;

        case (state)
            S_NS_GREEN: begin
                ns_light = 3'b001; // Green
                ew_light = 3'b100; // Red
            end
            S_NS_YELLOW: begin
                ns_light = 3'b010; // Yellow
                ew_light = 3'b100; // Red
            end
            S_ALL_RED_1: begin
                ns_light = 3'b100;
                ew_light = 3'b100;
            end
            S_EW_GREEN: begin
                ns_light = 3'b100;
                ew_light = 3'b001;
            end
            S_EW_YELLOW: begin
                ns_light = 3'b100;
                ew_light = 3'b010;
            end
            S_ALL_RED_2: begin
                ns_light = 3'b100;
                ew_light = 3'b100;
            end
        endcase
    end

endmodule