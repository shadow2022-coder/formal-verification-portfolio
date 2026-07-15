`timescale 1ns/1ps

module cache_tb;

    logic clk = 1'b0;
    logic rst_n;

    // CPU request
    logic        cpu_req_valid;
    logic        cpu_req_ready;
    logic        cpu_req_write;
    logic [7:0]  cpu_req_addr;
    logic [31:0] cpu_req_wdata;
    logic [3:0]  cpu_req_wstrb;

    // CPU response
    logic        cpu_rsp_valid;
    logic        cpu_rsp_ready;
    logic [31:0] cpu_rsp_rdata;

    // Memory request
    logic        mem_req_valid;
    logic        mem_req_ready;
    logic        mem_req_write;
    logic [7:0]  mem_req_addr;
    logic [31:0] mem_req_wdata;

    // Memory response
    logic        mem_rsp_valid;
    logic        mem_rsp_ready;
    logic [31:0] mem_rsp_rdata;

    // Memory-model controls
    logic       force_req_stall;
    logic [7:0] response_delay_cycles;

    integer mem_read_requests;
    integer mem_write_requests;

    logic [31:0] read_data;
    integer      reads_before;
    integer      writes_before;

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

    memory_model mem (
        .clk,
        .rst_n,

        .mem_req_valid,
        .mem_req_ready,
        .mem_req_write,
        .mem_req_addr,
        .mem_req_wdata,

        .mem_rsp_valid,
        .mem_rsp_ready,
        .mem_rsp_rdata,

        .force_req_stall,
        .response_delay_cycles
    );

    // Count accepted backing-memory transactions.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_read_requests  <= 0;
            mem_write_requests <= 0;
        end else if (mem_req_valid && mem_req_ready) begin
            if (mem_req_write) begin
                mem_write_requests <= mem_write_requests + 1;
            end else begin
                mem_read_requests <= mem_read_requests + 1;
            end
        end
    end

    task automatic reset_system;
        begin
            rst_n         = 1'b0;

            cpu_req_valid = 1'b0;
            cpu_req_write = 1'b0;
            cpu_req_addr  = '0;
            cpu_req_wdata = '0;
            cpu_req_wstrb = '0;
            cpu_rsp_ready = 1'b0;

            force_req_stall      = 1'b0;
            response_delay_cycles = 8'd2;

            repeat (3) @(posedge clk);
            @(negedge clk);
            rst_n = 1'b1;
        end
    endtask

    task automatic cpu_read (
        input  logic [7:0]  address,
        output logic [31:0] returned_data
    );
        integer timeout;

        begin
            timeout = 0;

            while (cpu_req_ready !== 1'b1) begin
                @(posedge clk);
                #1;

                timeout = timeout + 1;

                if (timeout > 100) begin
                    $fatal(1, "Timeout waiting for CPU request readiness");
                end
            end

            @(negedge clk);

            cpu_req_valid = 1'b1;
            cpu_req_write = 1'b0;
            cpu_req_addr  = address;
            cpu_req_wdata = '0;
            cpu_req_wstrb = '0;

            @(posedge clk);
            #1;

            cpu_req_valid = 1'b0;

            timeout = 0;

            while (cpu_rsp_valid !== 1'b1) begin
                @(posedge clk);
                #1;

                timeout = timeout + 1;

                if (timeout > 100) begin
                    $fatal(1, "Timeout waiting for CPU read response");
                end
            end

            returned_data = cpu_rsp_rdata;

            @(negedge clk);
            cpu_rsp_ready = 1'b1;

            @(posedge clk);
            #1;

            @(negedge clk);
            cpu_rsp_ready = 1'b0;
        end
    endtask

    task automatic cpu_write (
        input logic [7:0]  address,
        input logic [31:0] write_data,
        input logic [3:0]  write_strobe
    );
        integer timeout;

        begin
            timeout = 0;

            while (cpu_req_ready !== 1'b1) begin
                @(posedge clk);
                #1;

                timeout = timeout + 1;

                if (timeout > 100) begin
                    $fatal(1, "Timeout waiting for CPU request readiness");
                end
            end

            @(negedge clk);

            cpu_req_valid = 1'b1;
            cpu_req_write = 1'b1;
            cpu_req_addr  = address;
            cpu_req_wdata = write_data;
            cpu_req_wstrb = write_strobe;

            @(posedge clk);
            #1;

            cpu_req_valid = 1'b0;

            timeout = 0;

            while (cpu_rsp_valid !== 1'b1) begin
                @(posedge clk);
                #1;

                timeout = timeout + 1;

                if (timeout > 100) begin
                    $fatal(1, "Timeout waiting for CPU write response");
                end
            end

            if (cpu_rsp_rdata !== 32'h0000_0000) begin
                $fatal(1, "Write completion response data was not zero");
            end

            @(negedge clk);
            cpu_rsp_ready = 1'b1;

            @(posedge clk);
            #1;

            @(negedge clk);
            cpu_rsp_ready = 1'b0;
        end
    endtask

    initial begin
        reset_system();

        // Address 0x04:
        // word index = 1
        // cache index = 1
        // tag = 0
        mem.memory[1] = 32'h1122_3344;

        // ---------------------------------------------------------------------
        // Scenario 1: Cold read miss and refill
        // ---------------------------------------------------------------------

        reads_before = mem_read_requests;

        cpu_read(8'h04, read_data);

        if (read_data !== 32'h1122_3344) begin
            $fatal(1, "Cold read miss returned incorrect data");
        end

        if (mem_read_requests !== reads_before + 1) begin
            $fatal(1, "Cold read miss did not issue one memory read");
        end

        if (dut.valid_array[1] !== 1'b1) begin
            $fatal(1, "Cold refill did not set valid");
        end

        if (dut.dirty_array[1] !== 1'b0) begin
            $fatal(1, "Cold read refill incorrectly set dirty");
        end

        if (dut.tag_array[1] !== 4'h0) begin
            $fatal(1, "Cold refill installed incorrect tag");
        end

        if (dut.data_array[1] !== 32'h1122_3344) begin
            $fatal(1, "Cold refill installed incorrect data");
        end

        $display("PASS 1: cold read miss and refill");

        // ---------------------------------------------------------------------
        // Scenario 2: Second read to same address must hit
        // ---------------------------------------------------------------------

        reads_before = mem_read_requests;

        cpu_read(8'h04, read_data);

        if (read_data !== 32'h1122_3344) begin
            $fatal(1, "Read hit returned incorrect data");
        end

        if (mem_read_requests !== reads_before) begin
            $fatal(1, "Read hit unexpectedly accessed memory");
        end

        $display("PASS 2: second read hits");

        // ---------------------------------------------------------------------
        // Scenario 3: Full write hit sets dirty
        // ---------------------------------------------------------------------

        reads_before  = mem_read_requests;
        writes_before = mem_write_requests;

        cpu_write(
            8'h04,
            32'hAABB_CCDD,
            4'b1111
        );

        if (dut.data_array[1] !== 32'hAABB_CCDD) begin
            $fatal(1, "Full write hit stored incorrect data");
        end

        if (dut.dirty_array[1] !== 1'b1) begin
            $fatal(1, "Full write hit did not set dirty");
        end

        if (dut.valid_array[1] !== 1'b1) begin
            $fatal(1, "Full write hit changed valid state");
        end

        if (dut.tag_array[1] !== 4'h0) begin
            $fatal(1, "Full write hit changed tag");
        end

        if (mem_read_requests !== reads_before ||
            mem_write_requests !== writes_before) begin
            $fatal(1, "Write hit unexpectedly accessed memory");
        end

        // Write-back policy means backing memory is still unchanged.
        if (mem.memory[1] !== 32'h1122_3344) begin
            $fatal(1, "Write hit incorrectly updated backing memory");
        end

        $display("PASS 3: write hit sets dirty");

        // ---------------------------------------------------------------------
        // Scenario 4: Read-after-write returns cached updated data
        // ---------------------------------------------------------------------

        reads_before = mem_read_requests;

        cpu_read(8'h04, read_data);

        if (read_data !== 32'hAABB_CCDD) begin
            $fatal(1, "Read-after-write returned incorrect data");
        end

        if (mem_read_requests !== reads_before) begin
            $fatal(1, "Read-after-write unexpectedly accessed memory");
        end

        $display("PASS 4: read-after-write returns updated data");

        // ---------------------------------------------------------------------
        // Scenario 5: Partial WSTRB write
        //
        // Old word = AA BB CC DD
        // New word = 55 66 77 88
        // WSTRB    = 0  1  0  1
        //
        // Updated bytes:
        // byte 2 = 66
        // byte 0 = 88
        //
        // Result = AA 66 CC 88
        // ---------------------------------------------------------------------

        cpu_write(
            8'h04,
            32'h5566_7788,
            4'b0101
        );

        if (dut.data_array[1] !== 32'hAA66_CC88) begin
            $fatal(1, "Partial WSTRB write produced incorrect data");
        end

        if (dut.dirty_array[1] !== 1'b1) begin
            $fatal(1, "Partial write did not preserve dirty state");
        end

        reads_before = mem_read_requests;

        cpu_read(8'h04, read_data);

        if (read_data !== 32'hAA66_CC88) begin
            $fatal(1, "Read after partial write returned wrong data");
        end

        if (mem_read_requests !== reads_before) begin
            $fatal(1, "Partial-write readback unexpectedly accessed memory");
        end

        $display("PASS 5: partial WSTRB write");

        $display("PASS: directed scenarios 1 through 5");
        $finish;
    end

endmodule