module axi4lite_properties (
    input logic        aclk,
    input logic        aresetn,

    // Write address channel
    input logic [3:0]  s_axi_awaddr,
    input logic        s_axi_awvalid,
    input logic        s_axi_awready,

    // Write data channel
    input logic [31:0] s_axi_wdata,
    input logic [3:0]  s_axi_wstrb,
    input logic        s_axi_wvalid,
    input logic        s_axi_wready,

    // Write response channel
    input logic [1:0]  s_axi_bresp,
    input logic        s_axi_bvalid,
    input logic        s_axi_bready,

    // Read address channel
    input logic [3:0]  s_axi_araddr,
    input logic        s_axi_arvalid,
    input logic        s_axi_arready,

    // Read data channel
    input logic [31:0] s_axi_rdata,
    input logic [1:0]  s_axi_rresp,
    input logic        s_axi_rvalid,
    input logic        s_axi_rready
);

    localparam logic [1:0] AXI_OKAY   = 2'b00;
    localparam logic [1:0] AXI_SLVERR = 2'b10;

    logic f_past_valid = 1'b0;

    /*
     * Formal transaction scoreboard
     *
     * aw_seen:
     *   A write address was accepted, but its write data has not yet
     *   been accepted.
     *
     * w_seen:
     *   Write data was accepted, but its address has not yet been
     *   accepted.
     *
     * write_request_open:
     *   Both write components were accepted, but the write response
     *   has not yet been consumed.
     *
     * read_request_open:
     *   A read address was accepted, but its read response has not
     *   yet been consumed.
     */
    logic aw_seen                    = 1'b0;
    logic w_seen                     = 1'b0;
    logic write_request_open         = 1'b0;
    logic write_wait_cycle           = 1'b0;
    logic read_request_open          = 1'b0;

    wire aw_fire = s_axi_awvalid && s_axi_awready;
    wire w_fire  = s_axi_wvalid  && s_axi_wready;
    wire b_fire  = s_axi_bvalid  && s_axi_bready;
    wire ar_fire = s_axi_arvalid && s_axi_arready;
    wire r_fire  = s_axi_rvalid  && s_axi_rready;

    /*
     * A complete write request exists when both its address and data
     * have been accepted. They may arrive in the same cycle or in
     * different cycles.
     */
    wire write_pair_fire =
        !write_request_open &&
        (aw_seen || aw_fire) &&
        (w_seen  || w_fire);

    always_ff @(posedge aclk) begin
        f_past_valid <= 1'b1;

        if (!aresetn) begin
            aw_seen            <= 1'b0;
            w_seen             <= 1'b0;
            write_request_open <= 1'b0;
            write_wait_cycle   <= 1'b0;
            read_request_open  <= 1'b0;
        end else begin

            /*
             * =====================================================
             * MASTER ASSUMPTIONS
             * =====================================================
             *
             * These describe legal behavior of the external AXI
             * master. The slave does not control these signals.
             */

                        if (f_past_valid && $past(aresetn)) begin

                /*
                 * MASTER ASSUMPTIONS
                 *
                 * During the normal proof these are assumptions.
                 * During the assumption audit they are disabled.
                 */
