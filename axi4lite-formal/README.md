# AXI4-Lite Formal Protocol Checker and Register Slave

A four-register AXI4-Lite slave implemented in SystemVerilog and verified
using simulation and open-source formal-verification tools.

The project demonstrates independent AXI write-channel handling,
backpressure, byte write strobes, symbolic inputs, transaction tracking,
reference-model checking, assumption auditing, cover properties, and
counterexample-driven debugging.

## Register Map

| Address | Register | Width |
|---|---|---:|
| `0x0` | CONTROL | 32 bits |
| `0x4` | STATUS | 32 bits |
| `0x8` | DATA0 | 32 bits |
| `0xC` | DATA1 | 32 bits |

Other addresses return `SLVERR`.

## Supported Behavior

- Independent write-address and write-data arrival
- Address-before-data writes
- Data-before-address writes
- Same-cycle address and data
- One outstanding write transaction
- One outstanding read transaction
- Read and write backpressure
- Stable response payloads during stalls
- Byte-selective writes using `WSTRB`
- Invalid-address responses
- Concurrent read and write activity
- Active-low synchronous reset

## Verification Approach

### Simulation

The self-checking SystemVerilog testbench verifies:

- Full writes and reads
- Partial writes
- All write-channel arrival orders
- Write-response backpressure
- Read-response backpressure
- Invalid addresses
- Concurrent read and write transactions
- Reset behavior

### Formal Verification

The formal environment uses symbolic:

- Addresses
- Write data
- Byte strobes
- VALID timing
- READY timing
- Backpressure duration

Master-controlled behavior is constrained using protocol assumptions.

Slave behavior is checked using assertions for:

- Response stability
- Transaction integrity
- No lost or duplicated requests
- No response without a request
- Outstanding-transaction limits
- Correct register updates
- Correct `WSTRB` handling
- Correct read values
- Invalid-address responses
- Reset behavior

Cover properties demonstrate that transactions, stalls, partial writes,
invalid addresses, and every write-channel ordering are reachable.

## Assume-Guarantee Model

The symbolic master is assumed to:

- Hold `AWVALID` and `AWADDR` while stalled
- Hold `WVALID`, `WDATA`, and `WSTRB` while stalled
- Hold `ARVALID` and `ARADDR` while stalled

The slave guarantees stable responses and correct transaction and register
behavior.

An assumption audit disables these master assumptions and produces an
expected counterexample, demonstrating that the assumptions are necessary
and active.

## Counterexample Exercises

Three bugs were intentionally introduced:

1. `BVALID` deasserted before `BREADY`
2. `RDATA` changed during read backpressure
3. `WSTRB` was ignored during a partial write

Each bug generated a formal counterexample. The waveform was inspected,
the root cause was documented, the RTL was restored, and the normal proof
was rerun successfully.

See:

```text
docs/counterexample_reports.md