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
    reg rst_n_up, rst_n_down;
    
    // Reset control logic for immediate mode change
    always @(posedge clk) begin
        if (!rst_n) begin
            // Global reset active
            rst_n_up <= 0;
            rst_n_down <= 0;
        end else if (mode_sw) begin
            // Down counter mode
            rst_n_up <= 0;    // Keep up counter in reset
            rst_n_down <= 1;  // Enable down counter
        end else begin
            // Up counter mode
            rst_n_up <= 1;    // Enable up counter
            rst_n_down <= 0;  // Keep down counter in reset
        end
    end
    
    // Instantiate the up/down counter module
    updown_counter #(
        .CLK_FREQ(50_000_000),  // 50 MHz default (adjust based on your board)
        .COUNT_FREQ(10)         // 0.1 second interval
    ) up_counter_inst (
        .clk(clk),
        .rst_n(rst_n_up),
        .mode_sw(1'b0),         // Fixed to Up counter mode
        .fnd_seg(up_counter_seg),
        .fnd_sel(up_counter_sel)
    );
    
    // Instantiate the down counter module
    down_counter #(
        .CLK_FREQ(50_000_000),  // 50 MHz default (adjust based on your board)
        .COUNT_FREQ(10)         // 0.1 second interval
    ) down_counter_inst (
        .clk(clk),
        .rst_n(rst_n_down),
        .fnd_seg(down_counter_seg),
        .fnd_sel(down_counter_sel)
    );
    
    // Mode selection mux
    // Selects between up_counter and down_counter based on mode_sw
    assign fnd_seg = mode_sw ? down_counter_seg : up_counter_seg;
    assign fnd_sel = mode_sw ? down_counter_sel : up_counter_sel;

endmodule