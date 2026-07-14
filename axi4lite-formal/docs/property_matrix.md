# Property Matrix

| Area | Property | Type |
|---|---|---|
| AW | `AWVALID` remains asserted while stalled | Assumption |
| AW | `AWADDR` remains stable while stalled | Assumption |
| W | `WVALID` remains asserted while stalled | Assumption |
| W | `WDATA` remains stable while stalled | Assumption |
| W | `WSTRB` remains stable while stalled | Assumption |
| AR | `ARVALID` remains asserted while stalled | Assumption |
| AR | `ARADDR` remains stable while stalled | Assumption |
| B | `BVALID` remains asserted while stalled | Assertion |
| B | `BRESP` remains stable while stalled | Assertion |
| R | `RVALID` remains asserted while stalled | Assertion |
| R | `RDATA` remains stable while stalled | Assertion |
| R | `RRESP` remains stable while stalled | Assertion |
| Write | No response without a complete request | Assertion |
| Write | No write component accepted twice | Assertion |
| Write | At most one outstanding response | Assertion |
| Read | No response without an accepted request | Assertion |
| Read | At most one outstanding read | Assertion |
| Registers | Correct address decoding | Assertion |
| Registers | Correct `WSTRB` application | Assertion |
| Registers | Unselected bytes remain unchanged | Assertion |
| Registers | Reads match stored values | Assertion |
| Error | Invalid writes return `SLVERR` | Assertion |
| Error | Invalid reads return `SLVERR` | Assertion |
| Reset | Registers and protocol state clear | Assertion |
| Reachability | All five handshakes occur | Cover |
| Reachability | Backpressure occurs | Cover |
| Reachability | AW-before-W occurs | Cover |
| Reachability | W-before-AW occurs | Cover |
| Reachability | AW and W together occur | Cover |
| Reachability | Partial writes occur | Cover |
| Reachability | Invalid addresses occur | Cover |