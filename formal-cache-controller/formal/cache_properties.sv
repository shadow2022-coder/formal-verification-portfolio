module cache_properties #(
    parameter int unsigned ADDR_WIDTH = 8,
    parameter int unsigned DATA_WIDTH = 32,
    parameter int unsigned NUM_LINES  = 4
) (
    input logic                          clk,
    input logic                          rst_n,

    input logic [2:0]                    state,

    input logic [NUM_LINES-1:0]          valid_array,
    input logic [NUM_LINES-1:0]          dirty_array,

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
    input logic [(DATA_WIDTH/8)-1:0]     req_wstrb_reg
);

    localparam logic [2:0] ST_IDLE = 3'd0;

    logic cpu_active;
    logic mem_outstanding;

    // -------------------------------------------------------------------------
    // Formal transaction monitors
    // -------------------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cpu_active     <= 1'b0;
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

        // Reset properties
        if (!$initstate && !$past(rst_n)) begin
            A_RST_01: assert (
                valid_array == {NUM_LINES{1'b0}}
            );

            A_RST_02: assert (
                dirty_array == {NUM_LINES{1'b0}}
            );
        end

        if (rst_n) begin

            // A_INV_01: Dirty implies valid.
            A_INV_01: assert (
                (dirty_array & ~valid_array) ==
                {NUM_LINES{1'b0}}
            );

            // A_CPU_02:
            // A CPU response requires an accepted active request.
            A_CPU_02: assert (
                !cpu_rsp_valid || cpu_active
            );

            // A_CPU_03:
            // No new CPU request may be accepted while one is active.
            A_CPU_03: assert (
                !(cpu_active && cpu_req_ready)
            );

            // A_MEM_02:
            // No second memory request may be issued while one is outstanding.
            A_MEM_02: assert (
                !(mem_outstanding && mem_req_valid)
            );

            // A_MEM_03:
            // The cache may accept a memory response only when a request
            // is outstanding.
            A_MEM_03: assert (
                !mem_rsp_ready || mem_outstanding
            );
        end

        if (!$initstate && rst_n && $past(rst_n)) begin

            // A_CPU_01:
            // CPU response remains valid and stable while backpressured.
            if ($past(cpu_rsp_valid && !cpu_rsp_ready)) begin
                A_CPU_01_VALID: assert (cpu_rsp_valid);

                A_CPU_01_DATA: assert (
                    cpu_rsp_rdata == $past(cpu_rsp_rdata)
                );
            end

            // A_MEM_01:
            // Memory request remains valid and stable while backpressured.
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

            // A_CPU_04:
            // Once processing has started, the captured CPU request cannot
            // change until the controller returns to IDLE.
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
        end
    end

endmodule
