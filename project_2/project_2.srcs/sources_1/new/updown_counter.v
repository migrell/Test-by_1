

module top_counter_up_down (
    input clk,
    input reset,
    input mode,
    output [3:0] fndcom,
    output [7:0] fndFont
);

    wire [13:0] fndData;

    counter_up_down U_Counter (
        .clk(clk),
        .reset(reset),
        .mode(mode),
        .count(fndData)
    );

    fndController U_fndController (
        .clk(clk),
        .reset(reset),
        .fndData(fndData),
        .fndCom(fndcom),
        .fndFont(fndFont)
    );

endmodule

module counter_up_down (
    input clk,
    input reset,
    input mode,
    output [13:0] count
);

    wire tick;

    clk_div_10hz U_CLK_DIV_10HZ (
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    U_Counter_Up_Down U_Counter_Up_Down (
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .mode(mode),
        .count(count)
    );

endmodule

module U_Counter_Up_Down (
    input clk,
    input reset,
    input tick,
    input mode,
    output [13:0] count
);

    reg [13:0] count_reg;
    wire [$clog2(10000) - 1 :0] counter;

    assign count = count_reg;
    assign counter = count_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
        end else begin
            if (mode == 1'b0) begin
                if (tick) begin
                    if (count_reg == 9999) begin
                        count_reg <= 0;
                    end else begin
                        count_reg <= count_reg + 1;
                    end
                end
            end else begin
                if (tick) begin
                    if (count_reg == 0) begin
                        count_reg <= 9999;
                    end else begin
                        count_reg <= count_reg - 1;
                    end
                end
            end
        end
    end
endmodule

module clk_div_10hz (
    input clk,
    input reset,
    output reg tick
);

    reg [$clog2(10_000_000) -1 :0] div_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            div_counter <= 0;
            tick <= 1'b0;
        end else begin
            if (div_counter == 100_000_000 - 1) begin // 100MHz
                div_counter <= 0;
                tick <= 1'b1;
            end else begin
                div_counter <= div_counter + 1;
                tick <= 1'b0;
            end
        end
    end
endmodule
