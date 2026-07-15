# Direct-Mapped Write-Back Cache Controller — Architecture

## 1. Purpose

This project implements a small blocking cache controller intended for RTL simulation and formal verification.

The controller sits between:

* A CPU-side ready/valid request-response interface
* A memory-side ready/valid request-response interface

The design supports read and write requests, cache hits, cache misses, write allocation, dirty eviction, memory writeback, refill, and backpressure.

The architecture is intentionally small. Verification depth, reproducibility, and proof quality are prioritized over feature expansion.

---

## 2. Fixed Configuration

| Parameter                   |               Value |
| --------------------------- | ------------------: |
| Address width               |              8 bits |
| Data width                  |             32 bits |
| Cache lines                 |                   4 |
| Words per cache line        |                   1 |
| Placement                   |       Direct mapped |
| Write policy                |          Write-back |
| Write-miss policy           |      Write allocate |
| CPU outstanding requests    |                   1 |
| Memory outstanding requests |                   1 |
| Backpressure                |           Supported |
| CPU address alignment       | 32-bit word aligned |

The cache is blocking. It accepts no new CPU request while another CPU transaction is active.

---

## 3. Address Decomposition

CPU and memory addresses are 8-bit byte addresses.

```text
Address: [7:4] [3:2] [1:0]
          Tag   Index Offset
```

| Field       | Bits    |  Width | Meaning                                                 |
| ----------- | ------- | -----: | ------------------------------------------------------- |
| Tag         | `[7:4]` | 4 bits | Identifies which memory word occupies the selected line |
| Index       | `[3:2]` | 2 bits | Selects one of four cache lines                         |
| Byte offset | `[1:0]` | 2 bits | Selects a byte within the 32-bit word                   |

Supported CPU addresses must be word aligned:

```systemverilog
cpu_req_addr[1:0] == 2'b00
```

Example:

```text
0x04 = tag 0000, index 01, offset 00
0x44 = tag 0100, index 01, offset 00
```

These addresses conflict because they have the same index but different tags.

---

## 4. Cache-Line Organization

Each cache line contains:

```text
Valid bit
Dirty bit
Tag
32-bit data word
```

Expected RTL storage:

```systemverilog
logic [NUM_LINES-1:0] valid_array;
logic [NUM_LINES-1:0] dirty_array;

logic [TAG_WIDTH-1:0]  tag_array  [0:NUM_LINES-1];
logic [DATA_WIDTH-1:0] data_array [0:NUM_LINES-1];
```

The fundamental cache invariant is:

```text
Dirty implies valid.
```

A line with `valid == 0` contains no usable cache entry. Its tag and data fields must not be used to produce a hit.

---

## 5. Reset Behavior

Reset is active-low through `rst_n`.

When reset is asserted:

* The FSM returns to `IDLE`.
* Every valid bit is cleared.
* Every dirty bit is cleared.
* No CPU response is pending.
* No memory request is pending.
* No CPU transaction is active.
* No memory transaction is outstanding.

The tag and data arrays do not need to be reset. Their contents are irrelevant while the corresponding valid bit is zero.

---

## 6. CPU-Side Protocol

### 6.1 Request Channel

A CPU request is accepted when:

```systemverilog
cpu_req_valid && cpu_req_ready
```

The cache asserts `cpu_req_ready` only when it can accept a new request.

Because the cache supports only one active CPU transaction, `cpu_req_ready` is normally asserted only in `IDLE`.

On the request handshake, the cache captures:

* `cpu_req_write`
* `cpu_req_addr`
* `cpu_req_wdata`
* `cpu_req_wstrb`

These captured fields remain unchanged until the transaction completes.

The CPU may remove or change its input request signals after the handshake because the cache operates from the captured request registers.

### 6.2 Response Channel

A CPU response is consumed when:

```systemverilog
cpu_rsp_valid && cpu_rsp_ready
```

For a read request:

```text
cpu_rsp_rdata = requested word
```

For a write request, the response indicates completion. The implementation will drive:

```text
cpu_rsp_rdata = 32'h00000000
```

while completing a write.

When `cpu_rsp_valid == 1` and `cpu_rsp_ready == 0`, the cache must hold the following stable:

