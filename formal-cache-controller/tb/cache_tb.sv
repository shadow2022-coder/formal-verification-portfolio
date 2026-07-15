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

        // Dirty victim represents address 0x04:
        // stored tag = 0, index = 1.
        dut.valid_array[1] = 1'b1;
        dut.dirty_array[1] = 1'b1;
        dut.tag_array[1]   = 4'h0;
        dut.data_array[1]  = 32'hDEAD_BEEF;

        // Conflicting read request to 0x44:
        // incoming tag = 4, index = 1.
        cpu_req_valid = 1;
        cpu_req_write = 0;
        cpu_req_addr  = 8'h44;

        // Request accepted: IDLE -> LOOKUP.
        @(posedge clk);
        #1;
        cpu_req_valid = 0;

        // LOOKUP -> WRITEBACK_REQ.
        @(posedge clk);
        #1;

        if (mem_req_valid !== 1'b1)
            $fatal(1, "Dirty miss did not generate writeback request");

        if (mem_req_write !== 1'b1)
            $fatal(1, "Dirty victim request was not a memory write");

        // Critical check: victim address is 0x04, not incoming 0x44.
        if (mem_req_addr !== 8'h04)
            $fatal(1, "Writeback used incorrect victim address");

        if (mem_req_wdata !== 32'hDEAD_BEEF)
            $fatal(1, "Writeback used incorrect victim data");

        // Stall writeback request.
        repeat (2) begin
            @(posedge clk);
            #1;

            if (mem_req_valid !== 1'b1)
                $fatal(1, "Writeback request dropped while stalled");

            if (mem_req_write !== 1'b1)
                $fatal(1, "Writeback request type changed while stalled");

            if (mem_req_addr !== 8'h04)
                $fatal(1, "Writeback address changed while stalled");

            if (mem_req_wdata !== 32'hDEAD_BEEF)
                $fatal(1, "Writeback data changed while stalled");
        end

        // Accept the writeback request.
        @(negedge clk);
        mem_req_ready = 1;

        @(posedge clk);
        #1;
        mem_req_ready = 0;

        if (mem_rsp_ready !== 1'b1)
            $fatal(1, "Cache not ready for writeback acknowledgement");

        // Victim must remain intact while waiting for acknowledgement.
        repeat (2) begin
            @(posedge clk);
            #1;

            if (mem_req_valid !== 1'b0)
                $fatal(1, "Refill began before writeback acknowledgement");

            if (dut.tag_array[1] !== 4'h0)
                $fatal(1, "Victim tag changed before acknowledgement");

            if (dut.data_array[1] !== 32'hDEAD_BEEF)
                $fatal(1, "Victim data changed before acknowledgement");

            if (dut.dirty_array[1] !== 1'b1)
                $fatal(1, "Victim dirty bit cleared too early");

            if (cpu_rsp_valid !== 1'b0)
                $fatal(1, "CPU response occurred before eviction completed");
        end

        // Send writeback acknowledgement.
        @(negedge clk);
        mem_rsp_valid = 1;
        mem_rsp_rdata = 0;

        @(posedge clk);
        #1;
        mem_rsp_valid = 0;

        // Cache must now issue the refill request for 0x44.
        if (mem_req_valid !== 1'b1)
            $fatal(1, "Refill did not begin after writeback acknowledgement");

        if (mem_req_write !== 1'b0)
            $fatal(1, "Refill request incorrectly marked as write");

        if (mem_req_addr !== 8'h44)
            $fatal(1, "Refill request used incorrect incoming address");

        // Stall refill request.
        repeat (2) begin
            @(posedge clk);
            #1;

            if (mem_req_valid !== 1'b1)
                $fatal(1, "Refill request dropped while stalled");

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

        // Delay refill response.
        repeat (2) begin
            @(posedge clk);
            #1;

            if (cpu_rsp_valid !== 1'b0)
                $fatal(1, "CPU response occurred before refill data");
        end

        // Return refill data for 0x44.
        @(negedge clk);
        mem_rsp_valid = 1;
        mem_rsp_rdata = 32'hCAFE_BABE;

        @(posedge clk);
        #1;
        mem_rsp_valid = 0;

        if (cpu_rsp_valid !== 1'b1)
            $fatal(1, "CPU response missing after dirty eviction refill");

        if (cpu_rsp_rdata !== 32'hCAFE_BABE)
            $fatal(1, "Dirty-miss read returned incorrect data");

        if (dut.valid_array[1] !== 1'b1)
            $fatal(1, "Refill did not leave line valid");

        if (dut.dirty_array[1] !== 1'b0)
            $fatal(1, "Read refill did not clear dirty bit");

        if (dut.tag_array[1] !== 4'h4)
            $fatal(1, "Refill installed incorrect incoming tag");

        if (dut.data_array[1] !== 32'hCAFE_BABE)
            $fatal(1, "Refill installed incorrect data");

        // Verify CPU response stability.
        repeat (2) begin
            @(posedge clk);
            #1;

            if (cpu_rsp_valid !== 1'b1)
                $fatal(1, "CPU response dropped while stalled");

            if (cpu_rsp_rdata !== 32'hCAFE_BABE)
                $fatal(1, "CPU response changed while stalled");
        end

        // Consume CPU response.
        @(negedge clk);
        cpu_rsp_ready = 1;

        @(posedge clk);
        #1;
        cpu_rsp_ready = 0;

        if (cpu_req_ready !== 1'b1)
            $fatal(1, "Controller did not return to IDLE");

        $display("PASS: dirty eviction, writeback, refill and read completion");
        $finish;
    end

endmodule