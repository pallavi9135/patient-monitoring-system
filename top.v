`timescale 1ns / 1ps

module top (
    input  wire        clk,        // 100 MHz
    input  wire        btnU,       // reset
    input  wire        btnL,       // load HR
    input  wire        btnC,       // load SpO2
    input  wire        btnR,       // load Temp
    input  wire [15:0] sw,
    output wire [3:0]  led,        // 0 normal, 1 warning, 2 critical, 3 alarm
    output wire [6:0]  seg,
    output wire [3:0]  an,
    output wire        dp
);

    wire rst = btnU;
    assign dp = 1'b1;              // decimal point off

    // Input registers
    reg [7:0] heart_rate;
    reg [6:0] spo2;
    reg [7:0] temperature;

    always @(posedge clk) begin
        if (rst) begin
            heart_rate  <= 8'd75;
            spo2        <= 7'd98;
            temperature <= 8'd37;
        end else begin
            if (btnL) heart_rate  <= sw[7:0];
            if (btnC) spo2        <= sw[6:0];
            if (btnR) temperature <= sw[7:0];
        end
    end

    wire normal, warning, critical, tick_1hz;
    wire led_n, led_w, led_c, alarm;

    threshold_checker u_chk (
        .clk(clk), .rst(rst),
        .heart_rate(heart_rate), .spo2(spo2), .temperature(temperature),
        .normal(normal), .warning(warning), .critical(critical)
    );

    clk_divider #(.DIV(100_000_000)) u_div (
        .clk(clk), .rst(rst), .tick_1hz(tick_1hz)
    );

    alarm_fsm #(.DELAY(2)) u_fsm (
        .clk(clk), .rst(rst), .tick_1hz(tick_1hz),
        .normal(normal), .warning(warning), .critical(critical),
        .led_normal(led_n), .led_warning(led_w),
        .led_critical(led_c), .alarm(alarm)
    );

    seg7_driver u_seg (
        .clk(clk), .rst(rst),
        .heart_rate(heart_rate), .spo2(spo2), .temperature(temperature),
        .sel(sw[15:14]),
        .seg(seg), .an(an)
    );

    assign led = {alarm, led_c, led_w, led_n};

endmodule