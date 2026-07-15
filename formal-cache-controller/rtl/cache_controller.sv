module cache_controller #(
    parameter int unsigned ADDR_WIDTH = 8,
    parameter int unsigned DATA_WIDTH = 32,
    parameter int unsigned NUM_LINES  = 4
) (
    // Clock and active-low reset
    input  logic                          clk,
    input  logic                          rst_n,

    // CPU request interface
    input  logic                          cpu_req_valid,
    output logic                          cpu_req_ready,
    input  logic                          cpu_req_write,
    input  logic [ADDR_WIDTH-1:0]         cpu_req_addr,
    input  logic [DATA_WIDTH-1:0]         cpu_req_wdata,
    input  logic [(DATA_WIDTH/8)-1:0]     cpu_req_wstrb,

    // CPU response interface
    output logic                          cpu_rsp_valid,
    input  logic                          cpu_rsp_ready,
    output logic [DATA_WIDTH-1:0]         cpu_rsp_rdata,

    // Memory request interface
    output logic                          mem_req_valid,
    input  logic                          mem_req_ready,
    output logic                          mem_req_write,
    output logic [ADDR_WIDTH-1:0]         mem_req_addr,
    output logic [DATA_WIDTH-1:0]         mem_req_wdata,

    // Memory response interface
    input  logic                          mem_rsp_valid,
    output logic                          mem_rsp_ready,
    input  logic [DATA_WIDTH-1:0]         mem_rsp_rdata
);

    // -------------------------------------------------------------------------
    // Derived constants
    // -------------------------------------------------------------------------

    localparam int unsigned BYTE_LANES   = DATA_WIDTH / 8;
    localparam int unsigned OFFSET_WIDTH = $clog2(BYTE_LANES);
    localparam int unsigned INDEX_WIDTH  = $clog2(NUM_LINES);
    localparam int unsigned TAG_WIDTH    =
        ADDR_WIDTH - INDEX_WIDTH - OFFSET_WIDTH;

    // -------------------------------------------------------------------------
    // Cache controller states
    // -------------------------------------------------------------------------

    typedef enum logic [2:0] {
        IDLE,
        LOOKUP,
        WRITEBACK_REQ,
        WRITEBACK_WAIT,
        REFILL_REQ,
        REFILL_WAIT,
        RESPOND
    } cache_state_t;

    cache_state_t state;
    cache_state_t next_state;

    // -------------------------------------------------------------------------
    // Cache-line storage
    // -------------------------------------------------------------------------

    logic [NUM_LINES-1:0] valid_array;
    logic [NUM_LINES-1:0] dirty_array;

    logic [TAG_WIDTH-1:0]  tag_array  [0:NUM_LINES-1];
    logic [DATA_WIDTH-1:0] data_array [0:NUM_LINES-1];

    // -------------------------------------------------------------------------
    // Captured CPU request
    //
    // A request may remain active for several cycles during writeback/refill,
    // so the complete request must be stored after the CPU handshake.
    // -------------------------------------------------------------------------

    logic                          req_write_reg;
    logic [ADDR_WIDTH-1:0]         req_addr_reg;
    logic [DATA_WIDTH-1:0]         req_wdata_reg;
    logic [BYTE_LANES-1:0]         req_wstrb_reg;

    // -------------------------------------------------------------------------
    // Registered CPU response data
    //
    // This register will later allow the response payload to remain stable
    // while cpu_rsp_valid is asserted and cpu_rsp_ready is low.
    // -------------------------------------------------------------------------

    logic [DATA_WIDTH-1:0] rsp_rdata_reg;

    // -------------------------------------------------------------------------
    // Output and next-state defaults
    //
    // Functional state behavior will be added incrementally in later stages.
    // -------------------------------------------------------------------------

    always_comb begin
        next_state = state;

        cpu_req_ready = 1'b0;

        cpu_rsp_valid = 1'b0;
        cpu_rsp_rdata = rsp_rdata_reg;

        mem_req_valid = 1'b0;
        mem_req_write = 1'b0;
        mem_req_addr  = '0;
        mem_req_wdata = '0;

        mem_rsp_ready = 1'b0;
    end

endmodule
