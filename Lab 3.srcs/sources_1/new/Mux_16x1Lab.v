`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2026 02:38:48 PM
// Design Name: 
// Module Name: Mux_16x1
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

module mux2x1 (
    input a, b,
    input sel,
    output y
    );
    wire nsel, a1, b1;
    not (nsel, sel);
    and (a1, a, nsel);
    and (b1, b, sel);
    or (y, a1, b1);
endmodule

module mux16x1 (
    input [15:0] in,
    input [3:0] sel,
    output out
    );
    wire [15:0] level1;
    wire [7:0] level2;
    wire [3:0] level3;
    genvar i;
    generate
    for (i = 0; i < 8; i = i + 1)begin
        mux2x1 m1 (.a(in[2*i]), .b(in[2*i+1]), .sel(sel[0]), .y(level1[i]));
    end
    for (i = 0; i < 4; i = i + 1)begin
        mux2x1 m2 (.a(level1[2*i]), .b(level1[2*i+1]), .sel(sel[1]), .y(level2[i]));
    end
    for (i = 0; i < 2; i = i + 1)begin
        mux2x1 m3 (.a(level2[2*i]), .b(level2[2*i+1]), .sel(sel[2]), .y(level3[i]));
    end
    mux2x1 m4 (.a(level3[0]), .b(level3[1]), .sel(sel[3]), .y(out));
    endgenerate
endmodule

module debounce (
    input clk,
    input btn_in,
    output reg btn_clean
    );
    reg [2:0] shift_reg;
    always @(posedge clk) begin
        shift_reg <= {shift_reg[1:0], btn_in};
        if (shift_reg == 3'b111) btn_clean <= 1;
        else if (shift_reg == 3'b000) btn_clean <= 0;
    end
endmodule

module toggle_switch (
    input clk,
    input rst,
    input btn_raw,
    output reg state
    );
    wire btn_clean;
    reg btn_prev;
    debounce db (.clk(clk), .btn_in(btn_raw), .btn_clean(btn_clean));
    always @(posedge clk) begin
        if (rst) begin
            state <= 0;
            btn_prev <= 0;
        end else begin
            if (btn_clean && !btn_prev)
            state <= ~state;
            btn_prev <= btn_clean;
        end
    end
endmodule

module Mux_16x1Lab(
    input clk,
    input rst,
    input [15:0] SW,
    input BTNU, BTND, BTNL, BTNR,
    output LED0
    );
    wire [3:0] sel;
    toggle_switch t0 (.clk(clk), .rst(rst), .btn_raw(BTND), .state(sel[0]));
    toggle_switch t1 (.clk(clk), .rst(rst), .btn_raw(BTNR), .state(sel[1]));
    toggle_switch t2 (.clk(clk), .rst(rst), .btn_raw(BTNL), .state(sel[2]));
    toggle_switch t3 (.clk(clk), .rst(rst), .btn_raw(BTNU), .state(sel[3]));
    mux16x1 mux (.in(SW), .sel(sel), .out(LED0));
endmodule
