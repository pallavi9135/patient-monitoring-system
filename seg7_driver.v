`timescale 1ns / 1ps

module seg7_driver (
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] heart_rate,
    input  wire [6:0] spo2,
    input  wire [7:0] temperature,
    input  wire [1:0] sel,        // 0=HR, 1=SpO2, 2=Temp
    output reg  [6:0] seg,        // active-low {g,f,e,d,c,b,a}
    output reg  [3:0] an          // active-low digit select
);

    reg [7:0] value;
    always @(*) begin
        case (sel)
            2'd0:    value = heart_rate;
            2'd1:    value = {1'b0, spo2};
            default: value = temperature;
        endcase
    end

    wire [3:0] hund = value / 100;
    wire [3:0] tens = (value % 100) / 10;
    wire [3:0] ones = value % 10;

    // refresh counter, ~190 Hz per digit
    reg [16:0] refresh;
    always @(posedge clk) begin
        if (rst) refresh <= 0;
        else     refresh <= refresh + 1;
    end
    wire [1:0] d = refresh[16:15];

    reg [3:0] digit;
    always @(*) begin
        case (d)
            2'd0: begin an = 4'b1110; digit = ones; end
            2'd1: begin an = 4'b1101; digit = tens; end
            2'd2: begin an = 4'b1011; digit = hund; end
            default: begin an = 4'b0111; digit = {2'b00, sel} + 4'd1; end
        endcase

        case (digit)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111;
        endcase
    end

endmodule
