module memory_model #(
    parameter int unsigned ADDR_WIDTH = 8,
    parameter int unsigned DATA_WIDTH = 32
) (
    input  logic                      clk,
    input  logic                      rst_n,

    // Request from cache
    input  logic                      mem_req_valid,
    output logic                      mem_req_ready,
    input  logic                      mem_req_write,
    input  logic [ADDR_WIDTH-1:0]     mem_req_addr,
    input  logic [DATA_WIDTH-1:0]     mem_req_wdata,

    // Response to cache
    output logic                      mem_rsp_valid,
    input  logic                      mem_rsp_ready,
    output logic [DATA_WIDTH-1:0]     mem_rsp_rdata,

    // Testbench controls
    input  logic                      force_req_stall,
    input  logic [7:0]                response_delay_cycles
);

    localparam int unsigned BYTE_LANES =
        DATA_WIDTH / 8;

    localparam int unsigned OFFSET_WIDTH =
        $clog2(BYTE_LANES);

    localparam int unsigned WORD_COUNT =
        1 << (ADDR_WIDTH - OFFSET_WIDTH);

    logic [DATA_WIDTH-1:0] memory [0:WORD_COUNT-1];

    logic                  transaction_pending;
    logic [7:0]            delay_count;

    integer word_index;

    // A new request is accepted only when no prior transaction is active.
    always_comb begin
        mem_req_ready =
            rst_n &&
            !transaction_pending &&
            !force_req_stall;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_rsp_valid       <= 1'b0;
            mem_rsp_rdata       <= '0;
            transaction_pending <= 1'b0;
            delay_count         <= '0;

            for (word_index = 0;
                 word_index < WORD_COUNT;
                 word_index = word_index + 1) begin
                memory[word_index] <= '0;
            end
        end else begin
            // Accept one memory request.
            if (mem_req_valid && mem_req_ready) begin
                if (mem_req_addr[OFFSET_WIDTH-1:0] != '0) begin
                    $fatal(
                        1,
                        "Memory model received an unaligned address"
                    );
                end

                transaction_pending <= 1'b1;
                delay_count         <= response_delay_cycles;

                if (mem_req_write) begin
                    memory[
                        mem_req_addr[ADDR_WIDTH-1:OFFSET_WIDTH]
                    ] <= mem_req_wdata;

                    // Write responses are acknowledgements only.
                    mem_rsp_rdata <= '0;
                end else begin
                    mem_rsp_rdata <= memory[
                        mem_req_addr[ADDR_WIDTH-1:OFFSET_WIDTH]
                    ];
                end
            end

            // Wait the configured number of cycles before responding.
            if (transaction_pending && !mem_rsp_valid) begin
                if (delay_count == 0) begin
                    mem_rsp_valid <= 1'b1;
                end else begin
                    delay_count <= delay_count - 1'b1;
                end
            end

            // Hold response valid and data stable until accepted.
            if (mem_rsp_valid && mem_rsp_ready) begin
                mem_rsp_valid       <= 1'b0;
                transaction_pending <= 1'b0;
            end
        end
    end

endmodule