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
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$$assume$axi4lite_formal .\sv:95$26_EN#sampled$2234  = 1'b0;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$$assume$axi4lite_formal .\sv:97$28_EN#sampled$2248  = 1'b0;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$$logic_and$axi4lite_formal .\sv:106$36_Y#sampled$2268  = 1'b1;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$axi4lite_formal .\sv:95$27_Y#sampled$2240  = 1'b1;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_formal .\sv:100$10$0#sampled$2190  = 1'b0;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$/aresetn#sampled$2192  = 1'b0;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$/aresetn#sampled$2254  = 1'b1;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$/f_past_valid#sampled$2180  = 1'b0;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$1'1#sampled$2182  = 1'b0;
    // UUT.$auto$clk2fflogic.\cc:87:sample_control_edge$/aclk#sampled$2242  = 1'b1;
    UUT.aclk = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/aw_pending[0:0]#sampled$3602  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/awaddr_hold[3:0]#sampled$3612  = 4'b0000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/control_reg[31:0]#sampled$3562  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/data0_reg[31:0]#sampled$3582  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/data1_reg[31:0]#sampled$3592  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/s_axi_bresp[1:0]#sampled$3542  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/s_axi_bvalid[0:0]#sampled$3552  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/s_axi_rdata[31:0]#sampled$3512  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/s_axi_rresp[1:0]#sampled$3522  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/s_axi_rvalid[0:0]#sampled$3532  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/status_reg[31:0]#sampled$3572  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/w_pending[0:0]#sampled$3622  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/wdata_hold[31:0]#sampled$3632  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/wstrb_hold[3:0]#sampled$3642  = 4'b0000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/aw_pending#sampled$3600  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/awaddr_hold#sampled$3610  = 4'b0000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/control_reg#sampled$3560  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/data0_reg#sampled$3580  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/data1_reg#sampled$3590  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_bresp#sampled$3540  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_bvalid#sampled$3550  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_rdata#sampled$3510  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_rresp#sampled$3520  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_rvalid#sampled$3530  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/status_reg#sampled$3570  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/w_pending#sampled$3620  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/wdata_hold#sampled$3630  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/wstrb_hold#sampled$3640  = 4'b0000;
    // UUT.dut.$auto$clk2fflogic.\cc:87:sample_control_edge$/aclk#sampled$3644  = 1'b1;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/expected_read_data[31:0]#sampled$2382  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/expected_read_resp[1:0]#sampled$2392  = 2'b00;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/expected_read_valid[0:0]#sampled$2372  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/model_aw_pending[0:0]#sampled$2282  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/model_awaddr[3:0]#sampled$2292  = 4'b0000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/model_control[31:0]#sampled$2332  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/model_data0[31:0]#sampled$2352  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/model_data1[31:0]#sampled$2362  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/model_status[31:0]#sampled$2342  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/model_w_pending[0:0]#sampled$2302  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/model_wdata[31:0]#sampled$2312  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/model_wstrb[3:0]#sampled$2322  = 4'b0000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_functional .\sv:253$237$0#sampled$2400  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/aresetn#sampled$2402  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/expected_read_data#sampled$2380  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/expected_read_resp#sampled$2390  = 2'b00;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/expected_read_valid#sampled$2370  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/f_past_valid#sampled$2270  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/model_aw_pending#sampled$2280  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/model_awaddr#sampled$2290  = 4'b0000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/model_control#sampled$2330  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/model_data0#sampled$2350  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/model_data1#sampled$2360  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/model_status#sampled$2340  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/model_w_pending#sampled$2300  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/model_wdata#sampled$2310  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/model_wstrb#sampled$2320  = 4'b0000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$1'1#sampled$2272  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:87:sample_control_edge$/aclk#sampled$2284  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:102$40$0[0:0]$64#sampled$2706  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:102$40$0[0:0]$64#sampled$3368  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:108$42$0[0:0]$66#sampled$2726  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:108$42$0[0:0]$66#sampled$3382  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:115$45$0[0:0]$69#sampled$2756  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:115$45$0[0:0]$69#sampled$3410  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:127$47$0[0:0]$71#sampled$2776  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:127$47$0[0:0]$71#sampled$3396  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:133$49$0[0:0]$73#sampled$2796  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:133$49$0[0:0]$73#sampled$3424  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0/aw_seen[0:0]#sampled$2646  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0/read_request_open[0:0]#sampled$2686  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0/w_seen[0:0]#sampled$2656  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0/write_request_open[0:0]#sampled$2666  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0/write_wait_cycle[0:0]#sampled$2676  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_properties .\sv:148$97_EN#sampled$3418  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assume$axi4lite_properties .\sv:103$78_EN#sampled$3194  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assume$axi4lite_properties .\sv:109$81_EN#sampled$3250  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assume$axi4lite_properties .\sv:116$86_EN#sampled$3278  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_properties .\sv:104$80_Y#sampled$3214  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_properties .\sv:110$83_Y#sampled$3242  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_properties .\sv:111$85_Y#sampled$3256  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_properties .\sv:117$88_Y#sampled$3284  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_and$axi4lite_properties .\sv:292$162_Y#sampled$3438  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_and$axi4lite_properties .\sv:293$164_Y#sampled$3452  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_and$axi4lite_properties .\sv:294$166_Y#sampled$3466  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_and$axi4lite_properties .\sv:298$171_Y#sampled$3480  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_and$axi4lite_properties .\sv:304$174_Y#sampled$3494  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_and$axi4lite_properties .\sv:305$177_Y#sampled$3508  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:102$40$0#sampled$2704  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:104$41$0#sampled$2714  = 4'b0000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:108$42$0#sampled$2724  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:110$43$0#sampled$2734  = 32'b00000000000000000000000000000000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:111$44$0#sampled$2744  = 4'b0000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:115$45$0#sampled$2754  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:117$46$0#sampled$2764  = 4'b0000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:127$47$0#sampled$2774  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:129$48$0#sampled$2784  = 2'b00;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:133$49$0#sampled$2794  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:135$50$0#sampled$2804  = 32'b00000000000000000000000000000000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:136$51$0#sampled$2814  = 2'b00;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:99$39$0#sampled$2694  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/ar_fire#sampled$3340  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/aresetn#sampled$2696  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/aw_fire#sampled$3298  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/aw_seen#sampled$2644  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/b_fire#sampled$3326  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/f_past_valid#sampled$2634  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/r_fire#sampled$3354  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/read_request_open#sampled$2684  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_araddr#sampled$2766  = 4'b0000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_arvalid#sampled$3270  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_awaddr#sampled$2716  = 4'b0000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_awvalid#sampled$3200  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_bresp#sampled$2786  = 2'b00;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_rdata#sampled$2806  = 32'b00000000000000000000000000000000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_rresp#sampled$2816  = 2'b00;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_wdata#sampled$2736  = 32'b00000000000000000000000000000000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_wstrb#sampled$2746  = 4'b0000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_wvalid#sampled$3228  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/w_fire#sampled$3312  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/w_seen#sampled$2654  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/write_request_open#sampled$2664  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/write_wait_cycle#sampled$2674  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$1'1#sampled$2636  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:87:sample_control_edge$/aclk#sampled$3272  = 1'b1;

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
      UUT.s_axi_araddr <= 4'b0110;
      UUT.s_axi_arvalid <= 1'b0;
      UUT.s_axi_awaddr <= 4'b0000;
      UUT.s_axi_awvalid <= 1'b0;
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
      UUT.s_axi_araddr <= 4'b0000;
      UUT.s_axi_arvalid <= 1'b0;
      UUT.s_axi_awaddr <= 4'b0000;
      UUT.s_axi_awvalid <= 1'b1;
      UUT.s_axi_bready <= 1'b0;
      UUT.s_axi_rready <= 1'b1;
      UUT.s_axi_wdata <= 32'b00000000000000000000000000000000;
      UUT.s_axi_wstrb <= 4'b0000;
      UUT.s_axi_wvalid <= 1'b0;
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

    genclock <= cycle < 5;
    cycle <= cycle + 1;
  end
endmodule
