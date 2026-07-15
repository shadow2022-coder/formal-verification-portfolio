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

        #1;
        if (cpu_req_ready !== 1'b1)
            $fatal(1, "cpu_req_ready must be high in IDLE");

        cpu_req_valid = 1'b1;
        cpu_req_write = 1'b1;
        cpu_req_addr  = 8'h44;
        cpu_req_wdata = 32'hAABB_CCDD;
        cpu_req_wstrb = 4'b1010;

        @(posedge clk);
        #1;

        cpu_req_valid = 1'b0;

        if (dut.state !== 3'd1)
            $fatal(1, "Controller did not enter LOOKUP");

        if (dut.req_write_reg !== 1'b1)
            $fatal(1, "Write flag was not captured");

        if (dut.req_addr_reg !== 8'h44)
            $fatal(1, "Address was not captured");

        if (dut.req_wdata_reg !== 32'hAABB_CCDD)
            $fatal(1, "Write data was not captured");

        if (dut.req_wstrb_reg !== 4'b1010)
            $fatal(1, "Write strobe was not captured");

        if (cpu_req_ready !== 1'b0)
            $fatal(1, "Cache accepted a second request while busy");

        $display("PASS: reset and CPU request capture");
        $finish;
    end

endmodule
