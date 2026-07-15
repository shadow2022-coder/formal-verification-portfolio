module cache_properties #(
    parameter int unsigned ADDR_WIDTH  = 8,
    parameter int unsigned DATA_WIDTH  = 32,
    parameter int unsigned NUM_LINES   = 4,
    parameter int unsigned BYTE_LANES  = DATA_WIDTH / 8,
    parameter int unsigned INDEX_WIDTH = $clog2(NUM_LINES),
    parameter int unsigned TAG_WIDTH   =
        ADDR_WIDTH - INDEX_WIDTH - $clog2(BYTE_LANES)
) (
    input logic                          clk,
    input logic                          rst_n,

    input logic [2:0]                    state,

    input logic [NUM_LINES-1:0]          valid_array,
    input logic [NUM_LINES-1:0]          dirty_array,

    input logic [INDEX_WIDTH-1:0]        req_index,
    input logic [TAG_WIDTH-1:0]          req_tag,
    input logic                          cache_hit,

    input logic                          selected_valid,
    input logic                          selected_dirty,
    input logic [TAG_WIDTH-1:0]          selected_tag,
    input logic [DATA_WIDTH-1:0]         selected_data,

    input logic                          cpu_req_valid,
    input logic                          cpu_req_ready,

    input logic                          cpu_rsp_valid,
    input logic                          cpu_rsp_ready,
    input logic [DATA_WIDTH-1:0]         cpu_rsp_rdata,

    input logic                          mem_req_valid,
    input logic                          mem_req_ready,
    input logic                          mem_req_write,
    input logic [ADDR_WIDTH-1:0]         mem_req_addr,
    input logic [DATA_WIDTH-1:0]         mem_req_wdata,

    input logic                          mem_rsp_valid,
    input logic                          mem_rsp_ready,
    input logic [DATA_WIDTH-1:0]         mem_rsp_rdata,

    input logic                          req_write_reg,
    input logic [ADDR_WIDTH-1:0]         req_addr_reg,
    input logic [DATA_WIDTH-1:0]         req_wdata_reg,
    input logic [BYTE_LANES-1:0]         req_wstrb_reg
);

    localparam int unsigned OFFSET_WIDTH = $clog2(BYTE_LANES);

    localparam logic [2:0] ST_IDLE           = 3'd0;
    localparam logic [2:0] ST_LOOKUP         = 3'd1;
    localparam logic [2:0] ST_WRITEBACK_REQ  = 3'd2;
    localparam logic [2:0] ST_WRITEBACK_WAIT = 3'd3;
    localparam logic [2:0] ST_REFILL_REQ     = 3'd4;
    localparam logic [2:0] ST_REFILL_WAIT    = 3'd5;

    logic cpu_active;
    logic mem_outstanding;

    logic miss_pending;
    logic dirty_miss_pending;
    logic writeback_done;

    function automatic logic [DATA_WIDTH-1:0] expected_wstrb_merge (
        input logic [DATA_WIDTH-1:0] old_data,
        input logic [DATA_WIDTH-1:0] new_data,
        input logic [BYTE_LANES-1:0] wstrb
    );
        integer byte_index;

        begin
            expected_wstrb_merge = old_data;

            for (
                byte_index = 0;
                byte_index < BYTE_LANES;
                byte_index = byte_index + 1
            ) begin
                if (wstrb[byte_index]) begin
                    expected_wstrb_merge[byte_index*8 +: 8] =
                        new_data[byte_index*8 +: 8];
                end
            end
        end
    endfunction

    // -------------------------------------------------------------------------
    // Formal transaction and miss monitors
    // -------------------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cpu_active        <= 1'b0;
            mem_outstanding   <= 1'b0;

            miss_pending      <= 1'b0;
            dirty_miss_pending <= 1'b0;
            writeback_done    <= 1'b0;
        end else begin
            if (cpu_req_valid && cpu_req_ready) begin
                cpu_active <= 1'b1;
            end

            if (cpu_rsp_valid && cpu_rsp_ready) begin
                cpu_active <= 1'b0;
            end

            if (mem_req_valid && mem_req_ready) begin
                mem_outstanding <= 1'b1;
            end

            if (mem_rsp_valid && mem_rsp_ready) begin
                mem_outstanding <= 1'b0;
            end

            // Record the type of miss detected in LOOKUP.
            if ((state == ST_LOOKUP) && !cache_hit) begin
                miss_pending <= 1'b1;

                dirty_miss_pending <=
                    selected_valid && selected_dirty;

                writeback_done <= 1'b0;
            end

            // A response in WRITEBACK_WAIT acknowledges victim writeback.
            if (
                (state == ST_WRITEBACK_WAIT) &&
                mem_rsp_valid &&
                mem_rsp_ready
            ) begin
                writeback_done <= 1'b1;
            end

            // A response in REFILL_WAIT completes the miss sequence.
            if (
                (state == ST_REFILL_WAIT) &&
                mem_rsp_valid &&
                mem_rsp_ready
            ) begin
                miss_pending       <= 1'b0;
                dirty_miss_pending <= 1'b0;
                writeback_done     <= 1'b0;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Assertions
    // -------------------------------------------------------------------------

    always_ff @(posedge clk) begin

        // Reset behavior.
        if (!$initstate && !$past(rst_n)) begin
            A_RST_01: assert (
                valid_array == {NUM_LINES{1'b0}}
            );

            A_RST_02: assert (
                dirty_array == {NUM_LINES{1'b0}}
            );
        end

        if (rst_n) begin

            // Dirty implies valid.
            A_INV_01: assert (
                (dirty_array & ~valid_array) ==
                {NUM_LINES{1'b0}}
            );

            // Hit requires valid plus matching tag.
            A_HIT_01: assert (
                cache_hit ==
                (selected_valid && (selected_tag == req_tag))
            );

            // Hits must not access backing memory.
            if ((state == ST_LOOKUP) && cache_hit) begin
                A_HIT_02: assert (!mem_req_valid);
            end

            // CPU protocol tracking.
            A_CPU_02: assert (
                !cpu_rsp_valid || cpu_active
            );

            A_CPU_03: assert (
                !(cpu_active && cpu_req_ready)
            );

            // Memory protocol tracking.
            A_MEM_02: assert (
                !(mem_outstanding && mem_req_valid)
            );

            A_MEM_03: assert (
                !mem_rsp_ready || mem_outstanding
            );

            // A_MISS_01:
            // No CPU response may appear before refill completion.
            if (miss_pending) begin
                A_MISS_01: assert (!cpu_rsp_valid);
            end

            // A_EVICT_01:
            // Dirty eviction request must use victim address and data.
            if (state == ST_WRITEBACK_REQ) begin
                A_EVICT_01_VALID: assert (mem_req_valid);
                A_EVICT_01_WRITE: assert (mem_req_write);

                A_EVICT_01_ADDR: assert (
                    mem_req_addr == {
                        selected_tag,
                        req_index,
                        {OFFSET_WIDTH{1'b0}}
                    }
                );

                A_EVICT_01_DATA: assert (
                    mem_req_wdata == selected_data
                );
            end

            // A_EVICT_02:
            // Refill may not begin before dirty writeback completes.
            if (
                dirty_miss_pending &&
                (state == ST_REFILL_REQ)
            ) begin
                A_EVICT_02: assert (writeback_done);
            end

            // A_EVICT_03:
            // During writeback acknowledgement wait, no refill request exists.
            if (state == ST_WRITEBACK_WAIT) begin
                A_EVICT_03_READY: assert (mem_rsp_ready);
                A_EVICT_03_NO_REQUEST: assert (!mem_req_valid);
            end

            // A_REFILL_01:
            // Refill request uses the captured CPU request address.
            if (state == ST_REFILL_REQ) begin
                A_REFILL_01_VALID: assert (mem_req_valid);
                A_REFILL_01_READ: assert (!mem_req_write);

                A_REFILL_01_ADDR: assert (
                    mem_req_addr == req_addr_reg
                );
            end

            // A_REFILL_02:
            // Cache must accept the response while waiting for refill.
            if (state == ST_REFILL_WAIT) begin
                A_REFILL_02: assert (mem_rsp_ready);
            end
        end

        if (!$initstate && rst_n && $past(rst_n)) begin

            // CPU response stability while stalled.
            if ($past(cpu_rsp_valid && !cpu_rsp_ready)) begin
                A_CPU_01_VALID: assert (cpu_rsp_valid);

                A_CPU_01_DATA: assert (
                    cpu_rsp_rdata == $past(cpu_rsp_rdata)
                );
            end

            // Memory request stability while stalled.
            if ($past(mem_req_valid && !mem_req_ready)) begin
                A_MEM_01_VALID: assert (mem_req_valid);

                A_MEM_01_WRITE: assert (
                    mem_req_write == $past(mem_req_write)
                );

                A_MEM_01_ADDR: assert (
                    mem_req_addr == $past(mem_req_addr)
                );

                A_MEM_01_DATA: assert (
                    mem_req_wdata == $past(mem_req_wdata)
                );
            end

            // Captured request stays stable while the cache is busy.
            if ($past(state != ST_IDLE)) begin
                A_CPU_04_WRITE: assert (
                    req_write_reg == $past(req_write_reg)
                );

                A_CPU_04_ADDR: assert (
                    req_addr_reg == $past(req_addr_reg)
                );

                A_CPU_04_DATA: assert (
                    req_wdata_reg == $past(req_wdata_reg)
                );

                A_CPU_04_WSTRB: assert (
                    req_wstrb_reg == $past(req_wstrb_reg)
                );
            end

            // Read-hit behavior.
            if ($past(
                (state == ST_LOOKUP) &&
                cache_hit &&
                !req_write_reg
            )) begin
                A_HIT_03_VALID: assert (
                    selected_valid == $past(selected_valid)
                );

                A_HIT_03_DIRTY: assert (
                    selected_dirty == $past(selected_dirty)
                );

                A_HIT_03_TAG: assert (
                    selected_tag == $past(selected_tag)
                );

                A_HIT_03_DATA: assert (
                    selected_data == $past(selected_data)
                );

                A_HIT_04_RESPONSE_VALID: assert (cpu_rsp_valid);

                A_HIT_04_RESPONSE_DATA: assert (
                    cpu_rsp_rdata == $past(selected_data)
                );
            end

            // Write-hit behavior and WSTRB preservation.
            if ($past(
                (state == ST_LOOKUP) &&
                cache_hit &&
                req_write_reg
            )) begin
                A_WRITE_01_VALID: assert (
                    selected_valid == $past(selected_valid)
                );

                A_WRITE_02_TAG: assert (
                    selected_tag == $past(selected_tag)
                );

                A_WRITE_03_DIRTY: assert (selected_dirty);

                A_WRITE_04_DATA: assert (
                    selected_data ==
                    expected_wstrb_merge(
                        $past(selected_data),
                        $past(req_wdata_reg),
                        $past(req_wstrb_reg)
                    )
                );

                A_WRITE_05_RESPONSE_VALID: assert (cpu_rsp_valid);

                A_WRITE_05_RESPONSE_DATA: assert (
                    cpu_rsp_rdata == {DATA_WIDTH{1'b0}}
                );
            end

            // A_EVICT_04:
            // Victim line must remain unchanged throughout writeback.
            if (
                ($past(state) == ST_WRITEBACK_REQ) ||
                ($past(state) == ST_WRITEBACK_WAIT)
            ) begin
                A_EVICT_04_VALID: assert (
                    selected_valid == $past(selected_valid)
                );

                A_EVICT_04_DIRTY: assert (
                    selected_dirty == $past(selected_dirty)
                );

                A_EVICT_04_TAG: assert (
                    selected_tag == $past(selected_tag)
                );

                A_EVICT_04_DATA: assert (
                    selected_data == $past(selected_data)
                );
            end

            // Refill installation and original request completion.
            if ($past(
                (state == ST_REFILL_WAIT) &&
                mem_rsp_valid &&
                mem_rsp_ready
            )) begin
                A_REFILL_03_VALID: assert (selected_valid);

                A_REFILL_03_TAG: assert (
                    selected_tag == $past(req_tag)
                );

                A_REFILL_03_RESPONSE_VALID: assert (cpu_rsp_valid);

                if ($past(req_write_reg)) begin
                    A_REFILL_04_WRITE_DIRTY: assert (
                        selected_dirty
                    );

                    A_REFILL_04_WRITE_DATA: assert (
                        selected_data ==
                        expected_wstrb_merge(
                            $past(mem_rsp_rdata),
                            $past(req_wdata_reg),
                            $past(req_wstrb_reg)
                        )
                    );

                    A_REFILL_04_WRITE_RESPONSE: assert (
                        cpu_rsp_rdata == {DATA_WIDTH{1'b0}}
                    );
                end else begin
                    A_REFILL_05_READ_CLEAN: assert (
                        !selected_dirty
                    );

                    A_REFILL_05_READ_DATA: assert (
                        selected_data == $past(mem_rsp_rdata)
                    );

                    A_REFILL_05_READ_RESPONSE: assert (
                        cpu_rsp_rdata == $past(mem_rsp_rdata)
                    );
                end
            end
        end
    end


    `ifdef COVER

    logic c_any_refill_completed;

    logic c_dirty_miss_seen;
    logic c_writeback_accept_seen;
    logic c_writeback_ack_seen;
    logic c_refill_accept_seen;
    logic c_dirty_refill_seen;

    // -------------------------------------------------------------------------
    // Cover-sequence monitors
    // -------------------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            c_any_refill_completed <= 1'b0;

            c_dirty_miss_seen       <= 1'b0;
            c_writeback_accept_seen <= 1'b0;
            c_writeback_ack_seen    <= 1'b0;
            c_refill_accept_seen    <= 1'b0;
            c_dirty_refill_seen     <= 1'b0;
        end else begin

            // Remember that at least one refill has completed.
            if (
                (state == ST_REFILL_WAIT) &&
                mem_rsp_valid &&
                mem_rsp_ready
            ) begin
                c_any_refill_completed <= 1'b1;
            end

            // Begin tracking a new CPU transaction.
            if (cpu_req_valid && cpu_req_ready) begin
                c_dirty_miss_seen       <= 1'b0;
                c_writeback_accept_seen <= 1'b0;
                c_writeback_ack_seen    <= 1'b0;
                c_refill_accept_seen    <= 1'b0;
                c_dirty_refill_seen     <= 1'b0;
            end

            // Dirty conflicting line detected.
            if (
                (state == ST_LOOKUP) &&
                !cache_hit &&
                selected_valid &&
                selected_dirty
            ) begin
                c_dirty_miss_seen <= 1'b1;
            end

            // Dirty victim writeback accepted.
            if (
                c_dirty_miss_seen &&
                (state == ST_WRITEBACK_REQ) &&
                mem_req_valid &&
                mem_req_ready
            ) begin
                c_writeback_accept_seen <= 1'b1;
            end

            // Writeback acknowledgement accepted.
            if (
                c_writeback_accept_seen &&
                (state == ST_WRITEBACK_WAIT) &&
                mem_rsp_valid &&
                mem_rsp_ready
            ) begin
                c_writeback_ack_seen <= 1'b1;
            end

            // Refill request accepted after writeback.
            if (
                c_writeback_ack_seen &&
                (state == ST_REFILL_REQ) &&
                mem_req_valid &&
                mem_req_ready
            ) begin
                c_refill_accept_seen <= 1'b1;
            end

            // Refill response accepted.
            if (
                c_refill_accept_seen &&
                (state == ST_REFILL_WAIT) &&
                mem_rsp_valid &&
                mem_rsp_ready
            ) begin
                c_dirty_refill_seen <= 1'b1;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Required cover properties
    // -------------------------------------------------------------------------

    always_ff @(posedge clk) begin
        if (rst_n) begin

            // Cold miss: selected line is invalid.
            C_MISS_01: cover (
                (state == ST_LOOKUP) &&
                !cache_hit &&
                !selected_valid &&
                !req_write_reg
            );

            // A refill response is accepted.
            C_REFILL_01: cover (
                (state == ST_REFILL_WAIT) &&
                mem_rsp_valid &&
                mem_rsp_ready
            );

            // Read hit after at least one refill has completed.
            C_HIT_01: cover (
                c_any_refill_completed &&
                (state == ST_LOOKUP) &&
                cache_hit &&
                !req_write_reg
            );

            // Write hit.
            C_WRITE_01: cover (
                (state == ST_LOOKUP) &&
                cache_hit &&
                req_write_reg
            );

            // Partial-byte write hit.
            C_WRITE_02: cover (
                (state == ST_LOOKUP) &&
                cache_hit &&
                req_write_reg &&
                (|req_wstrb_reg) &&
                !(&req_wstrb_reg)
            );

            // Clean conflict miss.
            C_MISS_02: cover (
                (state == ST_LOOKUP) &&
                !cache_hit &&
                selected_valid &&
                !selected_dirty
            );

            // Dirty conflict miss.
            C_EVICT_01: cover (
                (state == ST_LOOKUP) &&
                !cache_hit &&
                selected_valid &&
                selected_dirty
            );

            // Memory-request backpressure.
            C_BACKPRESSURE_01: cover (
                mem_req_valid &&
                !mem_req_ready
            );

            // CPU-response backpressure.
            C_BACKPRESSURE_02: cover (
                cpu_rsp_valid &&
                !cpu_rsp_ready
            );

            // Complete central dirty-eviction path.
            C_EVICT_02: cover (
                c_dirty_refill_seen &&
                cpu_rsp_valid
            );
        end
    end

`endif

endmodule
