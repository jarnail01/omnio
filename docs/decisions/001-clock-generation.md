# Clock Generation

## Context and Problem Statement

Need to decide between generating an internal clock using a ring oscillator or relying on [Tiny Tapeout's demo board](https://tinytapeout.com/specs/clock/) to generate a clock signal up to 66 MHz. 

## Considered Options

* Tiny Tapeout Demo board can generate the clock signal up to 66 MHz
* Internal ring oscillator
* If there is room for a ring oscillator, include it and give the user the option to toggle between the demo board clock and the ring oscillator

## Decision Outcome

Chosen option: "{title of option 1}", because {justification. e.g., only option, which meets k.o. criterion decision driver | which resolves force {force} | … | comes out best (see below)}.

### Consequences

* Good, because {positive consequence, e.g., improvement of one or more desired qualities, …}
* Bad, because {negative consequence, e.g., compromising one or more desired qualities, …}
