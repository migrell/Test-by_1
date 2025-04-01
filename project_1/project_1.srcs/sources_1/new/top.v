// Top Module for Up/Down Counter
// Supports switching between Up and Down counting modes
// Connects the counters to the physical I/O pins of the FPGA or development board

module top_module(
    input wire clk,         // System Clock Input (from oscillator)
    input wire rst_n,       // Reset Input (from push button, active low)
    input wire mode_sw,     // Mode Switch Input (0:Up, 1:Down)
    output wire [6:0] fnd_seg, // 7-Segment data outputs
    output wire [3:0] fnd_sel  // 7-Segment select outputs
);

    // Parameters
    parameter CLK_FREQ = 50_000_000;  // 50 MHz default
    parameter COUNT_FREQ = 10;        // 0.1 second interval
    parameter CLK_DIV_VALUE = CLK_FREQ / (COUNT_FREQ * 2);

    // Internal signals
    wire [6:0] up_counter_seg;
    wire [3:0] up_counter_sel;
    wire [3:0] up_digit1, up_digit2, up_digit3, up_digit4;
    wire [6:0] down_counter_seg;
    wire [3:0] down_counter_sel;
    
    // Instantiate the up/down counter module
    updown_counter #(
        .CLK_FREQ(CLK_FREQ),
        .COUNT_FREQ(COUNT_FREQ),
        .CLK_DIV_VALUE(CLK_DIV_VALUE)
    ) up_counter_inst (
        .clk(clk),
        .rst_n(rst_n),
        .mode_sw(mode_sw),      // Pass the mode switch directly
        .fnd_seg(up_counter_seg),
        .fnd_sel(up_counter_sel),
        .digit1(up_digit1),     // Expose current digits
        .digit2(up_digit2),
        .digit3(up_digit3),
        .digit4(up_digit4)
    );
    
    // Instantiate the down counter module
    down_counter #(
        .CLK_FREQ(CLK_FREQ),
        .COUNT_FREQ(COUNT_FREQ),
        .CLK_DIV_VALUE(CLK_DIV_VALUE)
    ) down_counter_inst (
        .clk(clk),
        .rst_n(rst_n),
        .mode_sw(mode_sw),      // Pass the mode switch directly
        .current_digit1(up_digit1),  // Pass current up counter digits
        .current_digit2(up_digit2),
        .current_digit3(up_digit3),
        .current_digit4(up_digit4),
        .fnd_seg(down_counter_seg),
        .fnd_sel(down_counter_sel)
    );
    
    // Mode selection mux
    // Selects between up_counter and down_counter based on mode_sw
    assign fnd_seg = mode_sw ? down_counter_seg : up_counter_seg;
    assign fnd_sel = mode_sw ? down_counter_sel : up_counter_sel;

endmodule