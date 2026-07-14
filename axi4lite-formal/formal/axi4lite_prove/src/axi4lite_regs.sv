/* module axi4lite_regs #(
    parameter int ADDR_WIDTH = 4,
    parameter int DATA_WIDTH = 32
) (
    input  logic                      aclk,
    input  logic                      aresetn,

    // Write address channel
    input  logic [ADDR_WIDTH-1:0]     s_axi_awaddr,
    input  logic                      s_axi_awvalid,
    output logic                      s_axi_awready,

    // Write data channel
    input  logic [DATA_WIDTH-1:0]     s_axi_wdata,
    input  logic [(DATA_WIDTH/8)-1:0] s_axi_wstrb,
    input  logic                      s_axi_wvalid,
    output logic                      s_axi_wready,

    // Write response channel
    output logic [1:0]                s_axi_bresp,
    output logic                      s_axi_bvalid,
    input  logic                      s_axi_bready,

    // Read address channel
    input  logic [ADDR_WIDTH-1:0]     s_axi_araddr,
    input  logic                      s_axi_arvalid,
    output logic                      s_axi_arready,

    // Read data channel
    output logic [DATA_WIDTH-1:0]     s_axi_rdata,
    output logic [1:0]                s_axi_rresp,
    output logic                      s_axi_rvalid,
    input  logic                      s_axi_rready
);

    // AXI response codes
    localparam logic [1:0] AXI_OKAY   = 2'b00;
    localparam logic [1:0] AXI_SLVERR = 2'b10;

    // Four 32-bit registers
    logic [DATA_WIDTH-1:0] control_reg;
    logic [DATA_WIDTH-1:0] status_reg;
    logic [DATA_WIDTH-1:0] data0_reg;
    logic [DATA_WIDTH-1:0] data1_reg;

    // Temporary storage for independently arriving write information
    logic                      aw_pending;
    logic [ADDR_WIDTH-1:0]     awaddr_hold;

    logic                      w_pending;
    logic [DATA_WIDTH-1:0]     wdata_hold;
    logic [(DATA_WIDTH/8)-1:0] wstrb_hold;

    // Initial reset-only shell
    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            control_reg <= '0;
            status_reg  <= '0;
            data0_reg   <= '0;
            data1_reg   <= '0;

            aw_pending  <= 1'b0;
            awaddr_hold <= '0;

            w_pending   <= 1'b0;
            wdata_hold  <= '0;
            wstrb_hold  <= '0;
        end
    end

    // Temporary outputs.
    // We will replace these while implementing each AXI channel.
    assign s_axi_awready = 1'b0;
    assign s_axi_wready  = 1'b0;

    assign s_axi_bvalid  = 1'b0;
    assign s_axi_bresp   = AXI_OKAY;

    assign s_axi_arready = 1'b0;

    assign s_axi_rvalid  = 1'b0;
    assign s_axi_rdata   = '0;
    assign s_axi_rresp   = AXI_OKAY;

endmodule */



