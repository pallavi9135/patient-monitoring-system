`timescale 1ns / 1ps

module threshold_checker (
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] heart_rate,
    input  wire [6:0] spo2,
    input  wire [7:0] temperature,
    output reg        normal,
    output reg        warning,
    output reg        critical
);

    wire hr_crit = (heart_rate < 8'd50) || (heart_rate > 8'd120);
    wire hr_warn = (heart_rate < 8'd60) || (heart_rate > 8'd100);

    wire sp_crit = (spo2 < 7'd90);
    wire sp_warn = (spo2 < 7'd95);

    wire t_crit = (temperature <= 8'd34) || (temperature >= 8'd39);
    wire t_warn = (temperature <= 8'd35) || (temperature >= 8'd38);

    wire any_crit = hr_crit | sp_crit | t_crit;
    wire any_warn = hr_warn | sp_warn | t_warn;

    always @(posedge clk) begin
        if (rst) begin
            normal   <= 1'b1;
            warning  <= 1'b0;
            critical <= 1'b0;
        end else begin
            critical <= any_crit;
            warning  <= ~any_crit & any_warn;
            normal   <= ~any_crit & ~any_warn;
        end
    end

endmodule

