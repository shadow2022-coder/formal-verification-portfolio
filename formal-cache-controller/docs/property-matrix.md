# Formal Property Matrix

## 1. Purpose

This document maps each formal property to the cache behavior it checks.

The properties are divided into:

- control and protocol assertions;
- hit, miss, refill, and eviction assertions;
- symbolic data-integrity assertions;
- formal environment assumptions;
- formal cover properties.

---

## 2. Reset and Global Invariants

| Property | Type | Requirement |
|---|---|---|
| `A_RST_01` | Assert | The controller returns to the required reset state. |
| `A_RST_02` | Assert | Cache metadata is cleared or inactive after reset. |
| `A_INV_01` | Assert | A dirty cache line must also be valid. |

Fundamental invariant:

```text
dirty_array[index] -> valid_array[index]
```

A dirty invalid line would represent architecturally inconsistent cache state.

---

## 3. Hit Detection Properties

| Property | Type | Requirement |
|---|---|---|
| `A_HIT_01` | Assert | A reported cache hit requires a valid selected line with a matching tag. |
| `A_HIT_02` | Assert | A cache hit must not generate an unnecessary memory request. |
| `A_HIT_03_VALID` | Assert | After a completed hit transaction, the selected cache line remains valid. |
| `A_HIT_03_DIRTY` | Assert | A read hit does not incorrectly change the dirty state. |
| `A_HIT_03_TAG` | Assert | A read hit does not modify the selected line tag. |
| `A_HIT_03_DATA` | Assert | A read hit preserves the stored cache-line data. |
| `A_HIT_04_RESPONSE_VALID` | Assert | A read hit generates a valid CPU response. |
| `A_HIT_04_RESPONSE_DATA` | Assert | A read-hit response contains the selected cache-line data. |

A hit is defined as:

```systemverilog
selected_valid && selected_tag == req_tag
```

A stale tag in an invalid line must never produce a hit.

---

## 4. CPU Request and Response Properties

| Property | Type | Requirement |
|---|---|---|
| `A_CPU_01_VALID` | Assert | The controller presents a valid CPU response in the response state. |
| `A_CPU_01_DATA` | Assert | CPU response data matches the internally stored response value. |
| `A_CPU_02` | Assert | CPU response validity remains asserted while the response is stalled. |
| `A_CPU_03` | Assert | CPU response data remains stable while `cpu_rsp_ready` is low. |
| `A_CPU_04_WRITE` | Assert | The captured CPU request type remains stable while processing the transaction. |
| `A_CPU_04_ADDR` | Assert | The captured CPU address remains stable while processing the transaction. |
| `A_CPU_04_DATA` | Assert | The captured CPU write data remains stable while processing the transaction. |
| `A_CPU_04_WSTRB` | Assert | The captured CPU byte strobes remain stable while processing the transaction. |

CPU request handshake:

```systemverilog
cpu_req_valid && cpu_req_ready
```

CPU response handshake:

```systemverilog
cpu_rsp_valid && cpu_rsp_ready
```

The CPU may change its input request signals after the request handshake because
the controller must operate from its captured request registers.

---

## 5. Memory Request and Response Properties

| Property | Type | Requirement |
|---|---|---|
| `A_MEM_01_VALID` | Assert | A pending memory request keeps `mem_req_valid` asserted until accepted. |
| `A_MEM_01_WRITE` | Assert | Memory request type remains stable under backpressure. |
| `A_MEM_01_ADDR` | Assert | Memory request address remains stable under backpressure. |
| `A_MEM_01_DATA` | Assert | Memory write data remains stable under backpressure. |
| `A_MEM_02` | Assert | Memory request control remains stable while the request is stalled. |
| `A_MEM_03` | Assert | Memory request payload remains stable while the request is stalled. |

Memory request handshake:

```systemverilog
mem_req_valid && mem_req_ready
```

Memory response handshake:

```systemverilog
mem_rsp_valid && mem_rsp_ready
```

The design permits only one outstanding memory transaction.

---

## 6. Miss Properties

| Property | Type | Requirement |
|---|---|---|
| `A_MISS_01` | Assert | The controller must not generate an early CPU response while a miss is unresolved. |

A cache miss occurs when:

```text
selected line is invalid
```

or:

```text
selected line is valid but its tag does not match the request tag
```

