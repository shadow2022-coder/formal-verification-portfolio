# Verification and Proof Results

## 1. Summary

The cache controller was verified using:

- Verilator RTL lint
- directed SystemVerilog simulation
- unbounded formal safety proof
- bounded symbolic data-integrity checking
- formal cover analysis
- intentional fault injection

All correct-design checks passed. Both intentionally broken RTL variants produced the expected assertion counterexamples.

---

## 2. Result Overview

| Verification activity | Configuration | Result |
|---|---|---|
| RTL lint | Verilator | PASS |
| Directed simulation | Icarus Verilog | PASS |
| Control and protocol proof | ABC PDR, unbounded safety proof | PASS |
| Symbolic data-integrity proof | ABC BMC3, depth 22 | PASS |
| Formal cover analysis | SMTBMC + Boolector, depth 50 | PASS |
| Wrong writeback-address injection | SMTBMC + Boolector | Expected FAIL detected |
| Broken WSTRB injection | SMTBMC + Boolector | Expected FAIL detected |

---

## 3. RTL Lint

Command:

```bash
make lint
```

Tool:

```text
Verilator
```

Result:

```text
PASS
```

The lint run checks the synthesizable cache-controller RTL for structural and
language-level issues.

Warnings that are explicitly treated as non-fatal do not change the functional
verification result.

---

## 4. Directed Simulation

Command:

```bash
make sim
```

Tools:

```text
Icarus Verilog
VVP
```

Result:

```text
PASS: all 10 directed cache scenarios
```

Verified scenarios:

| ID | Scenario | Result |
|---|---|---|
| SIM-01 | Cold read miss and refill | PASS |
| SIM-02 | Read hit after refill | PASS |
| SIM-03 | Write hit and dirty-bit update | PASS |
| SIM-04 | Read after write | PASS |
| SIM-05 | Partial write using WSTRB | PASS |
| SIM-06 | Clean conflict miss | PASS |
| SIM-07 | Dirty conflict miss and writeback | PASS |
| SIM-08 | Memory request backpressure | PASS |
| SIM-09 | Delayed memory response | PASS |
| SIM-10 | CPU response backpressure | PASS |

Simulation waveform:

```text
docs/dirty-eviction-waveform.png
```

---

## 5. Unbounded Control and Protocol Proof

Command:

```bash
make formal
```

Configuration:

```text
File: formal/cache.sby
Mode: prove
Engine: ABC PDR
```

Result:

```text
PASS
```

Classification:

```text
Unbounded safety proof for the implemented assertions
```

The proof includes properties covering:

- reset behavior
- dirty-implies-valid invariant
- hit classification
- request capture and stability
- CPU response stability
- memory request stability
- clean miss behavior
- dirty eviction sequencing
- victim-address reconstruction
- refill request correctness
- refill installation
- read-hit behavior
- write-hit behavior
- WSTRB-controlled cache updates
- CPU response generation

This result is unbounded for the assertions included in the control and protocol
property module.

It does not prove unconditional liveness when the external environment may
stall forever.

---

## 6. Bounded Symbolic Data-Integrity Proof

Command:

```bash
make data
```

Configuration:

```text
File: formal/cache_data.sby
Mode: BMC
Engine: ABC BMC3
Depth: 22 cycles
```

Result:

```text
PASS
```

Classification:

```text
Bounded symbolic proof through 22 cycles
```

Symbolic quantities include:

- tracked cache address
- initial memory value
- CPU write data
- CPU byte strobes
- conflicting addresses
- cache hit and miss paths

Checked assertions:

| Property | Requirement |
|---|---|
| `F_DATA_01` | A read response for the tracked address returns the expected value |
| `F_DATA_02` | A resident tracked line contains the expected value |
| `F_DATA_03` | A tracked-address writeback contains the expected value |

The proof includes partial-byte writes and dirty writeback.

This result must be described as bounded. It does not claim an unbounded proof
of all possible data sequences.

