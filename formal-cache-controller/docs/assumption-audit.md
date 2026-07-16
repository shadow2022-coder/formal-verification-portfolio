# Formal Assumption and Abstraction Audit

## 1. Purpose

Formal verification explores every input sequence permitted by the formal
harness. Assumptions restrict the environment to legal interface behavior or
documented proof abstractions.

An assumption must not force the expected result or hide an RTL defect.

---

## 2. Control and Protocol Proof

Configuration:

```text
File: formal/cache.sby
Mode: prove
Engine: ABC PDR
Result: unbounded safety proof
```

### Reset assumption

The cache begins in reset:

```systemverilog
if ($initstate)
    assume(!rst_n);
else
    assume(rst_n);
```

This ensures that the FSM, valid bits, dirty bits, request state, and response
state begin from a defined architectural state.

The assumption does not force a hit, miss, refill, writeback, or response.

### Address-alignment assumption

```systemverilog
assume(cpu_req_addr[1:0] == 2'b00);
```

The cache supports one 32-bit word per line and does not implement unaligned
accesses. Therefore, CPU addresses must be word aligned.

The address tag and index remain symbolic.

### Symbolic environment

The formal environment may choose arbitrary values and timing for:

- CPU read or write requests
- CPU request addresses
- CPU write data
- CPU byte strobes
- CPU request timing
- CPU response backpressure
- Memory request backpressure
- Memory response timing
- Memory response data

This allows exploration of hits, misses, refills, dirty evictions, writebacks,
partial writes, and interface stalls.

### Liveness limitation

The main proof checks safety properties.

It does not claim that every transaction eventually completes under a fully
unconstrained environment. For example, memory could hold `mem_req_ready` low
forever unless a fairness assumption were added.

---

## 3. Bounded Symbolic Data-Integrity Proof

Configuration:

```text
File: formal/cache_data.sby
Mode: BMC
Depth: 22 cycles
Engine: ABC BMC3
Result: bounded symbolic data-integrity proof
```

The symbolic data proof is separated from the unbounded control proof because
32-bit symbolic values, cache arrays, byte strobes, memory behavior, and
backpressure create a much larger SAT problem.

### Symbolic tracked address

The proof selects an arbitrary address:

```systemverilog
(* anyconst *) logic [ADDR_WIDTH-1:0] f_addr_symbol;
```

The tracked address is word aligned, but its tag and index remain arbitrary.

This means the model is not limited to one manually selected address.

### Symbolic initial memory value

```systemverilog
(* anyconst *) logic [DATA_WIDTH-1:0] f_initial_memory_data;
```

The initial value at the tracked address is arbitrary. The proof therefore
does not depend on memory initially containing zero or another convenient
constant.

### One-address memory abstraction

The formal model tracks the architectural memory value for one arbitrary
address.

Requests to other addresses can still cause cache conflicts and eviction, but
the model does not construct a complete reference memory for every possible
address.

The abstraction focuses on the main data-integrity question:

```text
Does a read of the tracked address return the most recently expected value,
including partial-byte writes and dirty writeback?
```

### Data-proof progress assumptions

The bounded data proof assumes:

```systemverilog
assume(mem_req_ready);
assume(cpu_rsp_ready);
assume(mem_rsp_valid);
```

Backpressure behavior is verified separately by the control assertions and
cover properties.

These assumptions remove unrelated waiting cycles from the expensive symbolic
data proof. They do not choose:

- the tracked address
- initial memory data
- CPU write data
- CPU byte strobes
- hit or miss behavior
- conflicting cache tags

### Memory-interface assumptions

The abstract memory model assumes:

- a second memory request is not accepted while one is outstanding;
- an accepted memory response corresponds to an outstanding request;
- a read response for the tracked address returns the tracked architectural
  memory value.

These assumptions model the contract of the single-outstanding memory
interface.

---

## 4. Symbolic Data Assertions

### `F_DATA_01`

A completed CPU read of the tracked address returns the expected tracked value.

### `F_DATA_02`

When the tracked address is resident in the cache, the cache-line data equals
the expected tracked value.

This property includes partial-byte updates controlled by `WSTRB`.

### `F_DATA_03`

A dirty writeback to the tracked address contains the complete expected tracked
value.

---

## 5. Vacuity Prevention

Formal cover properties demonstrate that important cache behaviors are
reachable under the assumptions.

Covered scenarios include:

- cache miss
- refill
- cache hit
- write hit
- write allocation
- memory request backpressure
- CPU response backpressure
- dirty eviction
- writeback followed by refill

The central dirty-eviction sequence, `C_EVICT_02`, was reached at formal step
24.

These cover results reduce the risk that assertions pass only because relevant
states are unreachable.

---

## 6. Verified Claims

The project claims:

- unbounded safety proof for the implemented control and protocol properties;
- 22-cycle bounded symbolic data-integrity verification;
- formal reachability of the required cache scenarios;
- directed simulation of ten functional and backpressure scenarios;
- detection of two intentionally injected RTL defects.

---

## 7. Proof Boundaries

The project does not claim:

- an unbounded proof of every possible data sequence;
- cache coherence;
- multiple outstanding CPU or memory requests;
- multiword cache lines;
- unaligned access support;
- replacement-policy verification;
- unconditional transaction completion without fairness assumptions.