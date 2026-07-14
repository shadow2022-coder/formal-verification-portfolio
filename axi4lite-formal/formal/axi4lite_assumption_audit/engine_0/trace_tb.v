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
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_formal .\sv:101$31_EN#sampled$2395  = 1'b0;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$$assume$axi4lite_formal .\sv:95$26_EN#sampled$2409  = 1'b0;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$$assume$axi4lite_formal .\sv:97$28_EN#sampled$2423  = 1'b0;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$axi4lite_formal .\sv:101$32_Y#sampled$2387  = 1'b1;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$axi4lite_formal .\sv:102$34_Y#sampled$2401  = 1'b1;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$axi4lite_formal .\sv:95$27_Y#sampled$2415  = 1'b1;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_formal .\sv:100$10$0#sampled$2365  = 1'b0;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$/aresetn#sampled$2367  = 1'b0;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$/aresetn#sampled$2429  = 1'b1;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$/f_past_valid#sampled$2355  = 1'b0;
    // UUT.$auto$clk2fflogic.\cc:101:sample_data$1'1#sampled$2357  = 1'b0;
    // UUT.$auto$clk2fflogic.\cc:87:sample_control_edge$/aclk#sampled$2403  = 1'b1;
    UUT.aclk = 1'b0;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_assumption_audit .\sv:26$40$0[0:0]$49#sampled$2189  = 1'b0;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_assumption_audit .\sv:31$42$0[0:0]$51#sampled$2209  = 1'b0;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_assumption_audit .\sv:37$45$0[0:0]$54#sampled$2239  = 1'b0;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_assumption_audit .\sv:27$58_EN#sampled$2277  = 1'b0;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_assumption_audit .\sv:32$61_EN#sampled$2319  = 1'b0;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_assumption_audit .\sv:38$66_EN#sampled$2333  = 1'b0;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_assumption_audit .\sv:28$60_Y#sampled$2283  = 1'b1;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_assumption_audit .\sv:33$63_Y#sampled$2311  = 1'b1;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_assumption_audit .\sv:34$65_Y#sampled$2325  = 1'b1;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_assumption_audit .\sv:39$68_Y#sampled$2353  = 1'b1;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_assumption_audit .\sv:24$39$0#sampled$2177  = 1'b0;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_assumption_audit .\sv:26$40$0#sampled$2187  = 1'b0;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_assumption_audit .\sv:28$41$0#sampled$2197  = 4'b0000;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_assumption_audit .\sv:31$42$0#sampled$2207  = 1'b0;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_assumption_audit .\sv:33$43$0#sampled$2217  = 32'b00000000000000000000000000000000;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_assumption_audit .\sv:34$44$0#sampled$2227  = 4'b0000;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_assumption_audit .\sv:37$45$0#sampled$2237  = 1'b0;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_assumption_audit .\sv:39$46$0#sampled$2247  = 4'b0000;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$/aresetn#sampled$2179  = 1'b0;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$/f_past_valid#sampled$2167  = 1'b0;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_araddr#sampled$2249  = 4'b0000;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_arvalid#sampled$2339  = 1'b1;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_awaddr#sampled$2199  = 4'b0000;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_awvalid#sampled$2269  = 1'b1;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_wdata#sampled$2219  = 32'b00000000000000000000000000000000;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_wstrb#sampled$2229  = 4'b0000;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_wvalid#sampled$2297  = 1'b1;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:101:sample_data$1'1#sampled$2169  = 1'b0;
    // UUT.assumption_audit.$auto$clk2fflogic.\cc:87:sample_control_edge$/aclk#sampled$2313  = 1'b1;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/aw_pending[0:0]#sampled$3609  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/awaddr_hold[3:0]#sampled$3619  = 4'b0000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/control_reg[31:0]#sampled$3569  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/data0_reg[31:0]#sampled$3589  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/data1_reg[31:0]#sampled$3599  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/s_axi_bresp[1:0]#sampled$3549  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/s_axi_bvalid[0:0]#sampled$3559  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/s_axi_rdata[31:0]#sampled$3519  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/s_axi_rresp[1:0]#sampled$3529  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/s_axi_rvalid[0:0]#sampled$3539  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/status_reg[31:0]#sampled$3579  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/w_pending[0:0]#sampled$3629  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/wdata_hold[31:0]#sampled$3639  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$$0/wstrb_hold[3:0]#sampled$3649  = 4'b0000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/aw_pending#sampled$3607  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/awaddr_hold#sampled$3617  = 4'b0000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/control_reg#sampled$3567  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/data0_reg#sampled$3587  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/data1_reg#sampled$3597  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_bresp#sampled$3547  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_bvalid#sampled$3557  = 1'b1;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_rdata#sampled$3517  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_rresp#sampled$3527  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_rvalid#sampled$3537  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/status_reg#sampled$3577  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/w_pending#sampled$3627  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/wdata_hold#sampled$3637  = 32'b00000000000000000000000000000000;
    // UUT.dut.$auto$clk2fflogic.\cc:101:sample_data$/wstrb_hold#sampled$3647  = 4'b0000;
    // UUT.dut.$auto$clk2fflogic.\cc:87:sample_control_edge$/aclk#sampled$3651  = 1'b1;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/expected_read_data[31:0]#sampled$2557  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/expected_read_resp[1:0]#sampled$2567  = 2'b00;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/expected_read_valid[0:0]#sampled$2547  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/model_aw_pending[0:0]#sampled$2457  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/model_awaddr[3:0]#sampled$2467  = 4'b0000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/model_control[31:0]#sampled$2507  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/model_data0[31:0]#sampled$2527  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/model_data1[31:0]#sampled$2537  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/model_status[31:0]#sampled$2517  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/model_w_pending[0:0]#sampled$2477  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/model_wdata[31:0]#sampled$2487  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$0/model_wstrb[3:0]#sampled$2497  = 4'b0000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_functional .\sv:228$371_EN#sampled$2633  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_functional .\sv:236$382_EN#sampled$2647  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_functional .\sv:238$384_EN#sampled$2661  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_functional .\sv:243$386_EN#sampled$2703  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_functional .\sv:249$391_EN#sampled$2717  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_functional .\sv:254$394_EN#sampled$2745  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_functional .\sv:228$372_Y#sampled$2597  = 1'b1;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_functional .\sv:229$374_Y#sampled$2611  = 1'b1;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_functional .\sv:230$376_Y#sampled$2625  = 1'b1;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_functional .\sv:231$378_Y#sampled$2639  = 1'b1;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_functional .\sv:236$383_Y#sampled$2653  = 1'b1;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_functional .\sv:238$385_Y#sampled$2667  = 1'b1;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_functional .\sv:244$388_Y#sampled$2695  = 1'b1;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_functional .\sv:245$390_Y#sampled$2709  = 1'b1;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_functional .\sv:254$395_Y#sampled$2737  = 1'b1;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_functional .\sv:255$397_Y#sampled$2751  = 1'b1;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_functional .\sv:256$399_Y#sampled$2765  = 1'b1;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_functional .\sv:257$401_Y#sampled$2779  = 1'b1;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$axi4lite_functional .\sv:145$305_Y#sampled$2793  = 1'b1;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$axi4lite_functional .\sv:260$405_Y#sampled$2807  = 1'b1;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_functional .\sv:253$243$0#sampled$2575  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/aresetn#sampled$2577  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/expected_read_data#sampled$2555  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/expected_read_resp#sampled$2565  = 2'b00;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/expected_read_valid#sampled$2545  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/expected_read_valid#sampled$2681  = 1'b1;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/f_past_valid#sampled$2445  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/model_aw_pending#sampled$2455  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/model_awaddr#sampled$2465  = 4'b0000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/model_control#sampled$2505  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/model_data0#sampled$2525  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/model_data1#sampled$2535  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/model_status#sampled$2515  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/model_w_pending#sampled$2475  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/model_wdata#sampled$2485  = 32'b00000000000000000000000000000000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/model_wstrb#sampled$2495  = 4'b0000;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_rvalid#sampled$2723  = 1'b1;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:101:sample_data$1'1#sampled$2447  = 1'b0;
    // UUT.dut.functional_properties.$auto$clk2fflogic.\cc:87:sample_control_edge$/aclk#sampled$2739  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:138$77$0[0:0]$94#sampled$2881  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0$past$axi4lite_properties .\sv:144$79$0[0:0]$96#sampled$2901  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0/aw_seen[0:0]#sampled$2821  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0/read_request_open[0:0]#sampled$2861  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0/w_seen[0:0]#sampled$2831  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0/write_request_open[0:0]#sampled$2841  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$0/write_wait_cycle[0:0]#sampled$2851  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_properties .\sv:139$101_EN#sampled$2949  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_properties .\sv:145$104_EN#sampled$2991  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_properties .\sv:159$109_EN#sampled$3019  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_properties .\sv:166$116_EN#sampled$3033  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_properties .\sv:170$118_EN#sampled$3047  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_properties .\sv:174$120_EN#sampled$3075  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_properties .\sv:187$124_EN#sampled$3089  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_properties .\sv:193$125_EN#sampled$3103  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_properties .\sv:201$127_EN#sampled$3117  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_properties .\sv:207$131_EN#sampled$3145  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_properties .\sv:215$135_EN#sampled$3173  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_properties .\sv:234$140_EN#sampled$3201  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_properties .\sv:247$142_EN#sampled$3271  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_properties .\sv:255$144_EN#sampled$3229  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_properties .\sv:259$145_EN#sampled$3243  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$assert$axi4lite_properties .\sv:265$147_EN#sampled$3257  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_properties .\sv:140$103_Y#sampled$2955  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_properties .\sv:146$106_Y#sampled$2983  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$eq$axi4lite_properties .\sv:147$108_Y#sampled$2997  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$axi4lite_properties .\sv:159$111_Y#sampled$3011  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$axi4lite_properties .\sv:162$115_Y#sampled$3025  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$axi4lite_properties .\sv:166$117_Y#sampled$3067  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$axi4lite_properties .\sv:170$119_Y#sampled$3081  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$axi4lite_properties .\sv:193$126_Y#sampled$3109  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$axi4lite_properties .\sv:201$128_Y#sampled$3123  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$axi4lite_properties .\sv:207$132_Y#sampled$3151  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$axi4lite_properties .\sv:234$141_Y#sampled$3207  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$axi4lite_properties .\sv:247$143_Y#sampled$3221  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$axi4lite_properties .\sv:259$146_Y#sampled$3249  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_or$axi4lite_properties .\sv:220$139_Y#sampled$3193  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$logic_or$axi4lite_properties .\sv:274$152_Y#sampled$3291  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:138$77$0#sampled$2879  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:140$78$0#sampled$2889  = 2'b00;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:144$79$0#sampled$2899  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:146$80$0#sampled$2909  = 32'b00000000000000000000000000000000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:147$81$0#sampled$2919  = 2'b00;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$$past$axi4lite_properties .\sv:99$76$0#sampled$2869  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/aresetn#sampled$2871  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/aw_seen#sampled$2819  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/f_past_valid#sampled$2809  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/read_request_open#sampled$2859  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/read_request_open#sampled$3263  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_bresp#sampled$2891  = 2'b00;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_bvalid#sampled$2941  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_rdata#sampled$2911  = 32'b00000000000000000000000000000000;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_rresp#sampled$2921  = 2'b00;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/s_axi_rvalid#sampled$2969  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/w_seen#sampled$2829  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/write_request_open#sampled$2839  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/write_request_open#sampled$3095  = 1'b1;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$/write_wait_cycle#sampled$2849  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:101:sample_data$1'1#sampled$2811  = 1'b0;
    // UUT.properties.$auto$clk2fflogic.\cc:87:sample_control_edge$/aclk#sampled$3125  = 1'b1;

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
      UUT.s_axi_arvalid <= 1'b1;
      UUT.s_axi_awaddr <= 4'b0000;
      UUT.s_axi_awvalid <= 1'b0;
      UUT.s_axi_bready <= 1'b0;
      UUT.s_axi_rready <= 1'b0;
      UUT.s_axi_wdata <= 32'b11111111111111111111111111111111;
      UUT.s_axi_wstrb <= 4'b1111;
      UUT.s_axi_wvalid <= 1'b0;
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
      UUT.s_axi_awvalid <= 1'b0;
      UUT.s_axi_bready <= 1'b0;
      UUT.s_axi_rready <= 1'b0;
      UUT.s_axi_wdata <= 32'b11111111111111111111111111111111;
      UUT.s_axi_wstrb <= 4'b1111;
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

    // state 6
    if (cycle == 5) begin
      UUT.aresetn <= 1'b1;
      UUT.s_axi_araddr <= 4'b1111;
      UUT.s_axi_arvalid <= 1'b0;
      UUT.s_axi_awaddr <= 4'b1111;
      UUT.s_axi_awvalid <= 1'b0;
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
