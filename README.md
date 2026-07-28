# FPGA Pong — Two-Player Hardware Game on DE10-Lite

A fully hardware-implemented two-player Pong game designed in **SystemVerilog** on the **Intel DE10-Lite FPGA board**. Game logic, VGA rendering, accelerometer-driven paddle control, and real-time scoring are all implemented in RTL — zero software, zero processor.

> **Course:** EECS 3216 — Digital Systems Design, York University (Winter 2024)  
> **Team:** Eyinojuoluwa Akin-Salami · Bhavitesh Garg · Amr Almazloum

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Module Descriptions](#module-descriptions)
- [Results](#results)
- [How to Build & Run](#how-to-build--run)
- [Tools Used](#tools-used)
- [Lessons Learned](#lessons-learned)

---

## Overview

The game renders a 640×480 VGA field at 60 Hz with two paddles, a puck, and a live scoreboard — all generated from combinational and sequential logic. Players control paddles by tilting the board's built-in **ADXL345 accelerometer** (x-axis for horizontal, y-axis for vertical movement). A 60-second countdown timer declares the higher-scoring player the winner when time expires.

**Key design constraints:**
- No CPU — all logic is purely RTL
- SPI communication to the accelerometer sampled in hardware
- Score and remaining time displayed on onboard 7-segment displays
- Game timer resets on button press

---

## Architecture

```
                      ┌──────────────────────────────┐
                      │  DE10_LITE_Golden_Top.sv     │
                      │  top level · I/O · paddles   │
                      └───┬───────┬────────┬─────────┘
                          │       │        │
        ┌─────────────────┘       │        └──────────────────┐
        │                         │                           │
        ▼                         ▼                           ▼
┌───────────────┐        ┌────────────────┐          ┌─────────────────┐
│  SPI Stack    │        │ VGA Subsystem  │          │  Game Logic     │
│               │        │                │          │                 │
│ spi_control   │        │ vga_sync.sv    │          │ puck.sv         │
│ spi_serdes    │        │ vga_display.sv │          │ game_state.sv   │
│               │        │                │          │ Timer.sv        │
│ (ADXL345 SPI) │        │ (640×480@60Hz) │          │ clock_divider   │
└───────────────┘        └────────────────┘          └─────────────────┘
                                                              │
                                                              ▼
                                                     ┌─────────────────┐
                                                     │ score_display   │
                                                     │ (7-seg HEX)     │
                                                     └─────────────────┘

  Inputs:  ADXL345 accelerometer (SPI), KEY[1:0] buttons
  Outputs: VGA (R/G/B + H/V sync), HEX displays (score + timer)
```

### Finite State Machines

The design contains four FSMs:

| FSM | Module | Purpose |
|---|---|---|
| **Game State** | `game_state.sv` | Overall game progression, driven by score and timer |
| **Playing State** | `game_state.sv` | Tracks in-play behaviour during an active round |
| **Color Race Mode** | `game_state.sv` | Alternate game mode |
| **Reset** | `game_state.sv` | Returns the game to a known start condition on KEY press |

---

## Module Descriptions

| File | Function |
|---|---|
| `DE10_LITE_Golden_Top.sv` | Top level: wires all modules, maps I/O pins, controls paddle movement |
| `puck.sv` | Puck position tracking, wall/paddle collision detection, trajectory update |
| `game_state.sv` | Game state, playing state, colour race mode, and reset FSMs |
| `vga_display.sv` | Pixel address → RGB colour mapping; draws field, paddles, puck |
| `vga_sync.sv` | VGA H/V sync and blanking generation *(based on open-source reference)* |
| `score_display.sv` | Binary-to-7-segment encoder for live score display |
| `Timer.sv` | 60-second countdown; declares winner on expiry or KEY reset |
| `clock_divider.sv` | Generates a 1 ms pulse for game timing *(based on open-source reference)* |
| `spi_control.sv` | Initializes the ADXL345; issues periodic X/Y read commands |
| `spi_serdes.sv` | 4-wire SPI serializer/deserializer |

---

## Results

All synthesis and place & route performed with **Quartus Prime Lite** targeting the **Intel MAX10 (10M50DAF484C7G)**. Figures below are from the Quartus Compilation Report.

| Metric | Value |
|---|---|
| Logic Elements (LEs) | 1,789 / 49,760 — **4%** |
| Registers | 372 |
| 9-bit DSP Blocks | 0 / 288 |
| PLLs | 1 / 4 (25 MHz VGA pixel clock) |
| **Fmax (Slow 85°C corner)** | **80.73 MHz** |
| VGA output | 640 × 480 @ 60 Hz |
| Game clock | 50 MHz (onboard oscillator) |

The design is lightweight — 4% LE utilization leaves substantial headroom for additional game features or display elements.

**Demo:** [Video walkthrough](https://drive.google.com/file/d/12x8Y-OBAWBwtN-MbQ-zOkENaJjP4MvaE/view?usp=drivesdk)

---

## How to Build & Run

### Prerequisites

- Intel Quartus Prime Lite Edition
- DE10-Lite FPGA development board
- VGA monitor + cable
- ModelSim (optional, for simulation)

### Synthesize & Program

```bash
git clone https://github.com/Jujuakin/Pong-Game.git
cd Pong-Game

# Open in Quartus
quartus Final_Project.qpf

# Compile: Processing → Start Compilation  [Ctrl+L]
# Program: Tools → Programmer → output_files/v1.sof → Start
```

### Simulate a Module (ModelSim)

```bash
vlog puck.sv
vsim work.puck
add wave *
run 500ns
```

### Play

1. Connect the DE10-Lite to a VGA monitor
2. Power the board — the game starts in the reset state
3. Press **KEY[0]** to start; press again to reset
4. Tilt the board to move each player's paddle
5. The 7-segment displays show scores and the countdown timer
6. The higher score when the timer reaches 00 wins

---

## Tools Used

| Tool | Purpose |
|---|---|
| Quartus Prime Lite | Synthesis, place & route, programming |
| ModelSim | Behavioural simulation |
| SystemVerilog (IEEE 1800) | HDL |
| Intel DE10-Lite | Target board (MAX10) |
| ADXL345 | 3-axis accelerometer (SPI, onboard) |

---

## Lessons Learned

**SPI accelerometer integration was the hardest part.** Initializing the ADXL345 requires a specific write sequence over SPI before any axis data is readable. Getting the mode, bit ordering, and chip-select timing right consumed a large share of debugging time — `spi_control.sv` went through several iterations before readings were stable. Finding usable reference material for the on-board accelerometer was itself a real obstacle.

**Modular design paid off.** Isolating VGA timing, game logic, the SPI stack, and scoring into separate modules made each subsystem debuggable on its own. Collision bugs were fixable inside `puck.sv` without touching VGA or SPI code.

**Synchronizing game elements to VGA timing was non-obvious.** Game state updates had to be paced against the display refresh rather than the 50 MHz system clock, which is what `clock_divider.sv` exists to solve. Getting this wrong produced visible tearing and inconsistent puck speed.
