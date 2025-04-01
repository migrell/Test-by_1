// Down Counter with FND Display (9999-0000)
// Clock divider generates 0.1 second interval
// Counts down from 9999 to 0000 and wraps back to 9999

module down_counter(
    input wire clk,         // System Clock (ex: 50MHz)
    input wire rst_n,       // Active-Low Reset
    input wire mode_sw,     // Mode Switch Input (0:Up, 1:Down)
    output reg [6:0] fnd_seg, // 7-Segment Data
    output reg [3:0] fnd_sel  // 7-Segment Select
);

    // Parameters
    parameter CLK_FREQ = 50_000_000; // 50 MHz 
    parameter COUNT_FREQ = 10;       // 0.1 second (10 Hz)

    // Internal signals
    reg [31:0] clk_cnt;
    reg clk_100ms;
    reg [3:0] digit1, digit2, digit3, digit4; // 4 digits for 9999-0000
    reg [3:0] display_digit;
    reg [1:0] digit_sel;
    reg [16:0] fnd_cnt; // 변수 먼저 선언
    
    // Initial values - starting from 9999 for down counter
    initial begin
        clk_cnt <= 0;
        clk_100ms <= 0;
        digit1 <= 9;
        digit2 <= 9;
        digit3 <= 9;
        digit4 <= 9;
        fnd_cnt <= 0;
        digit_sel <= 0;
    end
    
    // Clock divider - generates 0.1 second clock
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            clk_cnt <= 0;
            clk_100ms <= 0;
        end else begin
            if (clk_cnt >= (CLK_FREQ / COUNT_FREQ / 2) - 1) begin
                clk_cnt <= 0;
                clk_100ms <= ~clk_100ms;
            end else begin
                clk_cnt <= clk_cnt + 1;
            end
        end
    end
    
    // Counter logic - Down Counter
    always @(posedge clk_100ms or posedge rst_n) begin
        if (rst_n) begin
            // Initialize to 9999 for down counter
            digit1 <= 9;
            digit2 <= 9;
            digit3 <= 9;
            digit4 <= 9;
        end else if (mode_sw) begin  // 스위치가 1일 때만 다운카운터 동작
            // Down counting mode
            if (digit1 == 0) begin
                digit1 <= 9;
                if (digit2 == 0) begin
                    digit2 <= 9;
                    if (digit3 == 0) begin
                        digit3 <= 9;
                        if (digit4 == 0) begin
                            // Wrap around to 9999 when reaching 0000
                            digit4 <= 9;
                        end else begin
                            digit4 <= digit4 - 1;
                        end
                    end else begin
                        digit3 <= digit3 - 1;
                    end
                end else begin
                    digit2 <= digit2 - 1;
                end
            end else begin
                digit1 <= digit1 - 1;
            end
        end
    end
    
    // FND display multiplexing - cycles through digits at high frequency
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            fnd_cnt <= 0;
            digit_sel <= 0;
        end else begin
            if (fnd_cnt >= 50000) begin  // control refresh rate (ex: ~1kHz per digit)
                fnd_cnt <= 0;
                if (digit_sel == 3)
                    digit_sel <= 0;
                else
                    digit_sel <= digit_sel + 1;
            end else begin
                fnd_cnt <= fnd_cnt + 1;
            end
        end
    end
    
    // Digit selector
    always @(*) begin
        case (digit_sel)
            2'b00: begin
                display_digit = digit1;
                fnd_sel = 4'b1110;  // rightmost digit active
            end
            2'b01: begin
                display_digit = digit2;
                fnd_sel = 4'b1101;
            end
            2'b10: begin
                display_digit = digit3;
                fnd_sel = 4'b1011;
            end
            2'b11: begin
                display_digit = digit4;
                fnd_sel = 4'b0111;  // leftmost digit active
            end
        endcase
    end
    
    // 7-segment decoder
    always @(*) begin
        case (display_digit)
            4'h0: fnd_seg = 7'b1000000;  // 0
            4'h1: fnd_seg = 7'b1111001;  // 1
            4'h2: fnd_seg = 7'b0100100;  // 2
            4'h3: fnd_seg = 7'b0110000;  // 3
            4'h4: fnd_seg = 7'b0011001;  // 4
            4'h5: fnd_seg = 7'b0010010;  // 5
            4'h6: fnd_seg = 7'b0000010;  // 6
            4'h7: fnd_seg = 7'b1111000;  // 7
            4'h8: fnd_seg = 7'b0000000;  // 8
            4'h9: fnd_seg = 7'b0010000;  // 9
            default: fnd_seg = 7'b1111111; // blank
        endcase
    end
    
endmodule