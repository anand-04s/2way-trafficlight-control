// traffic_tb.v - Testbench for traffic_controller
`timescale 1ns/1ps

module traffic_tb;

    reg clk;
    reg rst;
    wire [2:0] ns_light;
    wire [2:0] ew_light;

    // Instantiate the DUT
    traffic_controller #(
        .GREEN_CYCLES(10),
        .YELLOW_CYCLES(5),
        .ALLRED_CYCLES(3)
    ) uut (
        .clk(clk),
        .rst(rst),
        .ns_light(ns_light),
        .ew_light(ew_light)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        clk = 0;
        rst = 1;
        #20 rst = 0;

        // Run for enough time to complete several cycles
        #500 $finish;
    end

    // Generate waveform
    initial begin
        $dumpfile("traffic_tb.vcd");
        $dumpvars(0, traffic_tb);
    end

    // Display outputs in console
    initial begin
        $display("Time\tNS\tEW");
        $monitor("%0t\t%b\t%b", $time, ns_light, ew_light);
    end

endmodule