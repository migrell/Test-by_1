// Down Counter with FND Display (9999-0000)
// 100MHz Clock, Supports switching between Up and Down modes

module down_counter(
    input wire clk,         // 100MHz System Clock
    input wire rst_n,       // Active-Low Reset
    input wire mode_sw,     // Mode Switch Input (0:Up, 1:Down)
    input wire [3:0] current_digit1,   // Current up counter digits
    input wire [3:0] current_digit2,
    input wire [3:0] current_digit3,
    input wire [3:0] current_digit4,
    output reg [6:0] fnd_seg, // 7-Segment Data
    output reg [3:0] fnd_sel  // 7-Segment Select
);

    parameter CLK_FREQ = 100_000_000; // 100 MHz
    parameter COUNT_FREQ = 10;        // 0.1 second (10 Hz)
    parameter CLK_DIV_VALUE = CLK_FREQ / (COUNT_FREQ * 2);

    // Internal signals
    reg [31:0] clk_cnt;
    reg count_pulse;  // 0.1초마다 1클록 생성
    reg [3:0] digit1, digit2, digit3, digit4; // 4 digits for 9999-0000
    reg [3:0] display_digit;
    reg [1:0] digit_sel;
    reg [16:0] fnd_cnt;
    reg [3:0] saved_digit1, saved_digit2, saved_digit3, saved_digit4; // 저장된 값
    reg down_start;
    
    // 100MHz 클록 기반 클록 분주기 - 0.1초 클록 생성
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_cnt <= 0;
            count_pulse <= 0;
        end else begin
            if (clk_cnt >= CLK_DIV_VALUE - 1) begin
                clk_cnt <= 0;
                count_pulse <= 1;  // 0.1초마다 1클록 펄스 생성
            end else begin
                clk_cnt <= clk_cnt + 1;
                count_pulse <= 0;  // 다른 시간에는 0 유지
            end
        end
    end

    // Down Counter Logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        digit1 <= 0;
        digit2 <= 0;
        digit3 <= 0;
        digit4 <= 0;
        saved_digit1 <= 0;
        saved_digit2 <= 0;
        saved_digit3 <= 0;
        saved_digit4 <= 0;
        down_start <= 0;
    end else if (!down_start && mode_sw) begin
        // 다운 카운트 모드 첫 진입 시 현재 업카운터 값 그대로 표시
        digit1 <= current_digit1;
        digit2 <= current_digit2;
        digit3 <= current_digit3;
        digit4 <= current_digit4;
        saved_digit1 <= current_digit1;
        saved_digit2 <= current_digit2;
        saved_digit3 <= current_digit3;
        saved_digit4 <= current_digit4;
        down_start <= 1;
    end else if (mode_sw && down_start && count_pulse) begin
        // 다운 카운팅 로직
        if (digit1 > 0 || digit2 > 0 || digit3 > 0 || digit4 > 0) begin
            if (digit1 == 0) begin
                digit1 <= 9;
                if (digit2 == 0) begin
                    digit2 <= 9;
                    if (digit3 == 0) begin
                        digit3 <= 9;
                        digit4 <= digit4 - 1;
                    end else
                        digit3 <= digit3 - 1;
                end else
                    digit2 <= digit2 - 1;
            end else
                digit1 <= digit1 - 1;
        end else begin
            // 모든 자리가 0이 되면 초기 저장값으로 복원
            digit1 <= saved_digit1;
            digit2 <= saved_digit2;
            digit3 <= saved_digit3;
            digit4 <= saved_digit4;
        end
    end else if (!mode_sw) begin
        down_start <= 0;
    end
end

    // FND 디스플레이 멀티플렉싱
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fnd_cnt <= 0;
            digit_sel <= 0;
        end else begin
            if (fnd_cnt >= 50000) begin
                fnd_cnt <= 0;
                digit_sel <= digit_sel == 3 ? 0 : digit_sel + 1;
            end else begin
                fnd_cnt <= fnd_cnt + 1;
            end
        end
    end
    
    // 디지트 선택기
    always @(*) begin
        case (digit_sel)
            2'b00: begin
                display_digit = digit1;
                fnd_sel = 4'b1110;  // 가장 오른쪽 디지트
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
                fnd_sel = 4'b0111;  // 가장 왼쪽 디지트
            end
        endcase
    end
    
    // 7-세그먼트 디코더
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
            default: fnd_seg = 7'b1111111; // 공백
        endcase
    end
    
endmodule