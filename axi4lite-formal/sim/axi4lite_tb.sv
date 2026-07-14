`timescale 1ns/1ps

module axi4lite_tb;

    localparam logic [1:0] AXI_OKAY   = 2'b00;
    localparam logic [1:0] AXI_SLVERR = 2'b10;

    logic        aclk;
    logic        aresetn;

    logic [3:0]  s_axi_awaddr;
    logic        s_axi_awvalid;
    logic        s_axi_awready;

    logic [31:0] s_axi_wdata;
    logic [3:0]  s_axi_wstrb;
    logic        s_axi_wvalid;
    logic        s_axi_wready;

    logic [1:0]  s_axi_bresp;
    logic        s_axi_bvalid;
    logic        s_axi_bready;

    logic [3:0]  s_axi_araddr;
    logic        s_axi_arvalid;
    logic        s_axi_arready;

    logic [31:0] s_axi_rdata;
    logic [1:0]  s_axi_rresp;
    logic        s_axi_rvalid;
    logic        s_axi_rready;

    integer failures;

    axi4lite_regs dut (
        .aclk          (aclk),
        .aresetn       (aresetn),

        .s_axi_awaddr  (s_axi_awaddr),
        .s_axi_awvalid (s_axi_awvalid),
        .s_axi_awready (s_axi_awready),

        .s_axi_wdata   (s_axi_wdata),
        .s_axi_wstrb   (s_axi_wstrb),
        .s_axi_wvalid  (s_axi_wvalid),
        .s_axi_wready  (s_axi_wready),

        .s_axi_bresp   (s_axi_bresp),
        .s_axi_bvalid  (s_axi_bvalid),
        .s_axi_bready  (s_axi_bready),

        .s_axi_araddr  (s_axi_araddr),
        .s_axi_arvalid (s_axi_arvalid),
        .s_axi_arready (s_axi_arready),

        .s_axi_rdata   (s_axi_rdata),
        .s_axi_rresp   (s_axi_rresp),
        .s_axi_rvalid  (s_axi_rvalid),
        .s_axi_rready  (s_axi_rready)
    );

    // 10 ns clock period
    initial begin
        aclk = 1'b0;
        forever #5 aclk = ~aclk;
    end

    task automatic reset_dut;
        begin
            @(negedge aclk);

            aresetn       = 1'b0;

            s_axi_awaddr  = '0;
            s_axi_awvalid = 1'b0;

            s_axi_wdata   = '0;
            s_axi_wstrb   = '0;
            s_axi_wvalid  = 1'b0;

            s_axi_bready  = 1'b0;

            s_axi_araddr  = '0;
            s_axi_arvalid = 1'b0;

            s_axi_rready  = 1'b0;

            repeat (3) @(posedge aclk);

            @(negedge aclk);
            aresetn = 1'b1;

            @(posedge aclk);
        end
    endtask

    task automatic send_write_address(
        input logic [3:0] address,
        input integer delay_cycles
    );
        begin
            repeat (delay_cycles) @(posedge aclk);

            @(negedge aclk);
            s_axi_awaddr  = address;
            s_axi_awvalid = 1'b1;

            do begin
                @(posedge aclk);
            end while (!(s_axi_awvalid && s_axi_awready));

            @(negedge aclk);
            s_axi_awvalid = 1'b0;
        end
    endtask

    task automatic send_write_data(
        input logic [31:0] data,
        input logic [3:0]  strobe,
        input integer delay_cycles
    );
        begin
            repeat (delay_cycles) @(posedge aclk);

            @(negedge aclk);
            s_axi_wdata  = data;
            s_axi_wstrb  = strobe;
            s_axi_wvalid = 1'b1;

            do begin
                @(posedge aclk);
            end while (!(s_axi_wvalid && s_axi_wready));

            @(negedge aclk);
            s_axi_wvalid = 1'b0;
        end
    endtask

    task automatic axi_write(
        input  logic [3:0]  address,
        input  logic [31:0] data,
        input  logic [3:0]  strobe,
        input  integer      address_delay,
        input  integer      data_delay,
        input  integer      response_stall_cycles,
        output logic [1:0]  response
    );
        logic [1:0] held_response;

        begin
            @(negedge aclk);
            s_axi_bready = 1'b0;

            fork
                send_write_address(address, address_delay);
                send_write_data(data, strobe, data_delay);
            join

            // Wait until the slave produces a response.
            while (!s_axi_bvalid)
                @(posedge aclk);

            held_response = s_axi_bresp;

            // Apply write-response backpressure.
            repeat (response_stall_cycles) begin
                @(posedge aclk);

                if (!s_axi_bvalid) begin
                    $error("BVALID dropped while BREADY was low");
                    failures = failures + 1;
                end

                if (s_axi_bresp !== held_response) begin
                    $error("BRESP changed while stalled");
                    failures = failures + 1;
                end
            end

            @(negedge aclk);
            s_axi_bready = 1'b1;

            do begin
                @(posedge aclk);
            end while (!(s_axi_bvalid && s_axi_bready));

            response = s_axi_bresp;

            @(negedge aclk);
            s_axi_bready = 1'b0;
        end
    endtask

    task automatic send_read_address(
        input logic [3:0] address,
        input integer delay_cycles
    );
        begin
            repeat (delay_cycles) @(posedge aclk);

            @(negedge aclk);
            s_axi_araddr  = address;
            s_axi_arvalid = 1'b1;

            do begin
                @(posedge aclk);
            end while (!(s_axi_arvalid && s_axi_arready));

            @(negedge aclk);
            s_axi_arvalid = 1'b0;
        end
    endtask

    task automatic axi_read(
        input  logic [3:0]  address,
        input  integer      address_delay,
        input  integer      response_stall_cycles,
        output logic [31:0] data,
        output logic [1:0]  response
    );
        logic [31:0] held_data;
        logic [1:0]  held_response;

        begin
            @(negedge aclk);
            s_axi_rready = 1'b0;

            send_read_address(address, address_delay);

            while (!s_axi_rvalid)
                @(posedge aclk);

            held_data     = s_axi_rdata;
            held_response = s_axi_rresp;

            // Apply read-response backpressure.
            repeat (response_stall_cycles) begin
                @(posedge aclk);

                if (!s_axi_rvalid) begin
                    $error("RVALID dropped while RREADY was low");
                    failures = failures + 1;
                end

                if (s_axi_rdata !== held_data) begin
                    $error("RDATA changed while stalled");
                    failures = failures + 1;
                end

                if (s_axi_rresp !== held_response) begin
                    $error("RRESP changed while stalled");
                    failures = failures + 1;
                end
            end

            @(negedge aclk);
            s_axi_rready = 1'b1;

            do begin
                @(posedge aclk);
            end while (!(s_axi_rvalid && s_axi_rready));

            data     = s_axi_rdata;
            response = s_axi_rresp;

            @(negedge aclk);
            s_axi_rready = 1'b0;
        end
    endtask

    task automatic check_response(
        input logic [1:0] actual,
        input logic [1:0] expected,
        input string test_name
    );
        begin
            if (actual !== expected) begin
                $error("%s: response=%b expected=%b",
                       test_name, actual, expected);
                failures = failures + 1;
            end else begin
                $display("PASS: %s", test_name);
            end
        end
    endtask

    task automatic check_data(
        input logic [31:0] actual,
        input logic [31:0] expected,
        input string test_name
    );
        begin
            if (actual !== expected) begin
                $error("%s: data=%h expected=%h",
                       test_name, actual, expected);
                failures = failures + 1;
            end else begin
                $display("PASS: %s = %h", test_name, actual);
            end
        end
    endtask

    logic [1:0]  write_response;
    logic [1:0]  read_response;
    logic [31:0] read_data;

    logic [1:0]  concurrent_write_response;
    logic [1:0]  concurrent_read_response;
    logic [31:0] concurrent_read_data;

    initial begin
        $dumpfile("build/axi4lite.vcd");
        $dumpvars(0, axi4lite_tb);

        failures = 0;

        aresetn       = 1'b0;
        s_axi_awaddr  = '0;
        s_axi_awvalid = 1'b0;
        s_axi_wdata   = '0;
        s_axi_wstrb   = '0;
        s_axi_wvalid  = 1'b0;
        s_axi_bready  = 1'b0;
        s_axi_araddr  = '0;
        s_axi_arvalid = 1'b0;
        s_axi_rready  = 1'b0;

        reset_dut();

        // Test 1: address and data arrive together.
        axi_write(
            4'h0,
            32'h1122_3344,
            4'b1111,
            0,
            0,
            0,
            write_response
        );

        check_response(
            write_response,
            AXI_OKAY,
            "same-cycle write response"
        );

        axi_read(4'h0, 0, 0, read_data, read_response);
        check_response(read_response, AXI_OKAY, "CONTROL read response");
        check_data(read_data, 32'h1122_3344, "CONTROL value");

        // Test 2: address arrives before data.
        axi_write(
            4'h8,
            32'hAABB_CCDD,
            4'b1111,
            0,
            3,
            0,
            write_response
        );

        check_response(
            write_response,
            AXI_OKAY,
            "address-before-data response"
        );

        axi_read(4'h8, 0, 0, read_data, read_response);
        check_data(read_data, 32'hAABB_CCDD, "DATA0 full write");

        // Test 3: data arrives before address.
        axi_write(
            4'hC,
            32'h5566_7788,
            4'b1111,
            3,
            0,
            0,
            write_response
        );

        check_response(
            write_response,
            AXI_OKAY,
            "data-before-address response"
        );

        axi_read(4'hC, 0, 0, read_data, read_response);
        check_data(read_data, 32'h5566_7788, "DATA1 value");

        // Test 4: partial-byte write.
        //
        // Old DATA0 = AA BB CC DD
        // New WDATA = 11 22 33 44
        // WSTRB     = 0  1  0  1
        // Result    = AA 22 CC 44
        axi_write(
            4'h8,
            32'h1122_3344,
            4'b0101,
            0,
            0,
            0,
            write_response
        );

        axi_read(4'h8, 0, 0, read_data, read_response);
        check_data(read_data, 32'hAA22_CC44, "DATA0 partial write");

        // Test 5: write-response backpressure.
        axi_write(
            4'h4,
            32'hDEAD_BEEF,
            4'b1111,
            0,
            0,
            3,
            write_response
        );

        check_response(
            write_response,
            AXI_OKAY,
            "write-response backpressure"
        );

        // Test 6: read-data backpressure.
        axi_read(4'h4, 0, 3, read_data, read_response);
        check_response(
            read_response,
            AXI_OKAY,
            "read-response backpressure"
        );
        check_data(read_data, 32'hDEAD_BEEF, "STATUS stalled read");

        // Test 7: invalid write address.
        axi_write(
            4'h2,
            32'hFFFF_FFFF,
            4'b1111,
            0,
            0,
            0,
            write_response
        );

        check_response(
            write_response,
            AXI_SLVERR,
            "invalid write address"
        );

        // Test 8: invalid read address.
        axi_read(4'h2, 0, 0, read_data, read_response);
        check_response(
            read_response,
            AXI_SLVERR,
            "invalid read address"
        );
        check_data(read_data, 32'h0000_0000, "invalid read data");

        // Test 9: concurrent read and write.
        fork
            begin
                axi_write(
                    4'h8,
                    32'hCAFE_BABE,
                    4'b1111,
                    0,
                    1,
                    1,
                    concurrent_write_response
                );
            end

            begin
                axi_read(
                    4'h0,
                    0,
                    2,
                    concurrent_read_data,
                    concurrent_read_response
                );
            end
        join

        check_response(
            concurrent_write_response,
            AXI_OKAY,
            "concurrent write"
        );

        check_response(
            concurrent_read_response,
            AXI_OKAY,
            "concurrent read"
        );

        check_data(
            concurrent_read_data,
            32'h1122_3344,
            "concurrent CONTROL read"
        );

        axi_read(4'h8, 0, 0, read_data, read_response);
        check_data(read_data, 32'hCAFE_BABE, "concurrent DATA0 write");

        // Test 10: reset clears all registers and transaction state.
        reset_dut();

        axi_read(4'h0, 0, 0, read_data, read_response);
        check_data(read_data, 32'h0000_0000, "CONTROL after reset");

        axi_read(4'h4, 0, 0, read_data, read_response);
        check_data(read_data, 32'h0000_0000, "STATUS after reset");

        axi_read(4'h8, 0, 0, read_data, read_response);
        check_data(read_data, 32'h0000_0000, "DATA0 after reset");

        axi_read(4'hC, 0, 0, read_data, read_response);
        check_data(read_data, 32'h0000_0000, "DATA1 after reset");

        if (failures == 0) begin
            $display("");
            $display("======================================");
            $display("ALL AXI4-LITE SIMULATION TESTS PASSED");
            $display("======================================");
        end else begin
            $display("");
            $display("SIMULATION FAILED: %0d error(s)", failures);
            $fatal(1);
        end

        #20;
        $finish;
    end

endmodule