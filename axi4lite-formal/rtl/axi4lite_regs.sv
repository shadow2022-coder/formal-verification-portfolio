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

endmodule