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

    // Internal signals
    wire [6:0] up_counter_seg;
    wire [3:0] up_counter_sel;
    wire [6:0] down_counter_seg;
    wire [3:0] down_counter_sel;
    
    // Instantiate the up/down counter module
    updown_counter #(
        .CLK_FREQ(50_000_000),  // 50 MHz default
        .COUNT_FREQ(10)         // 0.1 second interval
    ) up_counter_inst (
        .clk(clk),
        .rst_n(rst_n),
        .mode_sw(mode_sw),      // Pass the mode switch directly
        .fnd_seg(up_counter_seg),
        .fnd_sel(up_counter_sel)
    );
    
    // Instantiate the down counter module
    down_counter #(
        .CLK_FREQ(50_000_000),  // 50 MHz default
        .COUNT_FREQ(10)         // 0.1 second interval
    ) down_counter_inst (
        .clk(clk),
        .rst_n(rst_n),
        .mode_sw(mode_sw),      // Pass the mode switch directly
        .fnd_seg(down_counter_seg),
        .fnd_sel(down_counter_sel)
    );
    
    // Mode selection mux
    // Selects between up_counter and down_counter based on mode_sw
    assign fnd_seg = mode_sw ? down_counter_seg : up_counter_seg;
    assign fnd_sel = mode_sw ? down_counter_sel : up_counter_sel;

endmodule