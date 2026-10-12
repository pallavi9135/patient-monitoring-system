`timescale 1ns / 1ps

module alarm_fsm #(
    parameter DELAY = 2   // critical itne tick tak rahe tabhi alarm
)(
    input  wire clk,
    input  wire rst,
    input  wire tick_1hz,
    input  wire normal,
    input  wire warning,
    input  wire critical,
    output wire led_normal,
    output wire led_warning,
    output wire led_critical,
    output wire alarm
);
    localparam S_NORMAL = 2'd0,
               S_WARN   = 2'd1,
               S_CRIT   = 2'd2;

    reg [1:0] state, next_state;
    reg [3:0] crit_cnt;
    reg       blink;

    // critical kitne tick se lagatar hai
    always @(posedge clk) begin
        if (rst || !critical)
            crit_cnt <= 0;
        else if (tick_1hz && crit_cnt < DELAY)
            crit_cnt <= crit_cnt + 1;
    end

    // 1 Hz blink
    always @(posedge clk) begin
        if (rst)           blink <= 0;
        else if (tick_1hz) blink <= ~blink;
    end

    // next state
    always @(*) begin
        if (critical && crit_cnt >= DELAY) next_state = S_CRIT;
        else if (critical || warning)      next_state = S_WARN;
        else                               next_state = S_NORMAL;
    end

    always @(posedge clk) begin
        if (rst) state <= S_NORMAL;
        else     state <= next_state;
    end

    assign led_normal   = (state == S_NORMAL);
    assign led_warning  = (state == S_WARN);
    assign led_critical = (state == S_CRIT);
    assign alarm        = (state == S_CRIT) & blink;
endmodule