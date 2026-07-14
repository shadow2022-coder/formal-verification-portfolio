module axi4lite_properties (
    input logic        aclk,
    input logic        aresetn,

    input logic [3:0]  s_axi_awaddr,
    input logic        s_axi_awvalid,
    input logic        s_axi_awready,

    input logic [31:0] s_axi_wdata,
    input logic [3:0]  s_axi_wstrb,
    input logic        s_axi_wvalid,
    input logic        s_axi_wready,

    input logic [1:0]  s_axi_bresp,
    input logic        s_axi_bvalid,
    input logic        s_axi_bready,

    input logic [3:0]  s_axi_araddr,
    input logic        s_axi_arvalid,
    input logic        s_axi_arready,

    input logic [31:0] s_axi_rdata,
    input logic [1:0]  s_axi_rresp,
    input logic        s_axi_rvalid,
    input logic        s_axi_rready
);

    logic f_past_valid = 1'b0;

    always_ff @(posedge aclk) begin
        f_past_valid <= 1'b1;

        if (f_past_valid && $past(aresetn)) begin

            // MASTER ASSUMPTIONS
            // The master must hold AWVALID and AWADDR while stalled.
            if ($past(s_axi_awvalid && !s_axi_awready)) begin
                assume(s_axi_awvalid);
                assume(s_axi_awaddr == $past(s_axi_awaddr));
            end

            // The master must hold WVALID, WDATA and WSTRB while stalled.
            if ($past(s_axi_wvalid && !s_axi_wready)) begin
                assume(s_axi_wvalid);
                assume(s_axi_wdata == $past(s_axi_wdata));
                assume(s_axi_wstrb == $past(s_axi_wstrb));
            end

            // The master must hold ARVALID and ARADDR while stalled.
            if ($past(s_axi_arvalid && !s_axi_arready)) begin
                assume(s_axi_arvalid);
                assume(s_axi_araddr == $past(s_axi_araddr));
            end

            // SLAVE ASSERTIONS
            // BVALID and BRESP must remain stable during backpressure.
            if ($past(s_axi_bvalid && !s_axi_bready)) begin
                assert(s_axi_bvalid);
                assert(s_axi_bresp == $past(s_axi_bresp));
            end

            // RVALID, RDATA and RRESP must remain stable during backpressure.
            if ($past(s_axi_rvalid && !s_axi_rready)) begin
                assert(s_axi_rvalid);
                assert(s_axi_rdata == $past(s_axi_rdata));
                assert(s_axi_rresp == $past(s_axi_rresp));
            end
        end

        // Reachability checks
        if (aresetn) begin
            cover(s_axi_awvalid && s_axi_awready);
            cover(s_axi_wvalid  && s_axi_wready);
            cover(s_axi_bvalid  && s_axi_bready);
            cover(s_axi_arvalid && s_axi_arready);
            cover(s_axi_rvalid  && s_axi_rready);

            cover(s_axi_awvalid && !s_axi_awready);
            cover(s_axi_wvalid  && !s_axi_wready);
            cover(s_axi_bvalid  && !s_axi_bready);
            cover(s_axi_arvalid && !s_axi_arready);
            cover(s_axi_rvalid  && !s_axi_rready);
        end
    end

endmodule