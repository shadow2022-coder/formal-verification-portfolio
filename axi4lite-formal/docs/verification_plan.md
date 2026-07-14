# Verification Plan

## Objective

Verify the AXI4-Lite slave at both protocol and functional levels using
simulation and formal verification.

## Simulation Tests

The self-checking testbench covers:

- Full register writes
- Register reads
- Address and data arriving together
- Address before data
- Data before address
- Partial writes using `WSTRB`
- Write-response backpressure
- Read-response backpressure
- Invalid addresses
- Concurrent read and write activity
- Reset behavior

## Formal Verification Areas

### Protocol behavior

- Response stability during backpressure
- Independent AW and W channel handling
- No response without a request
- No duplicated response
- At most one outstanding transaction
- No request accepted twice

### Functional behavior

- Correct address decoding
- Correct register updates
- Correct byte-strobe application
- Unselected bytes remain unchanged
- Correct read data
- Invalid addresses return `SLVERR`
- Reset clears all registers and protocol state

### Reachability

Cover properties demonstrate:

- Every AXI channel handshake
- Write and read stalls
- Address-before-data writes
- Data-before-address writes
- Same-cycle address and data
- Partial writes
- Invalid-address responses

## Counterexample Exercises

Three intentional defects were tested:

1. Premature `BVALID` deassertion
2. Changing `RDATA` during backpressure
3. Ignoring `WSTRB`

Each defect generated a formal counterexample and was repaired before the
normal proof was rerun.