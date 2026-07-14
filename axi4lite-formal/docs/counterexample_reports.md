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