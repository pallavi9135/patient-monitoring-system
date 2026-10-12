`timescale 1ns / 1ps

module core_tb;

    reg        clk = 0;
    reg        rst = 1;
    reg  [7:0] heart_rate = 75;
    reg  [6:0] spo2 = 98;
    reg  [7:0] temperature = 37;

    wire normal, warning, critical;
    wire tick_1hz;
    wire led_normal, led_warning, led_critical, alarm;

    threshold_checker u_chk (
        .clk(clk), .rst(rst),
        .heart_rate(heart_rate), .spo2(spo2), .temperature(temperature),
        .normal(normal), .warning(warning), .critical(critical)
    );

    clk_divider #(.DIV(10)) u_div (   // chhota DIV, taaki sim tez chale
        .clk(clk), .rst(rst), .tick_1hz(tick_1hz)
    );

    alarm_fsm #(.DELAY(2)) u_fsm (
        .clk(clk), .rst(rst), .tick_1hz(tick_1hz),
        .normal(normal), .warning(warning), .critical(critical),
        .led_normal(led_normal), .led_warning(led_warning),
        .led_critical(led_critical), .alarm(alarm)
    );

    always #5 clk = ~clk;

    initial begin
        $monitor("t=%0t N=%b W=%b C=%b | LED n=%b w=%b c=%b alarm=%b",
                 $time, normal, warning, critical,
                 led_normal, led_warning, led_critical, alarm);

        #30 rst = 0;

        // 1. Normal
        #500;
        // 2. Warning (HR 105)
        heart_rate = 105;  #500;
        // 3. Critical (SpO2 85), lagatar: WARN -> CRIT, phir blink
        spo2 = 85;         #1500;
        // 4. Wapas normal
        heart_rate = 75; spo2 = 98;  #500;
        // 5. Chhota spike (80 ns): alarm nahi bajna chahiye
        spo2 = 85;         #80;
        spo2 = 98;         #500;

        $display("Simulation complete");
        $finish;
    end

endmodule

