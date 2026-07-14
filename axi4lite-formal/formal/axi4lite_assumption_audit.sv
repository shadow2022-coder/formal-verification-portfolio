module axi4lite_assumption_audit (
    input logic        aclk,
    input logic        aresetn,

    input logic [3:0]  s_axi_awaddr,
    input logic        s_axi_awvalid,
    input logic        s_axi_awready,

    input logic [31:0] s_axi_wdata,
    input logic [3:0]  s_axi_wstrb,
    input logic        s_axi_wvalid,
    input logic        s_axi_wready,

    input logic [3:0]  s_axi_araddr,
    input logic        s_axi_arvalid,
    input logic        s_axi_arready
);

    logic f_past_valid = 1'b0;

    always_ff @(posedge aclk) begin
        f_past_valid <= 1'b1;

        if (f_past_valid && aresetn && $past(aresetn)) begin

            if ($past(s_axi_awvalid && !s_axi_awready)) begin
                assert(s_axi_awvalid);
                assert(s_axi_awaddr == $past(s_axi_awaddr));
            end

            if ($past(s_axi_wvalid && !s_axi_wready)) begin
                assert(s_axi_wvalid);
                assert(s_axi_wdata == $past(s_axi_wdata));
                assert(s_axi_wstrb == $past(s_axi_wstrb));
            end

            if ($past(s_axi_arvalid && !s_axi_arready)) begin
                assert(s_axi_arvalid);
                assert(s_axi_araddr == $past(s_axi_araddr));
            end
        end
    end

endmodule