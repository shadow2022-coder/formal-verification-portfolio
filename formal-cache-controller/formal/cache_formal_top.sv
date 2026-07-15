module cache_formal_top;

    localparam int unsigned ADDR_WIDTH = 8;
    localparam int unsigned DATA_WIDTH = 32;
    localparam int unsigned NUM_LINES  = 4;

    // Formal global clock
    (* gclk *) logic clk;

    // Reset
    (* anyseq *) logic rst_n;

    // CPU request interface
    (* anyseq *) logic                      cpu_req_valid;
    logic                                  cpu_req_ready;
    (* anyseq *) logic                      cpu_req_write;
    (* anyseq *) logic [ADDR_WIDTH-1:0]     cpu_req_addr;
    (* anyseq *) logic [DATA_WIDTH-1:0]     cpu_req_wdata;
    (* anyseq *) logic [(DATA_WIDTH/8)-1:0] cpu_req_wstrb;

    // CPU response interface
    logic                                  cpu_rsp_valid;
    (* anyseq *) logic                      cpu_rsp_ready;
    logic [DATA_WIDTH-1:0]                 cpu_rsp_rdata;

    // Memory request interface
    logic                                  mem_req_valid;
    (* anyseq *) logic                      mem_req_ready;
    logic                                  mem_req_write;
    logic [ADDR_WIDTH-1:0]                 mem_req_addr;
    logic [DATA_WIDTH-1:0]                 mem_req_wdata;

    // Memory response interface
    (* anyseq *) logic                      mem_rsp_valid;
    logic                                  mem_rsp_ready;
    (* anyseq *) logic [DATA_WIDTH-1:0]     mem_rsp_rdata;

    // -------------------------------------------------------------------------
    // Initial environment assumptions
    // -------------------------------------------------------------------------

    always @(posedge clk) begin

        // Force a reachable reset sequence:
        // cycle 0: reset asserted
        // later cycles: reset deasserted
        if ($initstate) begin
            assume (!rst_n);
        end else begin
            assume (rst_n);
        end

        // Supported CPU requests are aligned 32-bit word accesses.
        assume (cpu_req_addr[1:0] == 2'b00);
    end

    // -------------------------------------------------------------------------
    // Device under test
    //
    // cache_properties is instantiated internally by cache_controller when
    // FORMAL is defined.
    // -------------------------------------------------------------------------

    cache_controller #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .NUM_LINES  (NUM_LINES)
    ) dut (
        .clk            (clk),
        .rst_n          (rst_n),

        .cpu_req_valid  (cpu_req_valid),
        .cpu_req_ready  (cpu_req_ready),
        .cpu_req_write  (cpu_req_write),
        .cpu_req_addr   (cpu_req_addr),
        .cpu_req_wdata  (cpu_req_wdata),
        .cpu_req_wstrb  (cpu_req_wstrb),

        .cpu_rsp_valid  (cpu_rsp_valid),
        .cpu_rsp_ready  (cpu_rsp_ready),
        .cpu_rsp_rdata  (cpu_rsp_rdata),

        .mem_req_valid  (mem_req_valid),
        .mem_req_ready  (mem_req_ready),
        .mem_req_write  (mem_req_write),
        .mem_req_addr   (mem_req_addr),
        .mem_req_wdata  (mem_req_wdata),

        .mem_rsp_valid  (mem_rsp_valid),
        .mem_rsp_ready  (mem_rsp_ready),
        .mem_rsp_rdata  (mem_rsp_rdata)
    );

endmodule
