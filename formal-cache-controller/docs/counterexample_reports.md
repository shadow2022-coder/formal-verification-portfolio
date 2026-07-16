# Counterexample Analysis

Two intentional RTL bugs were introduced in separate formal-only copies. The correct RTL was not modified.

## Fault 1: Wrong Dirty-Writeback Address

Fault file: formal/cache_controller_bug_wb_addr.sv

Injected bug:
The writeback address used req_tag instead of the stored victim tag.

Formal result:
- Expected result: FAIL
- Failing assertion: A_EVICT_01_ADDR
- Failure step: 9
- Trace: formal/cache_bug_wb/engine_0/trace.vcd

Root cause:
The controller wrote dirty victim data to the incoming request address instead of the evicted cache-line address.

Correct fix:
Use tag_array[req_index] when reconstructing the writeback address.

## Fault 2: Partial Write Ignores WSTRB

Fault file: formal/cache_controller_bug_wstrb.sv

Injected bug:
The write-hit logic replaced the complete 32-bit word with req_wdata_reg instead of merging only the enabled bytes.

Formal result:
- Expected result: FAIL
- Failing assertion: F_DATA_02
- Failure step: 9
- Trace: formal/cache_bug_wstrb/engine_0/trace.vcd

Root cause:
The write datapath ignored req_wstrb_reg and corrupted bytes whose strobes were zero.

Correct fix:
Use apply_wstrb with the existing data, request data, and request byte strobes.

## Conclusion

Both intentional bugs were detected within nine formal steps.
