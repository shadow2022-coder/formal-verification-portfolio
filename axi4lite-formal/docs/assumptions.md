# Formal Assumptions

## Purpose

The formal harness represents an arbitrary AXI4-Lite master.

The master is symbolic, but it must obey the AXI READY/VALID protocol.

## Write Address Assumptions

If `AWVALID` is asserted while `AWREADY` is low:

- `AWVALID` remains asserted
- `AWADDR` remains stable

## Write Data Assumptions

If `WVALID` is asserted while `WREADY` is low:

- `WVALID` remains asserted
- `WDATA` remains stable
- `WSTRB` remains stable

## Read Address Assumptions

If `ARVALID` is asserted while `ARREADY` is low:

- `ARVALID` remains asserted
- `ARADDR` remains stable

## Why These Assumptions Are Required

The slave does not control master-driven signals.

Without these assumptions, the formal environment may change or withdraw a
request before it is accepted. That behavior violates AXI and does not
represent a compliant master.

## Assumption Audit

The normal assumptions were temporarily disabled.

The master-protocol rules were converted into assertions, and formal
verification produced a counterexample. This demonstrated that the
assumptions were active and necessary.

## Avoiding Overconstraint

The environment does not assume:

- Specific addresses
- Specific data
- Specific byte strobes
- Immediate readiness
- A fixed transaction order

Cover properties confirm that transactions, stalls, partial writes, and
invalid addresses remain reachable.