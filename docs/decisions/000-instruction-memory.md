# Instruction Memory

## Context and Problem Statement

Choose storage for a small programmable instruction memory.
Need to decide what actually stores the data bits and how do modules access the data?

1. In order to emulate full-duplex protocols, the device needs to be able to run at least 2 programs at the same time (one for receiving data and one for transmitting data). 1 program for each of the 4 cores is the goal.
2. Target capacity: 32 words x 16 bits = 512 bits of data
3. One instruction fetch per core per clock cycle

## Considered Options

## 3. Options

| Option                           | Benefits                      | Disadvantages / risks                                             | Meets hard requirements?           |
| -------------------------------- | ----------------------------- | ----------------------------------------------------------------- | ---------------------------------- |
| Flop array + 4 read multiplexers | Fast and easy to implement.   | High power - clock and mux switching. High area.                  | Unknown, measure power and area    |
| SRAM macro                       | Low area, low power           | Single read port, would need 4 of them.                           | No                                 |
| Replicated SRAM macro            | Each core has its own memory. | Must keep copies identical. Fixed macro sizes may waste capacity. | Unknown, possible if macros exist. |
| Banked SRAM                      |                               |                                                                   |                                    |
|                                  |                               |                                                                   |                                    |


* {title of option 1}
* {title of option 2}
* {title of option 3}
* … <!-- numbers of options can vary -->

## Decision Outcome

Chosen option: "{title of option 1}", because {justification. e.g., only option, which meets k.o. criterion decision driver | which resolves force {force} | … | comes out best (see below)}.

<!-- This is an optional element. Feel free to remove. -->
### Consequences

* Good, because {positive consequence, e.g., improvement of one or more desired qualities, …}
* Bad, because {negative consequence, e.g., compromising one or more desired qualities, …}
* … <!-- numbers of consequences can vary -->
