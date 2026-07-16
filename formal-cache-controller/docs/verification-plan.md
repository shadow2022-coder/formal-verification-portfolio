# Cache Controller Verification Plan

## 1. Objective

The objective is to verify the functional correctness, protocol behavior, data
integrity, and control sequencing of a small direct-mapped write-back cache
controller.

The controller supports:

- CPU read and write requests
- read hits and write hits
- partial writes using byte strobes
- clean cache misses
- dirty cache-line eviction
- memory writeback
- refill
- write allocation
- CPU response backpressure
- memory request and response backpressure
- one outstanding CPU transaction
- one outstanding memory transaction

---

## 2. Design Configuration

| Feature | Configuration |
|---|---|
| Address width | 8 bits |
| Data width | 32 bits |
| Number of cache lines | 4 |
| Words per line | 1 |
| Placement | Direct mapped |
| Write policy | Write-back |
| Write-miss policy | Write allocate |
| CPU outstanding requests | 1 |
| Memory outstanding requests | 1 |
| Address alignment | 32-bit word aligned |

Address decomposition:

```text
Address [7:4] = tag
Address [3:2] = cache index
Address [1:0] = byte offset
```

---

## 3. Verification Strategy

The project uses several complementary verification methods.

### 3.1 RTL lint

Verilator checks the synthesizable RTL for:

- syntax errors
- width mismatches
- unused or undriven signals
- suspicious constructs
- incomplete combinational assignments

Command:

```bash
make lint
```

### 3.2 Directed simulation

The SystemVerilog testbench drives deterministic CPU and memory transactions.

Command:

```bash
make sim
```

The regression covers ten required scenarios.

### 3.3 Unbounded control and protocol proof

The main formal proof checks control, handshake, state-transition, hit, miss,
refill, response, and dirty-eviction safety properties.

Configuration:

```text
File: formal/cache.sby
Mode: prove
Engine: ABC PDR
```

Command:

```bash
make formal
```

This proof is unbounded for the implemented safety properties.

### 3.4 Bounded symbolic data-integrity proof

A tracked-address model verifies data correctness using arbitrary addresses,
arbitrary initial data, arbitrary CPU write data, and arbitrary byte strobes.

Configuration:

```text
File: formal/cache_data.sby
Mode: BMC
Depth: 22 cycles
Engine: ABC BMC3
```

Command:

```bash
make data
```

This is a bounded proof and must not be described as an unbounded data proof.

### 3.5 Formal cover analysis

Cover properties demonstrate that important cache behaviors remain reachable
under the formal assumptions.

Configuration:

```text
File: formal/cache_cover.sby
Mode: cover
Depth: 50 cycles
Engine: SMTBMC with Boolector
```

Command:

```bash
make cover
```

### 3.6 Fault injection

Two intentional RTL defects verify that the property set can detect realistic
implementation bugs.

Command:

```bash
make faults
```

---

## 4. Directed Simulation Scenarios

| ID | Scenario | Expected result |
|---|---|---|
| SIM-01 | Cold read miss and refill | Memory read occurs and CPU receives refill data |
| SIM-02 | Read after refill | Request becomes a cache hit |
| SIM-03 | Write hit | Selected cache line is updated and marked dirty |
| SIM-04 | Read after write | CPU receives the updated cached value |
| SIM-05 | Partial write using WSTRB | Enabled bytes change and disabled bytes remain unchanged |
| SIM-06 | Clean conflict miss | Old clean line is replaced without writeback |
| SIM-07 | Dirty conflict miss | Victim is written back before refill |
| SIM-08 | Memory request backpressure | Request fields remain stable until accepted |
| SIM-09 | Delayed memory response | Controller waits without losing transaction state |
| SIM-10 | CPU response backpressure | Response valid and data remain stable until accepted |

Successful regression message:

```text
PASS: all 10 directed cache scenarios
```

---

## 5. Main Verification Requirements

### 5.1 Reset correctness

Verify that reset:

