`timescale 1ns/1ps

module cache_tb;

    logic clk = 0;
    logic rst_n;

    logic        cpu_req_valid;
    logic        cpu_req_ready;
    logic        cpu_req_write;
    logic [7:0]  cpu_req_addr;
    logic [31:0] cpu_req_wdata;
    logic [3:0]  cpu_req_wstrb;

    logic        cpu_rsp_valid;
    logic        cpu_rsp_ready;
    logic [31:0] cpu_rsp_rdata;

    logic        mem_req_valid;
    logic        mem_req_ready;
    logic        mem_req_write;
    logic [7:0]  mem_req_addr;
    logic [31:0] mem_req_wdata;

    logic        mem_rsp_valid;
    logic        mem_rsp_ready;
    logic [31:0] mem_rsp_rdata;

    always #5 clk = ~clk;

    cache_controller dut (
        .clk,
        .rst_n,
        .cpu_req_valid,
        .cpu_req_ready,
        .cpu_req_write,
        .cpu_req_addr,
        .cpu_req_wdata,
        .cpu_req_wstrb,
        .cpu_rsp_valid,
        .cpu_rsp_ready,
        .cpu_rsp_rdata,
        .mem_req_valid,
        .mem_req_ready,
        .mem_req_write,
        .mem_req_addr,
        .mem_req_wdata,
        .mem_rsp_valid,
        .mem_rsp_ready,
        .mem_rsp_rdata
    );

    initial begin
        rst_n         = 0;
        cpu_req_valid = 0;
        cpu_req_write = 0;
        cpu_req_addr  = 0;
        cpu_req_wdata = 0;
        cpu_req_wstrb = 0;
        cpu_rsp_ready = 0;

        mem_req_ready = 0;
        mem_rsp_valid = 0;
        mem_rsp_rdata = 0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst_n = 1;

        // Install a clean conflicting line at index 1.
        //
        // Existing address: 0x04
        // tag = 0, index = 1
        dut.valid_array[1] = 1'b1;
        dut.dirty_array[1] = 1'b0;
        dut.tag_array[1]   = 4'h0;
        dut.data_array[1]  = 32'hDEAD_BEEF;

        // Write miss to 0x44:
        // tag = 4, index = 1
        cpu_req_valid = 1;
        cpu_req_write = 1;
        cpu_req_addr  = 8'h44;
        cpu_req_wdata = 32'hAABB_CCDD;
        cpu_req_wstrb = 4'b0101;

        // Request handshake: IDLE -> LOOKUP.
        @(posedge clk);
        #1;
        cpu_req_valid = 0;

        // LOOKUP -> REFILL_REQ.
        @(posedge clk);
        #1;

        if (mem_req_valid !== 1'b1)
            $fatal(1, "Write miss did not generate refill request");

        if (mem_req_write !== 1'b0)
            $fatal(1, "Write allocation must begin with memory read");

        if (mem_req_addr !== 8'h44)
            $fatal(1, "Write-miss refill used incorrect address");

        // A clean victim must not be written back.
        if (mem_req_wdata !== 32'h0000_0000)
            $fatal(1, "Unexpected writeback data during clean miss");

        // Stall memory request.
        repeat (2) begin
            @(posedge clk);
            #1;

            if (mem_req_valid !== 1'b1)
                $fatal(1, "Refill request dropped while stalled");

            if (mem_req_write !== 1'b0)
                $fatal(1, "Refill request type changed while stalled");

            if (mem_req_addr !== 8'h44)
                $fatal(1, "Refill address changed while stalled");
        end

        // Accept refill request.
        @(negedge clk);
        mem_req_ready = 1;

        @(posedge clk);
        #1;
        mem_req_ready = 0;

        if (mem_rsp_ready !== 1'b1)
            $fatal(1, "Cache not ready for refill response");

        // Delay the response.
        repeat (2) begin
            @(posedge clk);
            #1;

            if (cpu_rsp_valid !== 1'b0)
                $fatal(1, "CPU response occurred before refill");
        end

        // Memory returns:
        //
        // Refill word = 11 22 33 44
        // CPU data    = AA BB CC DD
        // WSTRB       = 0  1  0  1
        // Result      = 11 BB 33 DD
        @(negedge clk);
        mem_rsp_valid = 1;
        mem_rsp_rdata = 32'h1122_3344;

        @(posedge clk);
        #1;
        mem_rsp_valid = 0;

        if (cpu_rsp_valid !== 1'b1)
            $fatal(1, "Write-miss completion response missing");

        if (cpu_rsp_rdata !== 32'h0000_0000)
            $fatal(1, "Write completion response data must be zero");

        if (dut.valid_array[1] !== 1'b1)
            $fatal(1, "Write allocation did not set valid");

        if (dut.dirty_array[1] !== 1'b1)
            $fatal(1, "Write allocation did not set dirty");

        if (dut.tag_array[1] !== 4'h4)
            $fatal(1, "Write allocation installed incorrect tag");

        if (dut.data_array[1] !== 32'h11BB_33DD)
            $fatal(1, "Write allocation WSTRB merge failed");

        // Stall write completion response.
        repeat (2) begin
            @(posedge clk);
            #1;

            if (cpu_rsp_valid !== 1'b1)
                $fatal(1, "Write response dropped while stalled");

            if (dut.data_array[1] !== 32'h11BB_33DD)
                $fatal(1, "Allocated line changed while response stalled");
        end

        // Consume write response.
        @(negedge clk);
        cpu_rsp_ready = 1;

        @(posedge clk);
        #1;
        cpu_rsp_ready = 0;

        if (cpu_req_ready !== 1'b1)
            $fatal(1, "Controller did not return to IDLE");

        // Read the same address. This must now hit.
        cpu_req_valid = 1;
        cpu_req_write = 0;
        cpu_req_addr  = 8'h44;
        cpu_req_wdata = 0;
        cpu_req_wstrb = 0;

        @(posedge clk);
        #1;
        cpu_req_valid = 0;

        @(posedge clk);
        #1;

        if (cpu_rsp_valid !== 1'b1)
            $fatal(1, "Read after write allocation did not hit");

        if (cpu_rsp_rdata !== 32'h11BB_33DD)
            $fatal(1, "Read after write allocation returned wrong data");

        if (mem_req_valid !== 1'b0)
            $fatal(1, "Read hit unexpectedly accessed memory");

        $display("PASS: write miss, write allocation and WSTRB merge");
        $finish;
    end

endmodule