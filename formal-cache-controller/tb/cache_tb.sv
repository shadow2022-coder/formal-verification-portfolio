`timescale 1ns/1ps

module cache_tb;

    localparam int ADDR_WIDTH = 8;
    localparam int DATA_WIDTH = 32;

    logic clk;
    logic rst_n;

    logic                      cpu_req_valid;
    logic                      cpu_req_ready;
    logic                      cpu_req_write;
    logic [ADDR_WIDTH-1:0]     cpu_req_addr;
    logic [DATA_WIDTH-1:0]     cpu_req_wdata;
    logic [(DATA_WIDTH/8)-1:0] cpu_req_wstrb;

    logic                      cpu_rsp_valid;
    logic                      cpu_rsp_ready;
    logic [DATA_WIDTH-1:0]     cpu_rsp_rdata;

    logic                      mem_req_valid;
    logic                      mem_req_ready;
    logic                      mem_req_write;
    logic [ADDR_WIDTH-1:0]     mem_req_addr;
    logic [DATA_WIDTH-1:0]     mem_req_wdata;

    logic                      mem_rsp_valid;
    logic                      mem_rsp_ready;
    logic [DATA_WIDTH-1:0]     mem_rsp_rdata;

    cache_controller dut (
        .clk            (clk),
        .rst_n          (rst_n),

        .cpu_req_valid  (cpu_req_valid),
        .cpu_req_ready  (cpu_req_ready),
        .cpu_req_write  (cpu_req_write),
        .cpu_req_addr   (cpu_req_addr),
        .cpu_req_wdata  (cpu_req_wdata),
        .cpu_req_wstrb  (cpu_req_wstrb),

        .cpu_rsp_valid  (cpu_rsp_valid),
        .cpu_rsp_ready  (cpu_rsp_ready),
        .cpu_rsp_rdata  (cpu_rsp_rdata),

        .mem_req_valid  (mem_req_valid),
        .mem_req_ready  (mem_req_ready),
        .mem_req_write  (mem_req_write),
        .mem_req_addr   (mem_req_addr),
        .mem_req_wdata  (mem_req_wdata),

        .mem_rsp_valid  (mem_rsp_valid),
        .mem_rsp_ready  (mem_rsp_ready),
        .mem_rsp_rdata  (mem_rsp_rdata)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 1'b0;

        cpu_req_valid = 1'b0;
        cpu_req_write = 1'b0;
        cpu_req_addr  = '0;
        cpu_req_wdata = '0;
        cpu_req_wstrb = '0;
        cpu_rsp_ready = 1'b0;

        mem_req_ready = 1'b0;
        mem_rsp_valid = 1'b0;
        mem_rsp_rdata = '0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;

        // Address 0x04:
        // tag   = 0
        // index = 1
        // offset = 0
        dut.valid_array[1] = 1'b1;
        dut.dirty_array[1] = 1'b0;
        dut.tag_array[1]   = 4'h0;
        dut.data_array[1]  = 32'h1234_ABCD;

        // Submit a read request while keeping the response blocked.
        cpu_req_valid = 1'b1;
        cpu_req_write = 1'b0;
        cpu_req_addr  = 8'h04;

        @(posedge clk);
        #1;
        cpu_req_valid = 1'b0;

        // IDLE -> LOOKUP
        @(posedge clk);
        #1;

        // LOOKUP -> RESPOND
        if (cpu_rsp_valid !== 1'b1)
            $fatal(1, "Read-hit response was not generated");

        if (cpu_rsp_rdata !== 32'h1234_ABCD)
            $fatal(1, "Read-hit returned incorrect data");

        if (mem_req_valid !== 1'b0)
            $fatal(1, "Read hit must not access memory");

        // Hold the CPU response blocked for several cycles.
        repeat (3) begin
            @(posedge clk);
            #1;

            if (cpu_rsp_valid !== 1'b1)
                $fatal(1, "cpu_rsp_valid dropped during backpressure");

            if (cpu_rsp_rdata !== 32'h1234_ABCD)
                $fatal(1, "cpu_rsp_rdata changed during backpressure");

            if (cpu_req_ready !== 1'b0)
                $fatal(1, "Cache accepted a request while response pending");
        end

        // Accept the response.
        cpu_rsp_ready = 1'b1;

        @(posedge clk);
        #1;

        cpu_rsp_ready = 1'b0;

        if (cpu_rsp_valid !== 1'b0)
            $fatal(1, "cpu_rsp_valid remained asserted after handshake");

        if (cpu_req_ready !== 1'b1)
            $fatal(1, "Controller did not return to IDLE");

        $display("PASS: read hit and CPU response backpressure");
        $finish;
    end

endmodule