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

    input logic                          req_write_reg,
    input logic [ADDR_WIDTH-1:0]         req_addr_reg,
    input logic [DATA_WIDTH-1:0]         req_wdata_reg,
    input logic [BYTE_LANES-1:0]         req_wstrb_reg
);

    localparam logic [2:0] ST_IDLE   = 3'd0;
    localparam logic [2:0] ST_LOOKUP = 3'd1;

    logic cpu_active;
    logic mem_outstanding;

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
    // Transaction monitors
    // -------------------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cpu_active      <= 1'b0;
            mem_outstanding <= 1'b0;
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
        end
    end

    // -------------------------------------------------------------------------
    // Assertions
    // -------------------------------------------------------------------------

    always_ff @(posedge clk) begin

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

            // Hit detection must use valid plus tag equality.
            A_HIT_01: assert (
                cache_hit ==
                (selected_valid && (selected_tag == req_tag))
            );

            // A hit may not issue a backing-memory request.
            if ((state == ST_LOOKUP) && cache_hit) begin
                A_HIT_02: assert (!mem_req_valid);
            end

            // CPU transaction properties.
            A_CPU_02: assert (
                !cpu_rsp_valid || cpu_active
            );

            A_CPU_03: assert (
                !(cpu_active && cpu_req_ready)
            );

            // Memory transaction properties.
            A_MEM_02: assert (
                !(mem_outstanding && mem_req_valid)
            );

            A_MEM_03: assert (
                !mem_rsp_ready || mem_outstanding
            );
        end

        if (!$initstate && rst_n && $past(rst_n)) begin

            // CPU response stability during backpressure.
            if ($past(cpu_rsp_valid && !cpu_rsp_ready)) begin
                A_CPU_01_VALID: assert (cpu_rsp_valid);

                A_CPU_01_DATA: assert (
                    cpu_rsp_rdata == $past(cpu_rsp_rdata)
                );
            end

            // Memory request stability during backpressure.
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

            // Captured request remains stable while processing.
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

                A_HIT_04_RESPONSE_VALID: assert (
                    cpu_rsp_valid
                );

                A_HIT_04_RESPONSE_DATA: assert (
                    cpu_rsp_rdata == $past(selected_data)
                );
            end

            // Write-hit behavior.
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

                A_WRITE_03_DIRTY: assert (
                    selected_dirty
                );

                A_WRITE_04_DATA: assert (
                    selected_data ==
                    expected_wstrb_merge(
                        $past(selected_data),
                        $past(req_wdata_reg),
                        $past(req_wstrb_reg)
                    )
                );

                A_WRITE_05_RESPONSE_VALID: assert (
                    cpu_rsp_valid
                );

                A_WRITE_05_RESPONSE_DATA: assert (
                    cpu_rsp_rdata == {DATA_WIDTH{1'b0}}
                );
            end
        end
    end

endmodule
