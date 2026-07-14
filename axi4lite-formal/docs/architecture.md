# AXI4-Lite Register Slave Architecture

## Overview

This project implements a small AXI4-Lite slave containing four 32-bit
registers.

| Address | Register |
|---|---|
| `0x0` | CONTROL |
| `0x4` | STATUS |
| `0x8` | DATA0 |
| `0xC` | DATA1 |

All other addresses return `SLVERR`.

## AXI4-Lite Channels

The design supports five independent channels:

- Write address: `AWVALID`, `AWREADY`, `AWADDR`
- Write data: `WVALID`, `WREADY`, `WDATA`, `WSTRB`
- Write response: `BVALID`, `BREADY`, `BRESP`
- Read address: `ARVALID`, `ARREADY`, `ARADDR`
- Read response: `RVALID`, `RREADY`, `RDATA`, `RRESP`

A transfer occurs when both `VALID` and `READY` are high on a rising
clock edge.

## Write Architecture

The write address and write data may arrive independently.

The slave stores them using:

- `aw_pending` and `awaddr_hold`
- `w_pending`, `wdata_hold`, and `wstrb_hold`

The register update occurs only after both components have been accepted.

The slave supports one outstanding write transaction. It does not accept
another write while `BVALID` is active.

## Read Architecture

A read address is accepted when no previous read response is outstanding.

The address is decoded and the selected register value is stored in
`RDATA`. `RVALID`, `RDATA`, and `RRESP` remain stable until the master
asserts `RREADY`.

## Byte Write Strobes

Each `WSTRB` bit controls one byte:

| Strobe | Register bits |
|---|---|
| `WSTRB[0]` | `[7:0]` |
| `WSTRB[1]` | `[15:8]` |
| `WSTRB[2]` | `[23:16]` |
| `WSTRB[3]` | `[31:24]` |

Bytes with a disabled strobe remain unchanged.

## Reset

`aresetn` is an active-low synchronous reset.

Reset clears:

- All four registers
- Pending write state
- Write-response state
- Read-response state

## Limitations

- One outstanding write transaction
- One outstanding read transaction
- No AXI bursts
- No AXI transaction IDs
- Four-bit reduced address width