`ifndef NO_MASTER_ASSUMPTIONS

                // AWVALID and AWADDR must remain stable while stalled.
                if ($past(s_axi_awvalid && !s_axi_awready)) begin
                    assume(s_axi_awvalid);
                    assume(s_axi_awaddr == $past(s_axi_awaddr));
                end

                // WVALID, WDATA and WSTRB must remain stable while stalled.
                if ($past(s_axi_wvalid && !s_axi_wready)) begin
                    assume(s_axi_wvalid);
                    assume(s_axi_wdata == $past(s_axi_wdata));
                    assume(s_axi_wstrb == $past(s_axi_wstrb));
                end

                // ARVALID and ARADDR must remain stable while stalled.
                if ($past(s_axi_arvalid && !s_axi_arready)) begin
                    assume(s_axi_arvalid);
                    assume(s_axi_araddr == $past(s_axi_araddr));
                end

`endif

                /*
                 * SLAVE STALL-STABILITY ASSERTIONS
                 *
                 * These must remain active during both the normal
                 * proof and the assumption audit.
                 */

                // Write response must remain stable during backpressure.
                if ($past(s_axi_bvalid && !s_axi_bready)) begin
                    assert(s_axi_bvalid);
                    assert(s_axi_bresp == $past(s_axi_bresp));
                end

                // Read response must remain stable during backpressure.
                if ($past(s_axi_rvalid && !s_axi_rready)) begin
                    assert(s_axi_rvalid);
                    assert(s_axi_rdata == $past(s_axi_rdata));
                    assert(s_axi_rresp == $past(s_axi_rresp));
                end
            end

            /*
             * =====================================================
             * WRITE TRANSACTION TRACKING
             * =====================================================
             */

            // Both partial-write flags must never be set together.
            // Once both pieces exist, they become one complete request.
            assert(!(aw_seen && w_seen));

            // No partial request may coexist with a completed request.
            assert(!(write_request_open && (aw_seen || w_seen)));

            // The same address component cannot be accepted twice.
            if (aw_seen)
                assert(!aw_fire);

            // The same data component cannot be accepted twice.
            if (w_seen)
                assert(!w_fire);

            // No new write components while a response is outstanding.
            if (write_request_open) begin
                assert(!aw_fire);
                assert(!w_fire);
            end

            /*
             * Capture independently arriving write components.
             *
             * b_fire and write_pair_fire cannot legally occur in the
             * same cycle because the slave blocks AW and W while
             * BVALID is active.
             */
            if (b_fire) begin
                // A response cannot be consumed without a request.
                assert(write_request_open);

                write_request_open <= 1'b0;
                write_wait_cycle   <= 1'b0;
            end else if (write_pair_fire) begin
                // A completed write request must not overwrite another.
                assert(!write_request_open);

                aw_seen            <= 1'b0;
                w_seen             <= 1'b0;
                write_request_open <= 1'b1;
                write_wait_cycle   <= 1'b0;
            end else begin
                if (aw_fire) begin
                    assert(!aw_seen);
                    assert(!write_request_open);
                    aw_seen <= 1'b1;
                end

                if (w_fire) begin
                    assert(!w_seen);
                    assert(!write_request_open);
                    w_seen <= 1'b1;
                end
            end

            // BVALID cannot exist without a complete accepted write.
            if (s_axi_bvalid)
                assert(write_request_open);

            // BRESP must be one of the documented response values.
            if (s_axi_bvalid) begin
                assert(
                    (s_axi_bresp == AXI_OKAY) ||
                    (s_axi_bresp == AXI_SLVERR)
                );
            end

            /*
             * Once a complete write request has been assembled, the
             * current RTL is allowed one waiting cycle before BVALID
             * must become visible.
             */
            if (write_request_open) begin
                if (s_axi_bvalid) begin
                    write_wait_cycle <= 1'b0;
                end else begin
                    assert(!write_wait_cycle);
                    write_wait_cycle <= 1'b1;
                end
            end

            /*
             * =====================================================
             * READ TRANSACTION TRACKING
             * =====================================================
             */

            // No new read request while one response is outstanding.
            if (read_request_open)
                assert(!ar_fire);

            /*
             * A consumed response clears the request.
             * Otherwise, a read-address handshake creates a request.
             */
            if (r_fire) begin
                // A response cannot be consumed without a request.
                assert(read_request_open);
                read_request_open <= 1'b0;
            end else if (ar_fire) begin
                // Only one read may be outstanding.
                assert(!read_request_open);
                read_request_open <= 1'b1;
            end

            // RVALID cannot exist without an accepted read request.
            if (s_axi_rvalid)
                assert(read_request_open);

            // Every accepted read request must produce RVALID.
            if (read_request_open)
                assert(s_axi_rvalid);

            // RRESP must be one of the documented response values.
            if (s_axi_rvalid) begin
                assert(
                    (s_axi_rresp == AXI_OKAY) ||
                    (s_axi_rresp == AXI_SLVERR)
                );
            end
        end

        /*
         * =========================================================
         * COVER PROPERTIES — VACUITY AND REACHABILITY CHECKS
         * =========================================================
         */

        if (aresetn) begin

            // All five AXI channel handshakes are reachable.
            cover(aw_fire);
            cover(w_fire);
            cover(b_fire);
            cover(ar_fire);
            cover(r_fire);

            // Backpressure is reachable.
            cover(s_axi_awvalid && !s_axi_awready);
            cover(s_axi_wvalid  && !s_axi_wready);
            cover(s_axi_bvalid  && !s_axi_bready);
            cover(s_axi_arvalid && !s_axi_arready);
            cover(s_axi_rvalid  && !s_axi_rready);

            // All legal write ordering combinations are reachable.
            cover(aw_fire && w_fire);  // Address and data together
            cover(aw_seen && w_fire);  // Address before data
            cover(w_seen && aw_fire);  // Data before address

            // Partial-byte writes are reachable.
            cover(
                w_fire &&
                (s_axi_wstrb != 4'b0000) &&
                (s_axi_wstrb != 4'b1111)
            );

            // Invalid-address responses are reachable.
            cover(b_fire && (s_axi_bresp == AXI_SLVERR));
            cover(r_fire && (s_axi_rresp == AXI_SLVERR));
        end
    end

endmodule