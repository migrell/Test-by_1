// Up/Down Counter with FND Display (0000-9999)
// Clock divider generates 0.1 second interval
// MODE 0: Up Counter (0,1,2,...)
// Resets and starts counting automatically when power is applied

module updown_counter(
    input wire clk,         // System Clock (ex: 50MHz)
    input wire rst_n,       // Active-Low Reset
    input wire mode_sw,     // Mode Switch (0:Up, 1:Down)
    output reg [6:0] fnd_seg, // 7-Segment Data
    output reg [3:0] fnd_sel,  // 7-Segment Select
    output wire [3:0] digit1,   // Current digit outputs
    output wire [3:0] digit2,
    output wire [3:0] digit3,
    output wire [3:0] digit4
);

    // Parameters
    parameter CLK_FREQ = 50_000_000; // 50 MHz 
    parameter COUNT_FREQ = 10;       // 0.1 second (10 Hz)
    parameter CLK_DIV_VALUE = CLK_FREQ / (COUNT_FREQ * 2);

    // Internal signals
    reg [31:0] clk_cnt;
    reg count_pulse;  // 0.1초마다 1클록 생성
    reg [3:0] current_digit1, current_digit2, current_digit3, current_digit4; // 4 digits for 0000-9999
    reg [3:0] display_digit;
    reg [1:0] digit_sel;
    reg [16:0] fnd_cnt;
    reg mode_sw_reg1, mode_sw_reg2;
    reg mode;
    
    // Assign current digits to output
    assign digit1 = current_digit1;
    assign digit2 = current_digit2;
    assign digit3 = current_digit3;
    assign digit4 = current_digit4;
    
    // Initial values
    initial begin
        clk_cnt <= 0;
        count_pulse <= 0;
        current_digit1 <= 0;
        current_digit2 <= 0;
        current_digit3 <= 0;
        current_digit4 <= 0;
        fnd_cnt <= 0;
        digit_sel <= 0;
        mode_sw_reg1 <= 0;
        mode_sw_reg2 <= 0;
        mode <= 0;
    end
    
    // 개선된 클록 분주기 - 0.1초 간격 클록 생성
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
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
    
    // 모드 스위치 디바운스 및 처리
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            mode_sw_reg1 <= 0;
            mode_sw_reg2 <= 0;
            mode <= 0;
        end else begin
            mode_sw_reg1 <= mode_sw;
            mode_sw_reg2 <= mode_sw_reg1;
            mode <= mode_sw_reg2; // 디바운스된 모드
        end
    end
    
    // 개선된 카운터 로직 - 0.1초마다 카운트
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            current_digit1 <= 0;
            current_digit2 <= 0;
            current_digit3 <= 0;
            current_digit4 <= 0;
        end else if (count_pulse && !mode_sw) begin  // 0.1초 펄스와 업카운터 모드일 때만 동작
            // 업 카운팅 로직
            if (current_digit1 == 9) begin
                current_digit1 <= 0;
                if (current_digit2 == 9) begin
                    current_digit2 <= 0;
                    if (current_digit3 == 9) begin
                        current_digit3 <= 0;
                        if (current_digit4 == 9) begin
                            current_digit4 <= 0;
                        end else begin
                            current_digit4 <= current_digit4 + 1;
                        end
                    end else begin
                        current_digit3 <= current_digit3 + 1;
                    end
                end else begin
                    current_digit2 <= current_digit2 + 1;
                end
            end else begin
                current_digit1 <= current_digit1 + 1;
            end
        end
    end
    
    // FND 디스플레이 멀티플렉싱 - 고주파로 숫자 순환
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            fnd_cnt <= 0;
            digit_sel <= 0;
        end else begin
            if (fnd_cnt >= 50000) begin  // 디지트당 약 1kHz 주사율
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
                display_digit = current_digit1;
                fnd_sel = 4'b1110;  // 가장 오른쪽 디지트 활성화
            end
            2'b01: begin
                display_digit = current_digit2;
                fnd_sel = 4'b1101;
            end
            2'b10: begin
                display_digit = current_digit3;
                fnd_sel = 4'b1011;
            end
            2'b11: begin
                display_digit = current_digit4;
                fnd_sel = 4'b0111;  // 가장 왼쪽 디지트 활성화
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