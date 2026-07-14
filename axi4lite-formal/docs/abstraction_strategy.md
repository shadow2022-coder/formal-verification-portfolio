# Abstraction Strategy

## Reduced Address Width

The project uses a four-bit address instead of a full system address bus.

This retains all relevant register-decoding behavior while reducing the
formal state space.

## Reduced Register Count

Only four registers are implemented.

This is sufficient to prove:

- Address decoding
- Register isolation
- Read correctness
- Write correctness
- Invalid-address behavior

## Symbolic Inputs

Formal verification treats the following as symbolic:

- Write address
- Write data
- Write strobe
- Read address
- VALID timing
- READY timing

This allows the solver to explore arbitrary legal transactions.

## Single Outstanding Transaction

The first version supports:

- One outstanding write
- One outstanding read

This simplifies transaction tracking and proof closure while preserving
the main AXI4-Lite protocol challenges.

## Reference Model

A separate formal reference model tracks the expected register contents.

The DUT registers are continuously compared against this model.

This separates:

- Protocol-control proofs
- Register-functional proofs

## Assume-Guarantee Reasoning

The master guarantees legal READY/VALID behavior through assumptions.

The slave guarantees:

- Stable responses during stalls
- Correct transaction accounting
- Correct register functionality
- Correct response generation

## Arbitrary Transaction Tracking

Formal scoreboards track accepted write-address, write-data, write-response,
read-address, and read-response events.

This proves that transactions are neither lost nor duplicated.