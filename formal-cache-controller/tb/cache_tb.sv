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

        // Cold read miss:
        // 0x44 = tag 4, index 1, offset 0.
        cpu_req_valid = 1;
        cpu_req_write = 0;
        cpu_req_addr  = 8'h44;

        @(posedge clk);
        #1;
        cpu_req_valid = 0;

        // LOOKUP detects invalid-line miss.
        @(posedge clk);
        #1;

        if (mem_req_valid !== 1'b1)
            $fatal(1, "Refill request was not generated");

        if (mem_req_write !== 1'b0)
            $fatal(1, "Refill request incorrectly marked as write");

        if (mem_req_addr !== 8'h44)
            $fatal(1, "Refill request used incorrect address");

        // Memory-request backpressure.
        repeat (2) begin
            @(posedge clk);
            #1;

            if (mem_req_valid !== 1'b1)
                $fatal(1, "Memory request dropped while stalled");

            if (mem_req_write !== 1'b0)
                $fatal(1, "Memory request type changed while stalled");

            if (mem_req_addr !== 8'h44)
                $fatal(1, "Memory request address changed while stalled");
        end

        // Accept refill request.
        @(negedge clk);
        mem_req_ready = 1;

        @(posedge clk);
        #1;
        mem_req_ready = 0;

        if (mem_rsp_ready !== 1'b1)
            $fatal(1, "Cache is not ready for refill response");

        // Delayed memory response.
        repeat (2) begin
            @(posedge clk);
            #1;

            if (cpu_rsp_valid !== 1'b0)
                $fatal(1, "CPU response occurred before refill");
        end

        // Return refill data.
        @(negedge clk);
        mem_rsp_valid = 1;
        mem_rsp_rdata = 32'hCAFE_BABE;

        @(posedge clk);
        #1;
        mem_rsp_valid = 0;

        if (cpu_rsp_valid !== 1'b1)
            $fatal(1, "CPU response missing after refill");

        if (cpu_rsp_rdata !== 32'hCAFE_BABE)
            $fatal(1, "Incorrect read-miss response data");

        if (dut.valid_array[1] !== 1'b1)
            $fatal(1, "Refill did not set valid bit");

        if (dut.dirty_array[1] !== 1'b0)
            $fatal(1, "Read refill incorrectly set dirty bit");

        if (dut.tag_array[1] !== 4'h4)
            $fatal(1, "Refill installed incorrect tag");

        if (dut.data_array[1] !== 32'hCAFE_BABE)
            $fatal(1, "Refill installed incorrect data");

        // Stall CPU response and verify stability.
        repeat (2) begin
            @(posedge clk);
            #1;

            if (cpu_rsp_valid !== 1'b1)
                $fatal(1, "CPU response dropped while stalled");

            if (cpu_rsp_rdata !== 32'hCAFE_BABE)
                $fatal(1, "CPU response changed while stalled");
        end

        // Consume response.
        @(negedge clk);
        cpu_rsp_ready = 1;

        @(posedge clk);
        #1;
        cpu_rsp_ready = 0;

        if (cpu_req_ready !== 1'b1)
            $fatal(1, "Controller did not return to IDLE");

        // Second read to same address must hit.
        cpu_req_valid = 1;
        cpu_req_write = 0;
        cpu_req_addr  = 8'h44;

        @(posedge clk);
        #1;
        cpu_req_valid = 0;

        @(posedge clk);
        #1;

        if (cpu_rsp_valid !== 1'b1)
            $fatal(1, "Second access did not produce hit response");

        if (cpu_rsp_rdata !== 32'hCAFE_BABE)
            $fatal(1, "Read hit after refill returned wrong data");

        if (mem_req_valid !== 1'b0)
            $fatal(1, "Read hit after refill accessed memory");

        $display("PASS: clean read miss, refill and subsequent hit");
        $finish;
    end

endmodule