# AMBA AHB–APB Subsystem (Modular RTL Design)

This repository is **not just an AHB–APB bridge implementation**.

It is a **minimal but architecturally correct AMBA subsystem** composed of:

* an **AHB Master**
* an **AHB–APB Bridge (top-level integration)**
* an **APB Slave Interface**
* a **system-level testbench**

The goal is to **understand and internalize AMBA bus behavior**, not merely “make signals toggle”.

If you understand *why* each module exists, you understand **on-chip interconnect design**.

---

## What problem AMBA actually solves (concept most people miss)

Inside a SoC:

* CPUs and DMA engines want **high bandwidth, pipelined access**
* Peripherals want **simple, low-power register access**

Using one bus for everything is inefficient.

**AMBA solves this by hierarchy**, not by one universal bus.

> **AHB is optimized for performance.
> APB is optimized for simplicity.
> A bridge is required because these goals conflict.**

This repository models that reality.

---

## Architectural overview (big picture)

```
┌────────────┐      ┌─────────────────┐      ┌──────────────┐
│ AHB Master │ ───► │ AHB–APB Bridge  │ ───► │ APB Interface│
│            │      │   (Bridge_top)  │      │   (Slave)    │
└────────────┘      └─────────────────┘      └──────────────┘
         ▲                        ▲
         │                        │
         └───────── top_tb ───────┘
```

Each block has **one clear responsibility**.

---

## Repository structure

```
.
├── AHB_Master.v        # Generates legal AHB transactions
├── Bridge_top.v        # Protocol translation + control
├── APB_Interface.v    # Simple APB slave model
├── top_tb.v            # System-level integration testbench
└── README.md
```

---

## Conceptual roles of each block (this matters)

### AHB_Master — *Transaction generator*

**What it is:**

* A behavioral AHB master
* Generates **address phase** and **data phase** correctly

**What it teaches:**

* AHB is **pipelined**
* Address/control ≠ data timing
* `HTRANS` encodes *transfer intent*, not data validity
* `HREADY` controls flow, not the clock

**Key idea people forget:**

> On AHB, data belongs to the **previous address phase**.

This is why bridging AHB to APB is non-trivial.

---

###  Bridge_top — *Protocol translation core*

This is the **heart of the system**.

**What it does conceptually:**

* Converts a **pipelined, overlapped protocol (AHB)**
  into a **two-cycle, non-pipelined protocol (APB)**

**Why this is hard:**

* AHB can issue a new transfer every cycle
* APB cannot accept a new transfer until the previous one finishes

➡ Therefore, the bridge must:

* Stall AHB (`HREADYOUT`)
* Buffer address/data
* Serialize transfers
* Maintain correctness under back-to-back requests

**Key insight (often omitted):**

> A bridge is a *temporal decoupler*, not just a signal mapper.

---

###  APB_Interface — *Peripheral abstraction*

**What it is:**

* A simple APB slave model
* Returns constant data for reads
* Accepts writes during ENABLE phase

**What it teaches:**

* APB has **no pipelining**
* `PSEL` selects the peripheral
* `PENABLE` means “commit the transfer”
* Read data is valid **only in ENABLE phase**

**Important subtlety:**

> APB has no concept of burst, retry, or out-of-order access.

This is why APB is ideal for control registers.

---

### top_tb — *System-level truth*

**Why this matters more than unit testbenches:**

* Verifies **protocol interaction**, not just module correctness
* Exposes timing bugs that unit TBs hide
* Matches how real SoCs are validated

**Key idea:**

> Most AMBA bugs are *integration bugs*, not RTL bugs.

---

## Protocol behavior captured in this design

### AHB side

* Uses `HTRANS = NONSEQ / SEQ`
* Supports back-to-back requests
* Uses `HREADYOUT` for stalling
* Always returns `HRESP = OKAY`

### APB side

* Two-phase transfer:

  1. SETUP (`PSEL=1, PENABLE=0`)
  2. ENABLE (`PSEL=1, PENABLE=1`)
* No wait states (`PREADY` assumed high)
* One transfer at a time

---

## FSM philosophy 

The bridge FSM is not about states like *read* or *write*.

It is about **temporal alignment** between:

* AHB address phase
* AHB data phase
* APB setup phase
* APB enable phase

If you ever feel confused, ask:

> “Which bus phase am I aligning right now?”

That question unlocks the FSM logic.

---

## What this design intentionally does NOT include

This is by design, not omission.

* ❌ Multiple APB slaves
* ❌ `PREADY` wait states
* ❌ Error responses (`PSLVERR`)
* ❌ AXI / ACE features
* ❌ Cache coherency

Why?

> Because correctness comes **before completeness**.

---

## How to simulate

### Using Icarus Verilog

```bash
iverilog *.v -o sim.out
vvp sim.out
```

### Using ModelSim / Questa

```tcl
vlog *.v
vsim top_tb
run -all
```

---


## Conceptual takeaway (read this again later)

* AHB ≠ APB
* Bridging is **not wiring**
* Flow control matters more than data width
* FSMs exist to **manage time**, not signals
* Good AMBA design is about **discipline, not cleverness**

---


