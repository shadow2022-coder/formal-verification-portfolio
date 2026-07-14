module axi4lite_formal;

    // Formal clock
    logic aclk = 1'b0;

    always @($global_clock) begin
        aclk <= !aclk;
    end

    // Reset and symbolic master-controlled inputs
    (* anyseq *) logic        aresetn;

    (* anyseq *) logic [3:0]  s_axi_awaddr;
    (* anyseq *) logic        s_axi_awvalid;
    logic                     s_axi_awready;

    (* anyseq *) logic [31:0] s_axi_wdata;
    (* anyseq *) logic [3:0]  s_axi_wstrb;
    (* anyseq *) logic        s_axi_wvalid;
    logic                     s_axi_wready;

    logic [1:0]               s_axi_bresp;
    logic                     s_axi_bvalid;
    (* anyseq *) logic        s_axi_bready;

    (* anyseq *) logic [3:0]  s_axi_araddr;
    (* anyseq *) logic        s_axi_arvalid;
    logic                     s_axi_arready;

    logic [31:0]              s_axi_rdata;
    logic [1:0]               s_axi_rresp;
    logic                     s_axi_rvalid;
    (* anyseq *) logic        s_axi_rready;

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

    logic f_past_valid = 1'b0;

    always_ff @(posedge aclk) begin
        f_past_valid <= 1'b1;

        // Begin in reset, then keep reset released.
        if (!f_past_valid)
            assume(!aresetn);
        else
            assume(aresetn);

        // Check that response state was cleared by reset.
        if (f_past_valid && !$past(aresetn)) begin
            assert(!s_axi_bvalid);
            assert(!s_axi_rvalid);
        end

        // Ensure reset release is reachable.
        cover(f_past_valid && aresetn);
    end

endmodule