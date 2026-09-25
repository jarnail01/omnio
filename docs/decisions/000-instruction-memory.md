# Instruction Memory

## Context and Problem Statement

Choose storage for a small programmable instruction memory.
Need to decide what actually stores the data bits and how do modules access the data?

1. In order to emulate full-duplex protocols, the device needs to be able to run at least 2 programs at the same time (one for receiving data and one for transmitting data). 1 program for each of the 4 cores is the goal.
2. Target capacity: 32 words x 16 bits = 512 bits of data
3. One instruction fetch per core per clock cycle

## Considered Options

| Option | Benefits | Disadvantages / risks | Meets hard requirements? |
| --- | --- | --- | --- |
| Flop array + 4 read multiplexers | Easy to implement | High power - clock and mux switching. High area. | Unknown, measure power and area |
| Single SRAM macro | Low area, low power | Single read port, need to arbitrate, each core gets 1/4 of max clock rate | No |
| Replicated SRAM macro | More throughput than single SRAM | High area, high power | Unknown, possible if macros exist |
| Banked SRAM | | | |

## Decision Outcome

Chosen option: "{title of option 1}", because {justification. e.g., only option, which meets k.o. criterion decision driver | which resolves force {force} | … | comes out best (see below)}.

### Consequences

* Good, because {positive consequence, e.g., improvement of one or more desired qualities, …}
* Bad, because {negative consequence, e.g., compromising one or more desired qualities, …}
