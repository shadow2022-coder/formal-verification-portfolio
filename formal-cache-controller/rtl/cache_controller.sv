
module cache_controller #(
    parameter int unsigned ADDR_WIDTH = 8,
    parameter int unsigned DATA_WIDTH = 32,
    parameter int unsigned NUM_LINES  = 4
) (
    // Clock and active-low reset
    input  logic                      clk,
    input  logic                      rst_n,

    // CPU request interface
    input  logic                      cpu_req_valid,
    output logic                      cpu_req_ready,
    input  logic                      cpu_req_write,
    input  logic [ADDR_WIDTH-1:0]     cpu_req_addr,
    input  logic [DATA_WIDTH-1:0]     cpu_req_wdata,
    input  logic [(DATA_WIDTH/8)-1:0] cpu_req_wstrb,

    // CPU response interface
    output logic                      cpu_rsp_valid,
    input  logic                      cpu_rsp_ready,
    output logic [DATA_WIDTH-1:0]     cpu_rsp_rdata,

    // Memory request interface
    output logic                      mem_req_valid,
    input  logic                      mem_req_ready,
    output logic                      mem_req_write,
    output logic [ADDR_WIDTH-1:0]     mem_req_addr,
    output logic [DATA_WIDTH-1:0]     mem_req_wdata,

    // Memory response interface
    input  logic                      mem_rsp_valid,
    output logic                      mem_rsp_ready,
    input  logic [DATA_WIDTH-1:0]     mem_rsp_rdata
);

    // -------------------------------------------------------------------------
    // Derived constants
    // -------------------------------------------------------------------------

    localparam int unsigned BYTE_LANES   = DATA_WIDTH / 8;
    localparam int unsigned OFFSET_WIDTH = $clog2(BYTE_LANES);
    localparam int unsigned INDEX_WIDTH  = $clog2(NUM_LINES);
    localparam int unsigned TAG_WIDTH    =
        ADDR_WIDTH - INDEX_WIDTH - OFFSET_WIDTH;

    // -------------------------------------------------------------------------
    // Cache controller states
    // -------------------------------------------------------------------------

    typedef enum logic [2:0] {
        IDLE,
        LOOKUP,
        WRITEBACK_REQ,
        WRITEBACK_WAIT,
        REFILL_REQ,
        REFILL_WAIT,
        RESPOND
    } cache_state_t;

    cache_state_t state;
    cache_state_t next_state;

    // -------------------------------------------------------------------------
    // Cache-line storage
    // -------------------------------------------------------------------------

    logic [NUM_LINES-1:0] valid_array;
    logic [NUM_LINES-1:0] dirty_array;

    logic [TAG_WIDTH-1:0]  tag_array  [0:NUM_LINES-1];
    logic [DATA_WIDTH-1:0] data_array [0:NUM_LINES-1];

    // -------------------------------------------------------------------------
    // Captured CPU request
    // -------------------------------------------------------------------------

    logic                      req_write_reg;
    logic [ADDR_WIDTH-1:0]     req_addr_reg;
    logic [DATA_WIDTH-1:0]     req_wdata_reg;
    logic [BYTE_LANES-1:0]     req_wstrb_reg;

    // -------------------------------------------------------------------------
    // Registered CPU response data
    // -------------------------------------------------------------------------

    logic [DATA_WIDTH-1:0] rsp_rdata_reg;

    // -------------------------------------------------------------------------
    // Lookup signals
    // -------------------------------------------------------------------------

    logic [INDEX_WIDTH-1:0] req_index;
    logic [TAG_WIDTH-1:0]   req_tag;
    logic                   cache_hit;

    assign req_index =
        req_addr_reg[OFFSET_WIDTH + INDEX_WIDTH - 1 : OFFSET_WIDTH];

    assign req_tag =
        req_addr_reg[ADDR_WIDTH - 1 : OFFSET_WIDTH + INDEX_WIDTH];

    assign cache_hit =
        valid_array[req_index] &&
        (tag_array[req_index] == req_tag);

    // -------------------------------------------------------------------------
    // WSTRB byte-mask function
    // -------------------------------------------------------------------------

    function automatic logic [DATA_WIDTH-1:0] apply_wstrb (
        input logic [DATA_WIDTH-1:0] old_data,
        input logic [DATA_WIDTH-1:0] new_data,
        input logic [BYTE_LANES-1:0] wstrb
    );
        integer byte_index;

        begin
            apply_wstrb = old_data;

            for (
                byte_index = 0;
                byte_index < BYTE_LANES;
                byte_index = byte_index + 1
            ) begin
                if (wstrb[byte_index]) begin
                    apply_wstrb[byte_index*8 +: 8] =
                        new_data[byte_index*8 +: 8];
                end
            end
        end
    endfunction

    // -------------------------------------------------------------------------
    // Sequential state, request storage and cache updates
    // -------------------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= IDLE;

            valid_array   <= '0;
            dirty_array   <= '0;

            req_write_reg <= 1'b0;
            req_addr_reg  <= '0;
            req_wdata_reg <= '0;
            req_wstrb_reg <= '0;

            rsp_rdata_reg <= '0;
        end else begin
            state <= next_state;

            // Capture one CPU request.
            if (cpu_req_valid && cpu_req_ready) begin
                req_write_reg <= cpu_req_write;
                req_addr_reg  <= cpu_req_addr;
                req_wdata_reg <= cpu_req_wdata;
                req_wstrb_reg <= cpu_req_wstrb;
            end

            // Complete a read hit or write hit.
            if ((state == LOOKUP) && cache_hit) begin
                if (req_write_reg) begin
                    data_array[req_index] <= apply_wstrb(
                        data_array[req_index],
                        req_wdata_reg,
                        req_wstrb_reg
                    );

                    dirty_array[req_index] <= 1'b1;
                    rsp_rdata_reg          <= '0;
                end else begin
                    rsp_rdata_reg <= data_array[req_index];
                end
            end

            // Install refill data for a read miss or write miss.
            if ((state == REFILL_WAIT) &&
                mem_rsp_valid &&
                mem_rsp_ready) begin

                tag_array[req_index]   <= req_tag;
                valid_array[req_index] <= 1'b1;

                if (req_write_reg) begin
                    // Write allocation:
                    // merge CPU write into the word returned by memory.
                    data_array[req_index] <= apply_wstrb(
                        mem_rsp_rdata,
                        req_wdata_reg,
                        req_wstrb_reg
                    );

                    dirty_array[req_index] <= 1'b1;
                    rsp_rdata_reg          <= '0;
                end else begin
                    data_array[req_index]  <= mem_rsp_rdata;
                    dirty_array[req_index] <= 1'b0;
                    rsp_rdata_reg          <= mem_rsp_rdata;
                end
            end
        end
    end

    // -------------------------------------------------------------------------
    // Combinational output and next-state logic
    // -------------------------------------------------------------------------

    always_comb begin
        next_state = state;

        cpu_req_ready = 1'b0;

        cpu_rsp_valid = 1'b0;
        cpu_rsp_rdata = rsp_rdata_reg;

        mem_req_valid = 1'b0;
        mem_req_write = 1'b0;
        mem_req_addr  = '0;
        mem_req_wdata = '0;

        mem_rsp_ready = 1'b0;

                case (state)
            IDLE: begin
                cpu_req_ready = 1'b1;

                if (cpu_req_valid && cpu_req_ready) begin
                    next_state = LOOKUP;
                end
            end

            LOOKUP: begin
                if (cache_hit) begin
                    next_state = RESPOND;
                end else if (
                    valid_array[req_index] &&
                    dirty_array[req_index]
                ) begin
                    // Dirty conflict miss: write back victim first.
                    next_state = WRITEBACK_REQ;
                end else begin
                    // Invalid or clean miss.
                    next_state = REFILL_REQ;
                end
            end

            WRITEBACK_REQ: begin
                mem_req_valid = 1'b1;
                mem_req_write = 1'b1;

                // Reconstruct the victim address using the stored tag.
                mem_req_addr = {
                    tag_array[req_index],
                    req_index,
                    {OFFSET_WIDTH{1'b0}}
                };

                mem_req_wdata = data_array[req_index];

                if (mem_req_ready) begin
                    next_state = WRITEBACK_WAIT;
                end
            end

            WRITEBACK_WAIT: begin
                // Both reads and writes receive a memory completion response.
                mem_rsp_ready = 1'b1;

                if (mem_rsp_valid) begin
                    next_state = REFILL_REQ;
                end
            end

            REFILL_REQ: begin
                mem_req_valid = 1'b1;
                mem_req_write = 1'b0;
                mem_req_addr  = req_addr_reg;
                mem_req_wdata = '0;

                if (mem_req_ready) begin
                    next_state = REFILL_WAIT;
                end
            end

            REFILL_WAIT: begin
                mem_rsp_ready = 1'b1;

                if (mem_rsp_valid) begin
                    next_state = RESPOND;
                end
            end

            RESPOND: begin
                cpu_rsp_valid = 1'b1;

                if (cpu_rsp_ready) begin
                    next_state = IDLE;
                end
            end

            default: begin
                next_state = state;
            end
        endcase
    end

    `ifdef FORMAL

        cache_properties #(
            .NUM_LINES(NUM_LINES)
        ) formal_properties (
            .clk         (clk),
            .rst_n       (rst_n),
            .valid_array (valid_array),
            .dirty_array (dirty_array)
        );

    `endif

endmodule

