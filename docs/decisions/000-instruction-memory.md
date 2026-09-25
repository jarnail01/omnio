# Instruction Memory

## Context and Problem Statement

Need to decide on storage for a small programmable instruction memory. Timing is critical and clock rate is limited by [Tiny Tapeout's specifications](https://tinytapeout.com/specs/clock/) to about 66 MHz at the time of writing (9/25/2026). Also, in order to emulate full-duplex protocols, a minimum of 2 concurrent programs is required. Therefore, asynchronous memory reading for each core is preferred. 

### Non-Negotiables
1. Each of the four cores must be able to asynchronously read from memory. This means they can share subroutines/code to reduce redundancy.
2. Minimum capacity: 32 words x 16 bits = 512 bits of data
3. Avoid or mitigate performance degradation. Power and area is less critical.

## Considered Options

| Option | Benefits | Disadvantages / risks | Meets hard requirements? |
| --- | --- | --- | --- |
| Flop array + 4 read multiplexers | Easy to implement | High power - clock and mux switching. High area. | Unknown, measure power and area |
| Single SRAM macro | Low area, low power | Single read port, need to arbitrate, each core gets 1/4 of max clock rate, poor performance | No |
| Replicated SRAM macro | More throughput than single SRAM | High area, high power | Unknown |
| Banked SRAM | | | |

## Decision Outcome

Chosen option: "{title of option 1}", because {justification. e.g., only option, which meets k.o. criterion decision driver | which resolves force {force} | … | comes out best (see below)}.

### Consequences

* Good, because {positive consequence, e.g., improvement of one or more desired qualities, …}
* Bad, because {negative consequence, e.g., compromising one or more desired qualities, …}

1 tile = 200 x 150 µm = 30,000 µ$m^2$
