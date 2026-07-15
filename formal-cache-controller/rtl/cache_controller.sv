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

`ifndef FORMAL_DATA

    // -------------------------------------------------------------------------
    // Main assertion module
    // -------------------------------------------------------------------------

    logic                  formal_selected_valid;
    logic                  formal_selected_dirty;
    logic [TAG_WIDTH-1:0]  formal_selected_tag;
    logic [DATA_WIDTH-1:0] formal_selected_data;

    assign formal_selected_valid = valid_array[req_index];
    assign formal_selected_dirty = dirty_array[req_index];
    assign formal_selected_tag   = tag_array[req_index];
    assign formal_selected_data  = data_array[req_index];

    cache_properties #(
        .ADDR_WIDTH  (ADDR_WIDTH),
        .DATA_WIDTH  (DATA_WIDTH),
        .NUM_LINES   (NUM_LINES),
        .BYTE_LANES  (BYTE_LANES),
        .INDEX_WIDTH (INDEX_WIDTH),
        .TAG_WIDTH   (TAG_WIDTH)
    ) formal_properties (
        .clk             (clk),
        .rst_n           (rst_n),
        .state           (state),

        .valid_array     (valid_array),
        .dirty_array     (dirty_array),

        .req_index       (req_index),
        .req_tag         (req_tag),
        .cache_hit       (cache_hit),

        .selected_valid  (formal_selected_valid),
        .selected_dirty  (formal_selected_dirty),
        .selected_tag    (formal_selected_tag),
        .selected_data   (formal_selected_data),

        .cpu_req_valid   (cpu_req_valid),
        .cpu_req_ready   (cpu_req_ready),

        .cpu_rsp_valid   (cpu_rsp_valid),
        .cpu_rsp_ready   (cpu_rsp_ready),
        .cpu_rsp_rdata   (cpu_rsp_rdata),

        .mem_req_valid   (mem_req_valid),
        .mem_req_ready   (mem_req_ready),
        .mem_req_write   (mem_req_write),
        .mem_req_addr    (mem_req_addr),
        .mem_req_wdata   (mem_req_wdata),

        .mem_rsp_valid   (mem_rsp_valid),
        .mem_rsp_ready   (mem_rsp_ready),
        .mem_rsp_rdata   (mem_rsp_rdata),

        .req_write_reg   (req_write_reg),
        .req_addr_reg    (req_addr_reg),
        .req_wdata_reg   (req_wdata_reg),
        .req_wstrb_reg   (req_wstrb_reg)
    );

    `endif  // !FORMAL_DATA