* `cpu_rsp_valid`
* `cpu_rsp_rdata`

No new CPU request may be accepted while a response is pending.

---

## 7. Memory-Side Protocol

The cache sends one memory request at a time.

A memory request is accepted when:

```systemverilog
mem_req_valid && mem_req_ready
```

The request type is selected by `mem_req_write`:

```text
mem_req_write = 0: refill read
mem_req_write = 1: dirty-line writeback
```

For a refill read:

* `mem_req_addr` contains the requested CPU word address.
* `mem_req_wdata` is not functionally relevant.

For a dirty writeback:

* `mem_req_addr` contains the reconstructed victim address.
* `mem_req_wdata` contains the victim cache-line data.

When `mem_req_valid == 1` and `mem_req_ready == 0`, all memory request fields must remain stable:

* `mem_req_valid`
* `mem_req_write`
* `mem_req_addr`
* `mem_req_wdata`

Every accepted memory request eventually produces one response.

A memory response is consumed when:

```systemverilog
mem_rsp_valid && mem_rsp_ready
```

Both reads and writes produce a response:

* For a read, `mem_rsp_rdata` contains refill data.
* For a write, `mem_rsp_rdata` is ignored.

The design must not assume that memory is always ready or that a response arrives after a fixed number of cycles.

---

## 8. Lookup and Hit Detection

After capturing a CPU request, the cache extracts:

```systemverilog
request_tag   = request_addr[7:4];
request_index = request_addr[3:2];
```

A cache hit occurs only when:

```systemverilog
valid_array[request_index] &&
tag_array[request_index] == request_tag
```

An invalid line cannot produce a hit, even if its uninitialized or stale tag happens to equal the requested tag.

A miss occurs when:

```text
valid bit is zero
```

or:

```text
valid bit is one but the stored tag differs from the requested tag
```

---

## 9. Read-Hit Behavior

On a read hit:

1. Read `data_array[request_index]`.
2. Store that value in the CPU response register.
3. Assert `cpu_rsp_valid`.
4. Transition to `RESPOND`.
5. Do not issue a memory request.
6. Do not modify valid, dirty, tag, or data state.

If the CPU stalls the response, the response data remains stable until accepted.

---

## 10. Write-Hit Behavior

On a write hit, the cache modifies only byte lanes enabled by `cpu_req_wstrb`.

For byte lane `i`:

```systemverilog
if (request_wstrb[i])
    updated_data[i*8 +: 8] = request_wdata[i*8 +: 8];
else
    updated_data[i*8 +: 8] = old_data[i*8 +: 8];
```

After the update:

* The selected line remains valid.
* The selected line keeps the same tag.
* The selected line becomes dirty.
* Disabled byte lanes retain their previous values.
* No memory request is issued immediately.
* A CPU write-completion response is generated.

This is write-back behavior: modified data remains in the cache until the dirty line is evicted.

---

## 11. Invalid or Clean Miss

A miss does not require writeback when the selected victim line is:

* Invalid, or
* Valid but clean

The sequence is:

1. Issue a memory read request for the requested word address.
2. Hold the request stable until memory accepts it.
3. Wait for the memory response.
4. Install the returned word into the indexed cache line.
5. Install the requested tag.
6. Set valid.
7. Clear dirty.
8. Complete the original CPU operation.

### 11.1 Read Miss Completion

For an original CPU read:

* Return the refill data to the CPU.
* Leave the installed line clean.

### 11.2 Write Miss Completion

For an original CPU write:

1. Refill the complete word from memory.
2. Apply the captured CPU `WSTRB` operation to the refill data.
3. Install the merged result in the cache.
4. Set the line dirty.
5. Return a write-completion response.

This is write allocation because a write miss first allocates the requested line in the cache.

---

## 12. Dirty Conflict Miss

A dirty conflict miss occurs when:

* The selected line is valid.
* The selected line is dirty.
* The selected line's tag differs from the requested tag.

The existing line must be written back before it can be replaced.

### 12.1 Victim Address Reconstruction

The victim address is reconstructed from:

* The stored victim tag
* The index of the incoming request
* A zero byte offset

```systemverilog
victim_addr = {
    tag_array[request_index],
    request_index,
    2'b00
};
```

