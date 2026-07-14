# Counterexample Reports

## Bug 1 — Premature BVALID Deassertion

### Injected defect

The write-response logic was intentionally changed to clear `BVALID`
after one cycle, even when the AXI master had not asserted `BREADY`.

Incorrect implementation:

```systemverilog
if (s_axi_bvalid) begin
    s_axi_bvalid <= 1'b0;
end

## Bug 2 — RDATA Changed During Backpressure

### Injected defect

The read-data logic was intentionally modified so that `RDATA`
incremented whenever the slave was holding a response and the master
kept `RREADY` low.

Incorrect implementation:

```systemverilog
if (s_axi_rvalid && !s_axi_rready) begin
    s_axi_rdata <= s_axi_rdata + 32'h1;
end


## Bug 3 — WSTRB Ignored During Partial Write

### Injected defect

The DATA0 write logic was intentionally changed to overwrite the complete
32-bit register without checking `WSTRB`.

Incorrect implementation:

```systemverilog
data0_reg <= wdata_hold;