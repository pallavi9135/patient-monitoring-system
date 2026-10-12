`timescale 1ns / 1ps

module threshold_checker_tb;

    reg        clk = 0;
    reg        rst = 1;
    reg  [7:0] heart_rate;
    reg  [6:0] spo2;
    reg  [7:0] temperature;
    wire       normal, warning, critical;

    threshold_checker dut (
        .clk(clk), .rst(rst),
        .heart_rate(heart_rate), .spo2(spo2), .temperature(temperature),
        .normal(normal), .warning(warning), .critical(critical)
    );

    always #5 clk = ~clk;   // 100 MHz

    task check(input [7:0] hr, input [6:0] sp, input [7:0] t,
               input exp_n, input exp_w, input exp_c);
        begin
            heart_rate = hr; spo2 = sp; temperature = t;
            repeat (2) @(posedge clk);
            #1;
            if ({normal, warning, critical} === {exp_n, exp_w, exp_c})
                $display("PASS: HR=%0d SpO2=%0d T=%0d -> N=%b W=%b C=%b",
                          hr, sp, t, normal, warning, critical);
            else
                $display("FAIL: HR=%0d SpO2=%0d T=%0d -> N=%b W=%b C=%b",
                          hr, sp, t, normal, warning, critical);
        end
    endtask

    initial begin
        heart_rate = 75; spo2 = 98; temperature = 37;
        repeat (3) @(posedge clk);
        rst = 0;

        //     HR   SpO2  Temp   N  W  C
        check( 75,   98,   37,   1, 0, 0);  // sab normal
        check(105,   98,   37,   0, 1, 0);  // HR warning
        check( 75,   92,   37,   0, 1, 0);  // SpO2 warning
        check( 75,   98,   38,   0, 1, 0);  // Temp warning
        check(130,   98,   37,   0, 0, 1);  // HR critical
        check( 75,   85,   37,   0, 0, 1);  // SpO2 critical
        check( 75,   98,   40,   0, 0, 1);  // Temp critical
        check(105,   85,   37,   0, 0, 1);  // warning + critical = critical
        check( 45,   98,   37,   0, 0, 1);  // HR kam (critical)

        $display("Simulation complete");
        $finish;
    end

endmodule