A miss must be resolved through refill, with dirty writeback first when required.

---

## 7. Dirty-Eviction Properties

| Property | Type | Requirement |
|---|---|---|
| `A_EVICT_01_VALID` | Assert | The controller asserts a memory request during dirty writeback. |
| `A_EVICT_01_WRITE` | Assert | The dirty-eviction memory request is a write. |
| `A_EVICT_01_ADDR` | Assert | The writeback address uses the stored victim tag, conflicting index, and zero byte offset. |
| `A_EVICT_01_DATA` | Assert | The writeback data equals the dirty victim cache-line data. |
| `A_EVICT_02` | Assert | Refill begins only after the dirty writeback has completed. |
| `A_EVICT_03_READY` | Assert | The controller is ready to accept the writeback response while waiting for it. |
| `A_EVICT_03_NO_REQUEST` | Assert | The controller does not issue a second memory request while waiting for the writeback response. |
| `A_EVICT_04_VALID` | Assert | The victim line remains valid while dirty writeback is in progress. |
| `A_EVICT_04_DIRTY` | Assert | The victim line remains dirty until writeback completes. |
| `A_EVICT_04_TAG` | Assert | The victim tag remains stable while writeback is in progress. |
| `A_EVICT_04_DATA` | Assert | The victim data remains stable while writeback is in progress. |

Correct dirty-victim address reconstruction:

```systemverilog
mem_req_addr = {
    tag_array[req_index],
    req_index,
    {OFFSET_WIDTH{1'b0}}
};
```

The stored victim tag must be used rather than the incoming request tag.

---

## 8. Refill Properties

| Property | Type | Requirement |
|---|---|---|
| `A_REFILL_01_VALID` | Assert | The controller asserts a memory request during refill request state. |
| `A_REFILL_01_READ` | Assert | A refill request is a memory read. |
| `A_REFILL_01_ADDR` | Assert | The refill request address equals the captured CPU request address. |
| `A_REFILL_02` | Assert | The controller asserts memory-response ready while waiting for refill data. |
| `A_REFILL_03_VALID` | Assert | Refill completion installs a valid cache line. |
| `A_REFILL_03_TAG` | Assert | Refill completion installs the requested tag. |
| `A_REFILL_03_RESPONSE_VALID` | Assert | Refill completion produces a valid CPU response. |
| `A_REFILL_04_WRITE_DIRTY` | Assert | A write-allocate refill marks the installed line dirty. |
| `A_REFILL_04_WRITE_DATA` | Assert | A write-allocate refill merges CPU write data using byte strobes. |
| `A_REFILL_04_WRITE_RESPONSE` | Assert | A completed write allocation returns the defined write response. |
| `A_REFILL_05_READ_CLEAN` | Assert | A read refill installs a clean cache line. |
| `A_REFILL_05_READ_DATA` | Assert | A read refill stores the returned memory data in the selected line. |
| `A_REFILL_05_READ_RESPONSE` | Assert | A read refill returns the memory data to the CPU. |

Read-miss refill:

```text
memory data -> cache line -> CPU response
```

Write-miss allocation:

```text
memory data + CPU WSTRB update -> dirty cache line
```

---

## 9. Write-Hit Properties

| Property | Type | Requirement |
|---|---|---|
| `A_WRITE_01_VALID` | Assert | A write hit preserves a valid selected cache line. |
| `A_WRITE_02_TAG` | Assert | A write hit preserves the selected cache-line tag. |
| `A_WRITE_03_DIRTY` | Assert | A write hit marks the selected line dirty. |
| `A_WRITE_04_DATA` | Assert | A write hit updates only bytes enabled by `req_wstrb_reg`. |
| `A_WRITE_05_RESPONSE_VALID` | Assert | A completed write hit generates a CPU response. |
| `A_WRITE_05_RESPONSE_DATA` | Assert | A completed write hit returns the defined write-response data. |

Expected byte merge:

```systemverilog
new_value = apply_wstrb(
    old_value,
    req_wdata_reg,
    req_wstrb_reg
);
```

For every strobe bit:

```text
WSTRB bit = 1 -> replace corresponding byte
WSTRB bit = 0 -> preserve corresponding byte
```

---

## 10. Symbolic Data-Integrity Assertions

These properties are located in `rtl/cache_controller.sv` under the
`FORMAL_DATA` configuration.

