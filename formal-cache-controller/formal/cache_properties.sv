module cache_properties #(
    parameter int unsigned NUM_LINES = 4
) (
    input logic                 clk,
    input logic                 rst_n,
    input logic [NUM_LINES-1:0] valid_array,
    input logic [NUM_LINES-1:0] dirty_array
);

    always @(posedge clk) begin

        // A_RST_01:
        // After reset was sampled low, all lines must be invalid.
        if (!$initstate && !$past(rst_n)) begin
            A_RST_01: assert (
                valid_array == {NUM_LINES{1'b0}}
            );
        end

        // A_RST_02:
        // After reset was sampled low, all dirty bits must be clear.
        if (!$initstate && !$past(rst_n)) begin
            A_RST_02: assert (
                dirty_array == {NUM_LINES{1'b0}}
            );
        end

        // A_INV_01:
        // No invalid cache line may be dirty.
        if (rst_n) begin
            A_INV_01: assert (
                (dirty_array & ~valid_array) ==
                {NUM_LINES{1'b0}}
            );
        end
    end

endmodule