The writeback address must use the stored victim tag. It must not use the incoming request tag.

### 12.2 Dirty-Eviction Sequence

The complete sequence is:

1. Detect the dirty conflict miss.
2. Issue a memory write request using the victim address.
3. Send the victim cache data as `mem_req_wdata`.
4. Hold the writeback request stable until accepted.
5. Wait for the memory write acknowledgement.
6. Only after the acknowledgement, issue the refill read request.
7. Wait for refill data.
8. Install the requested tag and returned data.
9. Set valid.
10. Complete the original CPU read or write.
11. Return a CPU response.

The victim line must not be overwritten before writeback acknowledgement.

---

## 13. Finite-State Machine

The controller uses the following states:

```systemverilog
typedef enum logic [2:0] {
    IDLE,
    LOOKUP,
    WRITEBACK_REQ,
    WRITEBACK_WAIT,
    REFILL_REQ,
    REFILL_WAIT,
    RESPOND
} cache_state_t;
```

### 13.1 `IDLE`

Responsibilities:

* Assert `cpu_req_ready`.
* Wait for a CPU request handshake.
* Capture the complete CPU request.
* Transition to `LOOKUP`.

No CPU transaction is active before the handshake.

### 13.2 `LOOKUP`

Responsibilities:

* Extract the request tag and index.
* Determine hit or miss.
* On read hit, prepare the read response.
* On write hit, update the selected cache line.
* On invalid or clean miss, transition to `REFILL_REQ`.
* On dirty conflict miss, transition to `WRITEBACK_REQ`.

### 13.3 `WRITEBACK_REQ`

Responsibilities:

* Assert `mem_req_valid`.
* Set `mem_req_write = 1`.
* Drive the reconstructed victim address.
* Drive the victim data.
* Hold all request fields stable under backpressure.
* Transition to `WRITEBACK_WAIT` after the request handshake.

### 13.4 `WRITEBACK_WAIT`

Responsibilities:

* Assert readiness to receive the write acknowledgement.
* Preserve the victim cache line until acknowledgement.
* Transition to `REFILL_REQ` only after the memory response handshake.

### 13.5 `REFILL_REQ`

Responsibilities:

* Assert `mem_req_valid`.
* Set `mem_req_write = 0`.
* Drive the captured CPU request address.
* Hold the refill request stable under backpressure.
* Transition to `REFILL_WAIT` after the request handshake.

### 13.6 `REFILL_WAIT`

Responsibilities:

* Wait for refill data.
* Install the requested tag.
* Install or merge the returned data.
* Set valid.
* Set dirty according to the original CPU operation.
* Prepare the CPU response.
* Transition to `RESPOND`.

For a read miss, the refill data is returned directly.

For a write miss, the refill data is merged with the captured CPU write data according to the captured strobes.

### 13.7 `RESPOND`

Responsibilities:

* Assert `cpu_rsp_valid`.
* Hold the CPU response stable under backpressure.
* Wait for the CPU response handshake.
* Return to `IDLE` after the response is accepted.

---

## 14. Backpressure Requirements

The cache supports independent backpressure on:

* CPU requests
* CPU responses
* Memory requests
* Memory responses

The design must not assume:

* The CPU immediately accepts a response.
* Memory immediately accepts a request.
* Memory responds in a fixed number of cycles.

Pending output-channel payloads must remain stable until their respective ready/valid handshake occurs.

---

## 15. Outstanding-Transaction Rules

The cache permits:

* At most one active CPU transaction
* At most one accepted but incomplete memory request

A new CPU request cannot be accepted until the prior CPU response is consumed.

A refill request cannot be issued while a writeback request is still awaiting acknowledgement.

---

## 16. Design Limitations

This project intentionally does not implement:

* Set associativity
* Multiple words per line
* Burst transactions
* Multiple outstanding CPU requests
* Multiple outstanding memory requests
* Request pipelining
* Cache coherence
* Replacement policies such as LRU
* ECC
* Prefetching
* Multiple cache levels
* Unaligned CPU accesses
* Sub-word CPU accesses as independent operations

`WSTRB` supports partial-byte modification of an aligned 32-bit cache word, but every request address remains word aligned.

These limitations are intentional and keep the controller small enough for exhaustive formal reasoning.
