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
        rst_n          = 0;
        cpu_req_valid  = 0;
        cpu_req_write  = 0;
        cpu_req_addr   = 0;
        cpu_req_wdata  = 0;
        cpu_req_wstrb  = 0;
        cpu_rsp_ready  = 0;

        mem_req_ready  = 0;
        mem_rsp_valid  = 0;
        mem_rsp_rdata  = 0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst_n = 1;

        // Address 0x04: tag 0, index 1.
        dut.valid_array[1] = 1'b1;
        dut.dirty_array[1] = 1'b0;
        dut.tag_array[1]   = 4'h0;
        dut.data_array[1]  = 32'h1122_3344;

        // Partial write hit:
        // old   = 11 22 33 44
        // new   = AA BB CC DD
        // wstrb = 1  0  1  0
        // result= AA 22 CC 44
        cpu_req_valid = 1;
        cpu_req_write = 1;
        cpu_req_addr  = 8'h04;
        cpu_req_wdata = 32'hAABB_CCDD;
        cpu_req_wstrb = 4'b1010;

        @(posedge clk);
        #1;
        cpu_req_valid = 0;

        @(posedge clk);
        #1;

        if (cpu_rsp_valid !== 1'b1)
            $fatal(1, "Write-hit response missing");

        if (cpu_rsp_rdata !== 32'h0000_0000)
            $fatal(1, "Write response data is not zero");

        if (dut.data_array[1] !== 32'hAA22_CC44)
            $fatal(1, "WSTRB masking failed");

        if (dut.dirty_array[1] !== 1'b1)
            $fatal(1, "Dirty bit was not set");

        if (dut.valid_array[1] !== 1'b1)
            $fatal(1, "Valid bit changed");

        if (dut.tag_array[1] !== 4'h0)
            $fatal(1, "Tag changed");

        if (mem_req_valid !== 1'b0)
            $fatal(1, "Write hit accessed memory");

        repeat (3) begin
            @(posedge clk);
            #1;

            if (cpu_rsp_valid !== 1'b1)
                $fatal(1, "Response dropped while stalled");

            if (cpu_rsp_rdata !== 32'h0000_0000)
                $fatal(1, "Response data changed while stalled");

            if (dut.data_array[1] !== 32'hAA22_CC44)
                $fatal(1, "Cache data changed while stalled");
        end

        @(negedge clk);
        cpu_rsp_ready = 1;

        @(posedge clk);
        #1;
        cpu_rsp_ready = 0;

        if (cpu_rsp_valid !== 1'b0)
            $fatal(1, "Response remained valid after handshake");

        if (cpu_req_ready !== 1'b1)
            $fatal(1, "Controller did not return to IDLE");

        $display("PASS: write hit, WSTRB masking and dirty update");
        $finish;
    end

endmodule