`ifdef FORMAL_DATA

    // =========================================================================
    // Symbolic tracked-address data-integrity model
    // =========================================================================

    (* anyconst *) logic [ADDR_WIDTH-1:0] f_addr_symbol;
    (* anyconst *) logic [DATA_WIDTH-1:0] f_initial_memory_data;

    wire [ADDR_WIDTH-1:0] f_tracked_addr = {
        f_addr_symbol[ADDR_WIDTH-1:OFFSET_WIDTH],
        {OFFSET_WIDTH{1'b0}}
    };

    wire [INDEX_WIDTH-1:0] f_tracked_index =
        f_tracked_addr[OFFSET_WIDTH + INDEX_WIDTH - 1 : OFFSET_WIDTH];

    wire [TAG_WIDTH-1:0] f_tracked_tag =
        f_tracked_addr[ADDR_WIDTH-1 : OFFSET_WIDTH + INDEX_WIDTH];

    wire f_tracked_resident =
        valid_array[f_tracked_index] &&
        (tag_array[f_tracked_index] == f_tracked_tag);

    // Architectural value expected for the tracked address.
    logic [DATA_WIDTH-1:0] f_expected_value;

    // Expected value captured when a tracked read is accepted.
    logic                  f_pending_tracked_read;
    logic [DATA_WIDTH-1:0] f_read_expected;

    // Abstract one-address backing-memory model.
    logic                  f_mem_outstanding;
    logic                  f_mem_write;
    logic [ADDR_WIDTH-1:0] f_mem_addr;
    logic [DATA_WIDTH-1:0] f_mem_wdata;
    logic [DATA_WIDTH-1:0] f_memory_value;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            f_expected_value       <= f_initial_memory_data;
            f_pending_tracked_read <= 1'b0;
            f_read_expected        <= '0;

            f_mem_outstanding      <= 1'b0;
            f_mem_write            <= 1'b0;
            f_mem_addr             <= '0;
            f_mem_wdata            <= '0;
            f_memory_value         <= f_initial_memory_data;
        end else begin

            // -------------------------------------------------------------
            // CPU architectural-value model
            // -------------------------------------------------------------

            if (cpu_req_valid && cpu_req_ready) begin
                f_pending_tracked_read <=
                    (cpu_req_addr == f_tracked_addr) &&
                    !cpu_req_write;

                if (
                    (cpu_req_addr == f_tracked_addr) &&
                    !cpu_req_write
                ) begin
                    f_read_expected <= f_expected_value;
                end

                if (
                    (cpu_req_addr == f_tracked_addr) &&
                    cpu_req_write
                ) begin
                    f_expected_value <= apply_wstrb(
                        f_expected_value,
                        cpu_req_wdata,
                        cpu_req_wstrb
                    );
                end
            end else if (cpu_rsp_valid && cpu_rsp_ready) begin
                f_pending_tracked_read <= 1'b0;
            end

            // -------------------------------------------------------------
            // Symbolic backing-memory model
            // -------------------------------------------------------------

            if (mem_req_valid && mem_req_ready) begin
                f_mem_outstanding <= 1'b1;
                f_mem_write       <= mem_req_write;
                f_mem_addr        <= mem_req_addr;
                f_mem_wdata       <= mem_req_wdata;
            end

            if (mem_rsp_valid && mem_rsp_ready) begin
                // A completed tracked-address writeback updates memory.
                if (
                    f_mem_write &&
                    (f_mem_addr == f_tracked_addr)
                ) begin
                    f_memory_value <= f_mem_wdata;
                end

                f_mem_outstanding <= 1'b0;
            end
        end
    end

    // Keep assumptions in a synchronous block. This avoids the Yosys
    // async2sync error caused by $check cells in async-reset processes.
    always_ff @(posedge clk) begin
        if (rst_n) begin

            // Data-only proof abstraction:
            // protocol backpressure is proved separately.
            F_DATA_FAST_01: assume (mem_req_ready);
            F_DATA_FAST_02: assume (cpu_rsp_ready);
            F_DATA_FAST_03: assume (mem_rsp_valid);

            F_DATA_ASSUME_01: assume (
                !(mem_req_valid && mem_req_ready) ||
                !f_mem_outstanding
            );

            F_DATA_ASSUME_02: assume (
                !(mem_rsp_valid && mem_rsp_ready) ||
                f_mem_outstanding
            );

            F_DATA_ASSUME_03: assume (
                !(
                    mem_rsp_valid &&
                    mem_rsp_ready &&
                    f_mem_outstanding &&
                    !f_mem_write &&
                    (f_mem_addr == f_tracked_addr)
                ) ||
                (mem_rsp_rdata == f_memory_value)
            );
        end
    end

    always_ff @(posedge clk) begin
        if (rst_n) begin

            // Every completed tracked read returns the architectural value.
            F_DATA_01: assert (
                !f_pending_tracked_read ||
                !cpu_rsp_valid ||
                (cpu_rsp_rdata == f_read_expected)
            );

            // At stable transaction boundaries, a resident tracked line
            // contains the latest architectural value.
            F_DATA_02: assert (
                !(
                    ((state == IDLE) || (state == RESPOND)) &&
                    f_tracked_resident
                ) ||
                (data_array[f_tracked_index] == f_expected_value)
            );

            // Dirty eviction of the tracked address writes back the latest
            // complete value, including partial-byte updates.
            F_DATA_03: assert (
                !(
                    mem_req_valid &&
                    mem_req_write &&
                    (mem_req_addr == f_tracked_addr)
                ) ||
                (mem_req_wdata == f_expected_value)
            );
        end
    end

`ifdef COVER

    logic [2:0] f_data_cover_phase;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            f_data_cover_phase <= 3'd0;
        end else begin
            case (f_data_cover_phase)

                // Symbolic partial write to tracked address.
                3'd0: begin
                    if (
                        cpu_req_valid &&
                        cpu_req_ready &&
                        cpu_req_write &&
                        (cpu_req_addr == f_tracked_addr) &&
                        (|cpu_req_wstrb) &&
                        !(&cpu_req_wstrb)
                    ) begin
                        f_data_cover_phase <= 3'd1;
                    end
                end

                // Dirty tracked line is written back.
                3'd1: begin
                    if (
                        mem_req_valid &&
                        mem_req_ready &&
                        mem_req_write &&
                        (mem_req_addr == f_tracked_addr)
                    ) begin
                        f_data_cover_phase <= 3'd2;
                    end
                end

                // Tracked address is requested again.
                3'd2: begin
                    if (
                        cpu_req_valid &&
                        cpu_req_ready &&
                        !cpu_req_write &&
                        (cpu_req_addr == f_tracked_addr)
                    ) begin
                        f_data_cover_phase <= 3'd3;
                    end
                end

                // Read response completes.
                3'd3: begin
                    if (cpu_rsp_valid && cpu_rsp_ready) begin
                        f_data_cover_phase <= 3'd4;
                    end
                end

                default: begin
                    f_data_cover_phase <= f_data_cover_phase;
                end
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (rst_n) begin
            C_DATA_01: cover (
                (f_data_cover_phase == 3'd3) &&
                cpu_rsp_valid &&
                (cpu_rsp_rdata == f_read_expected)
            );
        end
    end

`endif  // COVER

`endif  // FORMAL_DATA

`endif  // FORMAL

endmodule