| Property | Type | Requirement |
|---|---|---|
| `F_DATA_01` | Assert | A CPU read response for the tracked symbolic address equals the expected architectural value. |
| `F_DATA_02` | Assert | When the tracked address is resident, the selected cache-line data equals the expected value. |
| `F_DATA_03` | Assert | A writeback to the tracked address contains the complete expected value. |

The expected value is updated symbolically using:

- arbitrary initial memory data;
- arbitrary CPU write data;
- arbitrary CPU byte strobes;
- refill behavior;
- dirty writeback behavior.

These assertions are checked using bounded model checking.

---

## 11. Data-Proof Environment Assumptions

| Property | Type | Requirement or abstraction |
|---|---|---|
| `F_DATA_FAST_01` | Assume | Memory requests are immediately accepted during the data-only proof. |
| `F_DATA_FAST_02` | Assume | CPU responses are immediately accepted during the data-only proof. |
| `F_DATA_FAST_03` | Assume | Memory responses are made available without arbitrary waiting cycles. |
| `F_DATA_ASSUME_01` | Assume | The abstract memory interface does not accept an illegal second outstanding request. |
| `F_DATA_ASSUME_02` | Assume | A consumed memory response corresponds to an outstanding request. |
| `F_DATA_ASSUME_03` | Assume | A tracked-address memory read returns the tracked abstract memory value. |

The `F_DATA_FAST_*` assumptions are proof-performance abstractions.

Backpressure safety is verified separately in the unbounded control proof and
formal cover run.

---

## 12. Formal Cover Matrix

| Cover | Behavior demonstrated |
|---|---|
| `C_MISS_01` | A basic cache miss is reachable. |
| `C_REFILL_01` | A memory refill is reachable. |
| `C_HIT_01` | A cache hit after line installation is reachable. |
| `C_WRITE_01` | Cache write behavior is reachable. |
| `C_WRITE_02` | Partial-write or write-allocation behavior is reachable. |
| `C_MISS_02` | A conflicting-tag miss is reachable. |
| `C_EVICT_01` | A dirty writeback is reachable. |
| `C_BACKPRESSURE_01` | Memory request backpressure is reachable. |
| `C_BACKPRESSURE_02` | CPU response backpressure is reachable. |
| `C_EVICT_02` | A complete dirty eviction followed by refill is reachable. |
| `C_DATA_01` | The tracked symbolic data scenario involving write, eviction, and reread is reachable. |

Observed cover depths from the main cover run include:

| Cover | Reached step |
|---|---:|
| `C_MISS_01` | 4 |
| `C_BACKPRESSURE_01` | 6 |
| `C_REFILL_01` | 8 |
| `C_BACKPRESSURE_02` | 10 |
| `C_HIT_01` | 14 |
| `C_MISS_02` | 14 |
| `C_EVICT_01` | 14 |
| `C_WRITE_01` | 14 |
| `C_WRITE_02` | 14 |
| `C_EVICT_02` | 24 |

---

## 13. Fault-Injection Detection Matrix

| Injected fault | Expected failing property | Observed step |
|---|---|---:|
| Writeback uses `req_tag` instead of the victim tag | `A_EVICT_01_ADDR` | 9 |
| Write hit overwrites the complete word and ignores `WSTRB` | `F_DATA_02` | 9 |

The intentional failures demonstrate that the property suite can detect both
control/addressing corruption and data-path corruption.

---

## 14. Proof Classification

| Property group | Proof method |
|---|---|
| Reset, invariants, protocol, hit, miss, refill, and eviction assertions | Unbounded ABC PDR safety proof |
| `F_DATA_01`, `F_DATA_02`, and `F_DATA_03` | 22-cycle bounded symbolic data proof |
| `C_*` reachability properties | 50-cycle SMTBMC cover analysis |
| Intentional bug properties | Bounded counterexample generation |

The bounded data result must not be presented as an unbounded proof.

---

## 15. Summary

The property set verifies:

- reset correctness;
- cache metadata invariants;
- ready/valid stability;
- captured-request stability;
- hit and miss classification;
- write-hit byte merging;
- clean and dirty miss sequencing;
- victim-address reconstruction;
- refill installation;
- response correctness;
- symbolic tracked-address data integrity;
- reachability of important functional paths;
- detection of intentionally injected RTL bugs.