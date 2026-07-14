module axi4lite_functional_properties (
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
    input logic        s_axi_rready,

    // Internal DUT register values
    input logic [31:0] dut_control_reg,
    input logic [31:0] dut_status_reg,
    input logic [31:0] dut_data0_reg,
    input logic [31:0] dut_data1_reg
);

    localparam logic [1:0] AXI_OKAY   = 2'b00;
    localparam logic [1:0] AXI_SLVERR = 2'b10;

    logic f_past_valid = 1'b0;

    wire aw_fire = s_axi_awvalid && s_axi_awready;
    wire w_fire  = s_axi_wvalid  && s_axi_wready;
    wire b_fire  = s_axi_bvalid  && s_axi_bready;
    wire ar_fire = s_axi_arvalid && s_axi_arready;
    wire r_fire  = s_axi_rvalid  && s_axi_rready;

    // Reference-model write storage
    logic        model_aw_pending = 1'b0;
    logic [3:0]  model_awaddr     = 4'h0;

    logic        model_w_pending = 1'b0;
    logic [31:0] model_wdata     = 32'h0;
    logic [3:0]  model_wstrb     = 4'h0;

    // Reference-model registers
    logic [31:0] model_control = 32'h0;
    logic [31:0] model_status  = 32'h0;
    logic [31:0] model_data0   = 32'h0;
    logic [31:0] model_data1   = 32'h0;

    // Expected read response
    logic        expected_read_valid = 1'b0;
    logic [31:0] expected_read_data  = 32'h0;
    logic [1:0]  expected_read_resp  = AXI_OKAY;

    function automatic logic address_is_valid(
        input logic [3:0] address
    );
        begin
            case (address)
                4'h0,
                4'h4,
                4'h8,
                4'hC: address_is_valid = 1'b1;

                default: address_is_valid = 1'b0;
            endcase
        end
    endfunction

    function automatic logic [31:0] apply_wstrb(
        input logic [31:0] old_value,
        input logic [31:0] new_value,
        input logic [3:0]  strobe
    );
        logic [31:0] result;
        integer byte_index;

        begin
            result = old_value;

            for (byte_index = 0;
                 byte_index < 4;
                 byte_index = byte_index + 1) begin

                if (strobe[byte_index]) begin
                    result[byte_index*8 +: 8] =
                        new_value[byte_index*8 +: 8];
                end
            end

            apply_wstrb = result;
        end
    endfunction

    always_ff @(posedge aclk) begin
        f_past_valid <= 1'b1;

        if (!aresetn) begin
            model_aw_pending <= 1'b0;
            model_awaddr     <= 4'h0;

            model_w_pending <= 1'b0;
            model_wdata     <= 32'h0;
            model_wstrb     <= 4'h0;

            model_control <= 32'h0;
            model_status  <= 32'h0;
            model_data0   <= 32'h0;
            model_data1   <= 32'h0;

            expected_read_valid <= 1'b0;
            expected_read_data  <= 32'h0;
            expected_read_resp  <= AXI_OKAY;
        end else begin

            // Capture independently arriving write address.
            if (aw_fire) begin
                model_awaddr     <= s_axi_awaddr;
                model_aw_pending <= 1'b1;
            end

            // Capture independently arriving write data.
            if (w_fire) begin
                model_wdata     <= s_axi_wdata;
                model_wstrb     <= s_axi_wstrb;
                model_w_pending <= 1'b1;
            end

            /*
             * Mirror the RTL write-commit condition.
             * This occurs one cycle after both address and data
             * have been stored.
             */
            if (model_aw_pending &&
                model_w_pending &&
                !s_axi_bvalid) begin

                case (model_awaddr)
                    4'h0: begin
                        model_control <= apply_wstrb(
                            model_control,
                            model_wdata,
                            model_wstrb
                        );
                    end

                    4'h4: begin
                        model_status <= apply_wstrb(
                            model_status,
                            model_wdata,
                            model_wstrb
                        );
                    end

                    4'h8: begin
                        model_data0 <= apply_wstrb(
                            model_data0,
                            model_wdata,
                            model_wstrb
                        );
                    end

                    4'hC: begin
                        model_data1 <= apply_wstrb(
                            model_data1,
                            model_wdata,
                            model_wstrb
                        );
                    end

                    default: begin
                        // Invalid writes must change no register.
                    end
                endcase

                model_aw_pending <= 1'b0;
                model_w_pending  <= 1'b0;
            end

            /*
             * Capture the expected read result at the exact read
             * address handshake. This also defines simultaneous
             * read/write behavior as read-before-write.
             */
            if (ar_fire) begin
                case (s_axi_araddr)
                    4'h0: begin
                        expected_read_data <= model_control;
                        expected_read_resp <= AXI_OKAY;
                    end

                    4'h4: begin
                        expected_read_data <= model_status;
                        expected_read_resp <= AXI_OKAY;
                    end

                    4'h8: begin
                        expected_read_data <= model_data0;
                        expected_read_resp <= AXI_OKAY;
                    end

                    4'hC: begin
                        expected_read_data <= model_data1;
                        expected_read_resp <= AXI_OKAY;
                    end

                    default: begin
                        expected_read_data <= 32'h0000_0000;
                        expected_read_resp <= AXI_SLVERR;
                    end
                endcase

                expected_read_valid <= 1'b1;
            end else if (r_fire) begin
                expected_read_valid <= 1'b0;
            end

            // DUT registers must always equal the reference model.
            assert(dut_control_reg == model_control);
            assert(dut_status_reg  == model_status);
            assert(dut_data0_reg   == model_data0);
            assert(dut_data1_reg   == model_data1);

            // Check valid and invalid write responses.
            if (s_axi_bvalid) begin
                if (address_is_valid(model_awaddr))
                    assert(s_axi_bresp == AXI_OKAY);
                else
                    assert(s_axi_bresp == AXI_SLVERR);
            end

            // Check read data and response.
            if (s_axi_rvalid) begin
                assert(expected_read_valid);
                assert(s_axi_rdata == expected_read_data);
                assert(s_axi_rresp == expected_read_resp);
            end

            if (expected_read_valid)
                assert(s_axi_rvalid);
        end

        // Explicit reset checks
        if (f_past_valid && !$past(aresetn)) begin
            assert(dut_control_reg == 32'h0000_0000);
            assert(dut_status_reg  == 32'h0000_0000);
            assert(dut_data0_reg   == 32'h0000_0000);
            assert(dut_data1_reg   == 32'h0000_0000);

            assert(!s_axi_bvalid);
            assert(!s_axi_rvalid);
        end
    end

endmodule