module axi4lite_regs #(
    parameter int ADDR_WIDTH = 4,
    parameter int DATA_WIDTH = 32
) (
    input  logic                      aclk,
    input  logic                      aresetn,

    // Write address channel
    input  logic [ADDR_WIDTH-1:0]     s_axi_awaddr,
    input  logic                      s_axi_awvalid,
    output logic                      s_axi_awready,

    // Write data channel
    input  logic [DATA_WIDTH-1:0]     s_axi_wdata,
    input  logic [(DATA_WIDTH/8)-1:0] s_axi_wstrb,
    input  logic                      s_axi_wvalid,
    output logic                      s_axi_wready,

    // Write response channel
    output logic [1:0]                s_axi_bresp,
    output logic                      s_axi_bvalid,
    input  logic                      s_axi_bready,

    // Read address channel
    input  logic [ADDR_WIDTH-1:0]     s_axi_araddr,
    input  logic                      s_axi_arvalid,
    output logic                      s_axi_arready,

    // Read data channel
    output logic [DATA_WIDTH-1:0]     s_axi_rdata,
    output logic [1:0]                s_axi_rresp,
    output logic                      s_axi_rvalid,
    input  logic                      s_axi_rready
);

    localparam logic [1:0] AXI_OKAY   = 2'b00;
    localparam logic [1:0] AXI_SLVERR = 2'b10;

    // Four 32-bit registers
    logic [DATA_WIDTH-1:0] control_reg;
    logic [DATA_WIDTH-1:0] status_reg;
    logic [DATA_WIDTH-1:0] data0_reg;
    logic [DATA_WIDTH-1:0] data1_reg;

    // Stored write address
    logic                  aw_pending;
    logic [ADDR_WIDTH-1:0] awaddr_hold;

    // Stored write data
    logic                      w_pending;
    logic [DATA_WIDTH-1:0]     wdata_hold;
    logic [(DATA_WIDTH/8)-1:0] wstrb_hold;

    // READY is high only when that part has not already been captured.
    // No new write is accepted while a response is waiting.
    assign s_axi_awready = aresetn && !aw_pending && !s_axi_bvalid;
    assign s_axi_wready  = aresetn && !w_pending  && !s_axi_bvalid;

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            control_reg <= '0;
            status_reg  <= '0;
            data0_reg   <= '0;
            data1_reg   <= '0;

            aw_pending  <= 1'b0;
            awaddr_hold <= '0;

            w_pending   <= 1'b0;
            wdata_hold  <= '0;
            wstrb_hold  <= '0;

            s_axi_bvalid <= 1'b0;
            s_axi_bresp  <= AXI_OKAY;
        end else begin

            // Capture write address when VALID and READY are both high.
            if (s_axi_awvalid && s_axi_awready) begin
                awaddr_hold <= s_axi_awaddr;
                aw_pending  <= 1'b1;
            end

            // Capture write data independently.
            if (s_axi_wvalid && s_axi_wready) begin
                wdata_hold <= s_axi_wdata;
                wstrb_hold <= s_axi_wstrb;
                w_pending  <= 1'b1;
            end

            // Complete the write after both address and data are stored.
            if (aw_pending && w_pending && !s_axi_bvalid) begin
                case (awaddr_hold)
                    4'h0: begin
                        for (int byte_index = 0;
                             byte_index < DATA_WIDTH/8;
                             byte_index++) begin
                            if (wstrb_hold[byte_index]) begin
                                control_reg[byte_index*8 +: 8]
                                    <= wdata_hold[byte_index*8 +: 8];
                            end
                        end
                        s_axi_bresp <= AXI_OKAY;
                    end

                    4'h4: begin
                        for (int byte_index = 0;
                             byte_index < DATA_WIDTH/8;
                             byte_index++) begin
                            if (wstrb_hold[byte_index]) begin
                                status_reg[byte_index*8 +: 8]
                                    <= wdata_hold[byte_index*8 +: 8];
                            end
                        end
                        s_axi_bresp <= AXI_OKAY;
                    end

                    4'h8: begin
                        for (int byte_index = 0;
                             byte_index < DATA_WIDTH/8;
                             byte_index++) begin
                            if (wstrb_hold[byte_index]) begin
                                data0_reg[byte_index*8 +: 8]
                                    <= wdata_hold[byte_index*8 +: 8];
                            end
                        end
                        s_axi_bresp <= AXI_OKAY;
                    end

                    4'hC: begin
                        for (int byte_index = 0;
                             byte_index < DATA_WIDTH/8;
                             byte_index++) begin
                            if (wstrb_hold[byte_index]) begin
                                data1_reg[byte_index*8 +: 8]
                                    <= wdata_hold[byte_index*8 +: 8];
                            end
                        end
                        s_axi_bresp <= AXI_OKAY;
                    end

                    default: begin
                        // Invalid address: do not modify any register.
                        s_axi_bresp <= AXI_SLVERR;
                    end
                endcase

                // The stored address and data have now been consumed.
                aw_pending   <= 1'b0;
                w_pending    <= 1'b0;
                s_axi_bvalid <= 1'b1;
            end

            // Keep BVALID high until the master accepts the response.
            if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
            end
        end
    end

    // Read path will be implemented next.
   /*  assign s_axi_arready = 1'b0;
    assign s_axi_rvalid  = 1'b0;
    assign s_axi_rdata   = '0;
    assign s_axi_rresp   = AXI_OKAY; */
    // Accept one read request only when no response is waiting.
assign s_axi_arready = aresetn && !s_axi_rvalid;

always_ff @(posedge aclk) begin
    if (!aresetn) begin
        s_axi_rvalid <= 1'b0;
        s_axi_rdata  <= '0;
        s_axi_rresp  <= AXI_OKAY;
    end else begin

        // Read-address handshake
        if (s_axi_arvalid && s_axi_arready) begin
            case (s_axi_araddr)
                4'h0: begin
                    s_axi_rdata <= control_reg;
                    s_axi_rresp <= AXI_OKAY;
                end

                4'h4: begin
                    s_axi_rdata <= status_reg;
                    s_axi_rresp <= AXI_OKAY;
                end

                4'h8: begin
                    s_axi_rdata <= data0_reg;
                    s_axi_rresp <= AXI_OKAY;
                end

                4'hC: begin
                    s_axi_rdata <= data1_reg;
                    s_axi_rresp <= AXI_OKAY;
                end

                default: begin
                    s_axi_rdata <= '0;
                    s_axi_rresp <= AXI_SLVERR;
                end
            endcase

            s_axi_rvalid <= 1'b1;
        end

        // Read-response handshake
        else if (s_axi_rvalid && s_axi_rready) begin
            s_axi_rvalid <= 1'b0;
        end
    end
end

`ifdef FORMAL

    axi4lite_functional_properties functional_properties (
        .aclk             (aclk),
        .aresetn          (aresetn),

        .s_axi_awaddr     (s_axi_awaddr),
        .s_axi_awvalid    (s_axi_awvalid),
        .s_axi_awready    (s_axi_awready),

        .s_axi_wdata      (s_axi_wdata),
        .s_axi_wstrb      (s_axi_wstrb),
        .s_axi_wvalid     (s_axi_wvalid),
        .s_axi_wready     (s_axi_wready),

        .s_axi_bresp      (s_axi_bresp),
        .s_axi_bvalid     (s_axi_bvalid),
        .s_axi_bready     (s_axi_bready),

        .s_axi_araddr     (s_axi_araddr),
        .s_axi_arvalid    (s_axi_arvalid),
        .s_axi_arready    (s_axi_arready),

        .s_axi_rdata      (s_axi_rdata),
        .s_axi_rresp      (s_axi_rresp),
        .s_axi_rvalid     (s_axi_rvalid),
        .s_axi_rready     (s_axi_rready),

        .dut_control_reg  (control_reg),
        .dut_status_reg   (status_reg),
        .dut_data0_reg    (data0_reg),
        .dut_data1_reg    (data1_reg)
    );

`endif

endmodule
/*
AW handshake → address stored
W handshake  → data and strobe stored
Both stored  → register updated and BVALID raised
B handshake  → BVALID cleared
*/ 