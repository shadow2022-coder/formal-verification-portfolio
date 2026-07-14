`ifndef VERILATOR
module testbench;
  reg [4095:0] vcdfile;
  reg clock;
`else
module testbench(input clock, output reg genclock);
  initial genclock = 1;
`endif
  reg genclock = 1;
  reg [31:0] cycle = 0;
  axi4lite_formal UUT (

  );
`ifndef VERILATOR
  initial begin
    if ($value$plusargs("vcd=%s", vcdfile)) begin
      $dumpfile(vcdfile);
      $dumpvars(0, testbench);
    end
    #5 clock = 0;
    while (genclock) begin
      #5 clock = 0;
      #5 clock = 1;
    end
  end
`endif
  initial begin
`ifndef VERILATOR
    #1;
`endif
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$$assume$axi4lite_formal .\sv:95$25_EN#sampled$691  = 1'b0;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$$assume$axi4lite_formal .\sv:97$27_EN#sampled$705  = 1'b0;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$$logic_and$axi4lite_formal .\sv:106$35_Y#sampled$725  = 1'b1;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$axi4lite_formal .\sv:95$26_Y#sampled$697  = 1'b1;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_formal .\sv:100$9$0#sampled$647  = 1'b0;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$/aresetn#sampled$649  = 1'b0;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$/aresetn#sampled$711  = 1'b1;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$/f_past_valid#sampled$637  = 1'b0;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$1'1#sampled$639  = 1'b0;
    // UUT.$auto$clk2fflogic.\cc:87:sample_control_edge$/aclk#sampled$699  = 1'b1;
    UUT.aclk = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/aw_pending[0:0]#sampled$1267  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/awaddr_hold[3:0]#sampled$1277  = 4'b0000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/control_reg[31:0]#sampled$1227  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/data0_reg[31:0]#sampled$1247  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/data1_reg[31:0]#sampled$1257  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/s_axi_bresp[1:0]#sampled$1207  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/s_axi_bvalid[0:0]#sampled$1217  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/s_axi_rdata[31:0]#sampled$1177  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/s_axi_rresp[1:0]#sampled$1187  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/s_axi_rvalid[0:0]#sampled$1197  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/status_reg[31:0]#sampled$1237  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/w_pending[0:0]#sampled$1287  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/wdata_hold[31:0]#sampled$1297  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/wstrb_hold[3:0]#sampled$1307  = 4'b0000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/aw_pending#sampled$1265  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/awaddr_hold#sampled$1275  = 4'b0000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/control_reg#sampled$1225  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/data0_reg#sampled$1245  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/data1_reg#sampled$1255  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_bresp#sampled$1205  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_bvalid#sampled$1215  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_rdata#sampled$1175  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_rresp#sampled$1185  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_rvalid#sampled$1195  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/status_reg#sampled$1235  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/w_pending#sampled$1285  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/wdata_hold#sampled$1295  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/wstrb_hold#sampled$1305  = 4'b0000;
    // UUT.dut.$auto$clk2fflogic.\cc:87:sample_control_edge$/aclk#sampled$1309  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:37$39$0[0:0]$53#sampled$1117  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:37$39$0[0:0]$53#sampled$749  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:43$41$0[0:0]$55#sampled$1131  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:43$41$0[0:0]$55#sampled$769  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:50$44$0[0:0]$58#sampled$1159  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:50$44$0[0:0]$58#sampled$799  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:57$46$0[0:0]$60#sampled$1145  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:57$46$0[0:0]$60#sampled$819  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:63$48$0[0:0]$62#sampled$1173  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:63$48$0[0:0]$62#sampled$839  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assume$axi4lite_properties .\sv:38$66_EN#sampled$957  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assume$axi4lite_properties .\sv:44$69_EN#sampled$999  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assume$axi4lite_properties .\sv:51$74_EN#sampled$1013  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$cover$axi4lite_properties .\sv:72$85_EN#sampled$1041  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_properties .\sv:39$68_Y#sampled$963  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_properties .\sv:45$71_Y#sampled$991  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_properties .\sv:46$73_Y#sampled$1005  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_properties .\sv:52$76_Y#sampled$1033  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_and$axi4lite_properties .\sv:72$86_Y#sampled$1047  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_and$axi4lite_properties .\sv:73$88_Y#sampled$1061  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_and$axi4lite_properties .\sv:74$90_Y#sampled$1075  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_and$axi4lite_properties .\sv:75$92_Y#sampled$1089  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_and$axi4lite_properties .\sv:76$94_Y#sampled$1103  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:33$38$0#sampled$737  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:37$39$0#sampled$747  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:39$40$0#sampled$757  = 4'b0000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:43$41$0#sampled$767  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:45$42$0#sampled$777  = 32'b00000000000000000000000000000000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:46$43$0#sampled$787  = 4'b0000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:50$44$0#sampled$797  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:52$45$0#sampled$807  = 4'b0000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:57$46$0#sampled$817  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:59$47$0#sampled$827  = 2'b00;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:63$48$0#sampled$837  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:65$49$0#sampled$847  = 32'b00000000000000000000000000000000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:66$50$0#sampled$857  = 2'b00;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/aresetn#sampled$739  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/f_past_valid#sampled$727  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_araddr#sampled$809  = 4'b0000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_arvalid#sampled$1019  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_awaddr#sampled$759  = 4'b0000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_awvalid#sampled$949  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_bresp#sampled$829  = 2'b00;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_rdata#sampled$849  = 32'b00000000000000000000000000000000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_rresp#sampled$859  = 2'b00;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_wdata#sampled$779  = 32'b00000000000000000000000000000000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_wstrb#sampled$789  = 4'b0000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_wvalid#sampled$977  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$1'1#sampled$729  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:87:sample_control_edge$/aclk#sampled$1007  = 1'b1;

    // state 0
    UUT.aresetn = 1'b0;
    UUT.s_axi_araddr = 4'b0000;
    UUT.s_axi_arvalid = 1'b0;
    UUT.s_axi_awaddr = 4'b0000;
    UUT.s_axi_awvalid = 1'b0;
    UUT.s_axi_bready = 1'b0;
    UUT.s_axi_rready = 1'b0;
    UUT.s_axi_wdata = 32'b00000000000000000000000000000000;
    UUT.s_axi_wstrb = 4'b0000;
    UUT.s_axi_wvalid = 1'b0;
  end
  always @(posedge clock) begin
    // state 1
    if (cycle == 0) begin
      UUT.aresetn <= 1'b0;
      UUT.s_axi_araddr <= 4'b0000;
      UUT.s_axi_arvalid <= 1'b0;
      UUT.s_axi_awaddr <= 4'b0000;
      UUT.s_axi_awvalid <= 1'b0;
      UUT.s_axi_bready <= 1'b0;
      UUT.s_axi_rready <= 1'b0;
      UUT.s_axi_wdata <= 32'b00000000000000000000000000000000;
      UUT.s_axi_wstrb <= 4'b0000;
      UUT.s_axi_wvalid <= 1'b0;
    end

    // state 2
    if (cycle == 1) begin
      UUT.aresetn <= 1'b1;
      UUT.s_axi_araddr <= 4'b0000;
      UUT.s_axi_arvalid <= 1'b0;
      UUT.s_axi_awaddr <= 4'b0000;
      UUT.s_axi_awvalid <= 1'b1;
      UUT.s_axi_bready <= 1'b0;
      UUT.s_axi_rready <= 1'b0;
      UUT.s_axi_wdata <= 32'b00000000000000000000000000000000;
      UUT.s_axi_wstrb <= 4'b0000;
      UUT.s_axi_wvalid <= 1'b1;
    end

    // state 3
    if (cycle == 2) begin
      UUT.aresetn <= 1'b0;
      UUT.s_axi_araddr <= 4'b0000;
      UUT.s_axi_arvalid <= 1'b0;
      UUT.s_axi_awaddr <= 4'b0000;
      UUT.s_axi_awvalid <= 1'b0;
      UUT.s_axi_bready <= 1'b0;
      UUT.s_axi_rready <= 1'b0;
      UUT.s_axi_wdata <= 32'b00000000000000000000000000000000;
      UUT.s_axi_wstrb <= 4'b0000;
      UUT.s_axi_wvalid <= 1'b0;
    end

    // state 4
    if (cycle == 3) begin
      UUT.aresetn <= 1'b1;
      UUT.s_axi_araddr <= 4'b1111;
      UUT.s_axi_arvalid <= 1'b1;
      UUT.s_axi_awaddr <= 4'b1111;
      UUT.s_axi_awvalid <= 1'b1;
      UUT.s_axi_bready <= 1'b0;
      UUT.s_axi_rready <= 1'b1;
      UUT.s_axi_wdata <= 32'b11111111111111111111111111111111;
      UUT.s_axi_wstrb <= 4'b1111;
      UUT.s_axi_wvalid <= 1'b1;
    end

    // state 5
    if (cycle == 4) begin
      UUT.aresetn <= 1'b0;
      UUT.s_axi_araddr <= 4'b0000;
      UUT.s_axi_arvalid <= 1'b0;
      UUT.s_axi_awaddr <= 4'b0000;
      UUT.s_axi_awvalid <= 1'b0;
      UUT.s_axi_bready <= 1'b0;
      UUT.s_axi_rready <= 1'b0;
      UUT.s_axi_wdata <= 32'b00000000000000000000000000000000;
      UUT.s_axi_wstrb <= 4'b0000;
      UUT.s_axi_wvalid <= 1'b0;
    end

    // state 6
    if (cycle == 5) begin
      UUT.aresetn <= 1'b1;
      UUT.s_axi_araddr <= 4'b1111;
      UUT.s_axi_arvalid <= 1'b1;
      UUT.s_axi_awaddr <= 4'b1111;
      UUT.s_axi_awvalid <= 1'b1;
      UUT.s_axi_bready <= 1'b1;
      UUT.s_axi_rready <= 1'b0;
      UUT.s_axi_wdata <= 32'b11111111111111111111111111111111;
      UUT.s_axi_wstrb <= 4'b1111;
      UUT.s_axi_wvalid <= 1'b1;
    end

    // state 7
    if (cycle == 6) begin
      UUT.aresetn <= 1'b0;
      UUT.s_axi_araddr <= 4'b0000;
      UUT.s_axi_arvalid <= 1'b0;
      UUT.s_axi_awaddr <= 4'b0000;
      UUT.s_axi_awvalid <= 1'b0;
      UUT.s_axi_bready <= 1'b0;
      UUT.s_axi_rready <= 1'b0;
      UUT.s_axi_wdata <= 32'b00000000000000000000000000000000;
      UUT.s_axi_wstrb <= 4'b0000;
      UUT.s_axi_wvalid <= 1'b0;
    end

    genclock <= cycle < 7;
    cycle <= cycle + 1;
  end
endmodule
