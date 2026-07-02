`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2026 04:56:55 PM
// Design Name: 
// Module Name: Lab3TestBench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Lab3TestBench(
    );
    reg clk;
    reg rst;
    reg [15:0] SW;
    reg BTNU, BTND, BTNL, BTNR;

    // Output from the Top-Level Module
    wire LED0;

    // Instantiate the Top-Level Design Under Test (DUT)
    Mux_16x1Lab dut (
        .clk(clk),
        .rst(rst),
        .SW(SW),
        .BTNU(BTNU),
        .BTND(BTND),
        .BTNL(BTNL),
        .BTNR(BTNR),
        .LED0(LED0)
    );

    // Generate a 100 MHz clock (10ns period)
    always begin
        #5 clk = ~clk;
    end

    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        SW = 16'b0;
        BTNU = 0; BTND = 0; BTNL = 0; BTNR = 0;

        // Apply Reset for 4 clock cycles
        #40;
        rst = 0;
        #20;

        // Setup a distinct bit pattern on the 16 slide switches
        // SW[0]=1, SW[1]=0, SW[2]=1, SW[3]=0 ... SW[15]=0
        SW = 16'b0000000000000101; 
        #20;

        // --- TEST 1: Default Selection (sel = 4'b0000) ---
        // Out should select SW[0], which is 1. LED0 should be 1.
        #40;

        // --- TEST 2: Toggle sel[0] using BTND ---
        // Pulse BTND high for enough clock cycles to bypass the 3-cycle debouncer
        $display("Pressing BTND to toggle sel[0]...");
        BTND = 1;
        #50; // Hold for 5 clock cycles
        BTND = 0;
        #50; // Wait for debounce release 
        // New sel = 4'b0001. Out selects SW[1] (which is 0). LED0 should drop to 0.

        // --- TEST 3: Toggle sel[1] using BTNR ---
        $display("Pressing BTNR to toggle sel[1]...");
        BTNR = 1;
        #50;
        BTNR = 0;
        #50;
        // New sel = 4'b0011. Out selects SW[3] (which is 0). LED0 should remain 0.

        // --- TEST 4: Toggle sel[0] back to 0 using BTND ---
        $display("Pressing BTND again to clear sel[0]...");
        BTND = 1;
        #50;
        BTND = 0;
        #50;
        // New sel = 4'b0010. Out selects SW[2] (which is 1). LED0 should go back to 1.

        // Change SW inputs live to ensure the selected path responds dynamically
        $display("Changing SW[2] live to 0...");
        SW[2] = 0; 
        #20; // LED0 should immediately drop to 0

        // End simulation
        $display("Simulation finished.");
        $finish;
    end

endmodule
