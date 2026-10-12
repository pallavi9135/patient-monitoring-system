`timescale 1ns / 1ps

module clk_divider #(
    parameter DIV = 100_000_000   // 100 MHz -> 1 Hz
)(
    input  wire clk,
    input  wire rst,
    output reg  tick_1hz
);
    reg [26:0] cnt;

    always @(posedge clk) begin
        if (rst) begin
            cnt      <= 0;
            tick_1hz <= 0;
        end else if (cnt == DIV - 1) begin
            cnt      <= 0;
            tick_1hz <= 1;
        end else begin
            cnt      <= cnt + 1;
            tick_1hz <= 0;
        end
    end
endmodule