- returns the FSM to `IDLE`
- clears all valid bits
- clears all dirty bits
- removes pending CPU responses
- removes pending memory transactions
- prevents stale cache entries from producing hits

### 5.2 CPU request protocol

Verify that:

- a request is accepted only on `cpu_req_valid && cpu_req_ready`
- request payload is captured at the handshake
- no second request is accepted while a transaction is active
- captured request fields remain stable during processing

### 5.3 CPU response protocol

Verify that:

- responses are generated only for accepted CPU requests
- response data is stable while stalled
- `cpu_rsp_valid` remains asserted until accepted
- no new CPU request is accepted while a response is pending

### 5.4 Memory request protocol

Verify that:

- writeback and refill requests are correctly distinguished
- request address and data remain stable under backpressure
- only one memory request is outstanding
- refill requests use the requested address
- dirty writebacks use the stored victim address

### 5.5 Hit behavior

Verify that:

- a hit requires both a valid line and matching tag
- read hits return the stored cache data
- write hits update the selected bytes
- write hits mark the line dirty
- an invalid line cannot produce a hit

### 5.6 Miss behavior

Verify that:

- an invalid-line miss proceeds directly to refill
- a clean conflict miss does not write back the victim
- a dirty conflict miss writes back before refill
- refill installs the new tag and data
- refill marks the line valid
- read refill leaves the line clean
- write allocation applies WSTRB and marks the line dirty

### 5.7 Dirty eviction

Verify that:

- dirty victim data is preserved
- writeback uses the stored victim tag
- writeback uses the conflicting cache index
- byte-offset bits are zero
- refill begins only after writeback completion
- the new line is installed only after refill completion

### 5.8 Data integrity

For an arbitrary tracked address, verify that:

- reads return the expected architectural value
- partial writes preserve unselected bytes
- a resident tracked line contains the expected value
- dirty writeback contains the complete expected value
- eviction and later refill preserve the tracked value

---

## 6. Formal Cover Goals

The cover plan includes reachability of:

| Cover | Behavior |
|---|---|
| `C_MISS_01` | Basic cache miss |
| `C_MISS_02` | Conflict miss |
| `C_REFILL_01` | Memory refill |
| `C_HIT_01` | Cache hit after line installation |
| `C_WRITE_01` | Cache write behavior |
| `C_WRITE_02` | Partial or allocated write behavior |
| `C_BACKPRESSURE_01` | Memory request backpressure |
| `C_BACKPRESSURE_02` | CPU response backpressure |
| `C_EVICT_01` | Dirty writeback |
| `C_EVICT_02` | Complete dirty eviction followed by refill |

The central dirty-eviction path `C_EVICT_02` was reached at step 24.

---

## 7. Fault-Injection Plan

### Fault 1: Incorrect writeback address

Injected modification:

```text
Use req_tag instead of tag_array[req_index]
```

Expected detection:

```text
Assertion: A_EVICT_01_ADDR
Expected result: FAIL
Observed failure step: 9
```

### Fault 2: WSTRB ignored

Injected modification:

```text
Replace the complete cache word with req_wdata_reg
```

Expected detection:

```text
Assertion: F_DATA_02
Expected result: FAIL
Observed failure step: 9
```

The correct RTL remains unchanged because faults are stored in separate
formal-only copies.

---

## 8. Proof-Closure Criteria

The project is considered closed when:

- Verilator lint passes
- all ten directed simulation scenarios pass
- unbounded control and protocol proof passes
- bounded symbolic data proof passes through depth 22
- all required formal covers are reached
- both injected faults produce the expected assertion failures
- assumptions and abstractions are documented
- generated proof directories are excluded from Git
- the repository can reproduce the results using the Makefile

---

## 9. Reproduction Commands

Run individual checks:

```bash
make lint
make sim
make formal
make data
make cover
make faults
```

Run the complete correct-design regression:

```bash
make regression
```

Remove generated verification artifacts:

```bash
make clean
```