---

## 7. Formal Cover Results

Command:

```bash
make cover
```

Configuration:

```text
File: formal/cache_cover.sby
Mode: cover
Engine: SMTBMC with Boolector
Depth: 50 cycles
```

Result:

```text
PASS
```

Reached cover properties:

| Cover property | Scenario | Reached step |
|---|---|---:|
| `C_MISS_01` | Basic cache miss | 4 |
| `C_BACKPRESSURE_01` | Memory request backpressure | 6 |
| `C_REFILL_01` | Refill transaction | 8 |
| `C_BACKPRESSURE_02` | CPU response backpressure | 10 |
| `C_HIT_01` | Cache hit | 14 |
| `C_MISS_02` | Conflict miss | 14 |
| `C_EVICT_01` | Dirty writeback | 14 |
| `C_WRITE_01` | Cache write | 14 |
| `C_WRITE_02` | Partial or allocated write | 14 |
| `C_EVICT_02` | Dirty eviction followed by refill | 24 |

Formal dirty-eviction waveform:

```text
docs/formal-dirty-eviction-cover.png
```

The cover results demonstrate that important cache paths are reachable under
the formal assumptions and reduce the risk of vacuous assertion success.

---

## 8. Fault Injection 1: Incorrect Writeback Address

Command:

```bash
make fault-wb
```

Fault file:

```text
formal/cache_controller_bug_wb_addr.sv
```

Injected defect:

```systemverilog
mem_req_addr = {
    req_tag,
    req_index,
    {OFFSET_WIDTH{1'b0}}
};
```

The faulty implementation uses the incoming request tag instead of the stored
victim tag.

Formal result:

```text
Expected FAIL
```

Detected property:

```text
A_EVICT_01_ADDR
```

Failure step:

```text
9
```

Counterexample trace:

```text
formal/cache_bug_wb/engine_0/trace.vcd
```

The result demonstrates that the property suite detects incorrect dirty-victim
address reconstruction.

---

## 9. Fault Injection 2: WSTRB Ignored

Command:

```bash
make fault-wstrb
```

Fault file:

```text
formal/cache_controller_bug_wstrb.sv
```

Injected defect:

```systemverilog
data_array[req_index] <= req_wdata_reg;
```

The faulty implementation overwrites the complete cache word instead of
preserving bytes whose strobe bits are zero.

Formal result:

```text
Expected FAIL
```

Detected property:

```text
F_DATA_02
```

Failure step:

```text
9
```

Counterexample trace:

```text
formal/cache_bug_wstrb/engine_0/trace.vcd
```

The result demonstrates that the tracked-address data property detects
partial-write corruption.

---

## 10. Automated Targets

Available Makefile targets:

```bash
make help
make lint
make sim
make formal
make data
make cover
make fault-wb
make fault-wstrb
make faults
make regression
make clean
```

The complete correct-design regression is:

```bash
make regression
```

Fault injection is intentionally kept separate because those runs are expected
to produce assertion failures.

---

## 11. Proof Interpretation

The verified result should be stated precisely:

> The cache controller passed directed simulation, an unbounded formal safety
> proof for control and protocol assertions, a 22-cycle bounded symbolic
> data-integrity proof, and formal cover analysis. Two intentionally injected
> defects were detected by assertion counterexamples at step 9.

The project does not claim:

- unconditional liveness without fairness assumptions
- an unbounded proof of every possible data sequence
- cache coherence
- multiple outstanding transactions
- multiword cache lines
- unaligned accesses

---

## 12. Final Status

| Closure item | Status |
|---|---|
| RTL implementation | Complete |
| Directed regression | PASS |
| Control and protocol assertions | PASS |
| Symbolic data assertions | PASS through depth 22 |
| Formal covers | PASS |
| Assumption audit | Complete |
| Property matrix | Complete |
| Fault injection | Complete |
| Counterexample report | Complete |
| Makefile automation | Complete |