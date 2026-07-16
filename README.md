# Formal Verification Portfolio

A collection of RTL design and formal verification projects focused on digital design, ASIC verification, protocol correctness, assertions, counterexample analysis, and proof closure.

## Projects

### 1. AXI4-Lite Formal Protocol Checker and Register Slave

A SystemVerilog AXI4-Lite register slave verified using simulation and open-source formal verification tools.

Demonstrates:

- SystemVerilog RTL design
- AXI4-Lite ready/valid protocol handling
- Independent address and data channels
- Backpressure support
- Outstanding transaction tracking
- SystemVerilog assertions
- Formal assumptions and cover properties
- Register reference modeling
- WSTRB verification
- Counterexample debugging
- Assumption and vacuity auditing
- Proof closure

[View the AXI4-Lite project](./axi4lite-formal/)

### 2. Formal Verification of a Direct-Mapped Cache Controller

A SystemVerilog direct-mapped, write-back cache controller verified using directed simulation and open-source formal verification tools.

Demonstrates:

* SystemVerilog RTL design
* Direct-mapped cache architecture
* Tag, index, and byte-offset decomposition
* Read and write hit handling
* Write-back and write-allocate policies
* Partial-byte writes using WSTRB
* Clean and dirty conflict misses
* Dirty cache-line eviction and memory writeback
* Refill sequencing
* CPU and memory ready/valid interfaces
* Backpressure handling
* SystemVerilog assertions
* Symbolic tracked-address data modeling
* Bounded data-integrity verification
* Unbounded control and protocol safety proofs
* Formal cover properties and vacuity analysis
* Counterexample-driven debugging
* Fault injection and proof closure
* Automated lint, simulation, proof, and cover workflows using Make

[View the cache controller project](./formal-cache-controller/)


## Toolchain

- Yosys
- SymbiYosys
- Boolector
- Verilator
- Icarus Verilog
- GTKWave
- SystemVerilog
- Python
- Make

## Purpose

This repository is being developed as a hardware verification portfolio for Formal Verification Engineer, ASIC Verification, and RTL Verification roles.
