# FPGA Pong — Two-Player Hardware Game on DE10-Lite

A fully hardware-implemented two-player Pong game designed in **SystemVerilog** on the **Intel DE10-Lite FPGA board**. Game logic, VGA rendering, accelerometer-driven paddle control, and real-time scoring are all implemented in RTL — zero software, zero processor.

> **Course:** EECS 3216 — Digital Systems Design, York University (Winter 2024)  
> **Team:** Emmanuel Akin-salami · Bhavitesh Garg · Amr Almazloum

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Module Descriptions](#module-descriptions)
- [Results](#results)
- [How to Build & Run](#how-to-build--run)
- [Tools Used](#tools-used)
- [Lessons Learned](#lessons-learned)
- [3-Minute Walkthrough](#3-minute-walkthrough)

---

## Overview

The game renders a 640×480 VGA field at 60 Hz with two paddles, a puck, and a live scoreboard — all generated from combinational and sequential logic. Players control paddles by tilting the board's built-in **ADXL345 accelerometer** (x-axis for horizontal, y-axis for vertical movement). A 60-second countdown timer declares the higher-scoring player the winner when time expires.

**Key design constraints:**
- No CPU — all logic is purely RTL
- SPI communication to accelerometer sampled in hardware
- Score displayed on onboard 7-segment displays
- Game timer resets on button press; paddles respond with < 1 clock cycle latency at game clock rate

---

## Architecture

```
                          ┌─────────────────────────────────────────┐
                          │         DE10_LITE_Golden_Top.sv          │
                          │  (Top-level module — connects all below) │
                          └────────────┬──────────────┬─────────────┘
                                       │              │
               ┌───────────────────────┼──────────────┼──────────────────────┐
               │                       │              │                      │
    ┌──────────▼──────────┐  ┌─────────▼──────┐  ┌───▼──────────┐  ┌───────▼──────┐
    │   SPI Stack         │  │  VGA Subsystem │  │  Game Logic  │  │  Scoring     │
    │                     │  │                │  │              │  │              │
    │  spi_serdes.sv      │  │  sync_gen.sv   │  │  ball.sv     │  │  scoreboard  │
    │  spi_control.sv     │  │  vga_controller│  │  left_paddle │  │  .sv         │
    │                     │  │  .sv           │  │  .sv         │  │              │
    │  (ADXL345 ↔ FPGA)  │  │  (640×480@60Hz)│  │  right_paddle│  │  (7-seg HEX) │
    └──────────────────── ┘  └────────────────┘  │  .sv         │  └──────────────┘
                                                  │  pong_control│
                                                  │  .sv (FSM)   │
                                                  └──────────────┘

    Board Inputs: ADXL345 accelerometer (SPI), KEY[1:0] buttons
    Board Outputs: VGA connector (R/G/B + H/V sync), HEX displays (score + timer)
```

### Game State FSM

The `pong_control.sv` module implements a 3-state FSM:

```
  RESET ──► PLAYING ──► GAME_OVER
    ▲            │
    └────────────┘ (on timer expiry or KEY press)
```

In `PLAYING` state, a nested FSM tracks puck possession (free, left-side, right-side) and updates collision flags on every clock cycle.

---

## Module Descriptions

| File | Function |
|---|---|
| `DE10_LITE_Golden_Top.sv` | Top-level: wires all modules, maps I/O pins, controls paddle movement |
| `puck.sv` | Puck position tracking, wall/paddle collision detection, trajectory update |
| `game_state.sv` | Game state FSM (RESET → PLAYING → GAME_OVER) |
| `vga_display.sv` | Pixel address → RGB color mapping; draws field, paddles, puck |
| `vga_sync.sv` | VGA H/V sync and blanking signal generation (adapted from open-source) |
| `score_display.sv` | Binary-to-7-segment encoder for live score display |
| `Timer.sv` | 60-second countdown; declares winner on expiry or KEY press reset |
| `clock_divider.sv` | Generates 1 ms pulse for game timing |
| `spi_control.sv` | Initializes ADXL345 accelerometer; issues periodic X/Y read commands |
| `spi_serdes.sv` | 4-wire SPI serializer/deserializer; 8-bit transfer, CPOL=1 CPHA=1 |

---

## Results

All synthesis and place & route performed with **Quartus Prime Lite** on the **Intel MAX10 (10M50DAF484C7G)** device.

| Metric | Value |
|---|---|
| Logic Elements (LEs) | 1,789 / 49,760 — **4%** |
| Registers | 372 / 49,760 — **1%** |
| 9-bit DSP Blocks | 0 / 288 |
| PLLs | 1 / 4 (for 25 MHz VGA pixel clock) |
| **Fmax (Slow 85°C corner)** | **80.73 MHz** |
| VGA output | 640 × 480 @ 60 Hz |
| Game clock | 50 MHz (onboard oscillator) |
| Accelerometer sample rate | Configured via SPI init sequence |

The design is extremely lightweight — 4% LE utilization with significant headroom for additional game features or display elements.

**Demo:** [Drive link](https://drive.google.com/file/d/12x8Y-OBAWBwtN-MbQ-zOkENaJjP4MvaE/view?usp=drivesdk)

---

## How to Build & Run

### Prerequisites

- Intel Quartus Prime Lite Edition (tested on 21.x / 23.x)
- DE10-Lite FPGA development board
- VGA monitor + cable
- ModelSim-Altera (optional, for simulation)

### Synthesize & Program

```bash
# 1. Clone the repo
git clone https://github.com/Jujuakin/Pong-Game.git
cd Pong-Game

# 2. Open in Quartus
quartus Final_Project.qpf

# 3. Compile (Synthesis → Fitter → Assembler → Timing Analysis)
#    Processing → Start Compilation  [Ctrl+L]

# 4. Program the board
#    Tools → Programmer → Add File → output_files/v1.sof → Start
```

### Simulate a Module (ModelSim)

```bash
# Example: simulate the ball/puck module
vsim -do "
  vlog ball.sv
  vsim work.ball
  add wave *
  run 500ns
"
```

### Play

1. Connect the DE10-Lite to a VGA monitor
2. Power the board — game starts in **RESET** state
3. Press **KEY[0]** to start; press again to reset
4. Tilt the board to move each player's paddle
5. The 7-segment displays show scores (left / right) and countdown timer
6. Player with higher score when timer hits 00 wins

---

## Tools Used

| Tool | Purpose |
|---|---|
| Quartus Prime Lite 21.x | Synthesis, place & route, programming |
| ModelSim-Altera | Behavioral simulation |
| SystemVerilog (IEEE 1800) | HDL |
| Intel DE10-Lite | Target FPGA board (MAX10, 50K LEs) |
| ADXL345 | 3-axis accelerometer (SPI, onboard) |
| VGA display | 640×480 @ 60 Hz output |

---

## Lessons Learned

**SPI accelerometer integration was the hardest part.** Initializing the ADXL345 requires a specific write sequence over SPI before any axis data is readable. Getting the CPOL/CPHA mode, bit ordering, and CS timing right consumed a significant portion of debugging time. The `spi_control.sv` FSM went through multiple iterations before stable readings were achieved.

**Modular design paid off.** Isolating the VGA timing, game logic, SPI stack, and scoring into separate modules made it straightforward to debug each subsystem independently. When ball-paddle collision detection had an off-by-one pixel error, it was fixable in `ball.sv` without touching the VGA or SPI code.

**Collision detection edge cases.** Puck-paddle collision needed special handling for corner hits (top/bottom edge of paddle) to produce realistic angle deflection, and for high-speed puck states where the puck could tunnel through a paddle in a single clock cycle. Both required adding lookahead logic to the trajectory update.

---

## 3-Minute Walkthrough

| Time | What to show |
|---|---|
| 0:00–0:30 | Open repo, point to the module hierarchy and explain the top-level wiring |
| 0:30–1:00 | Walk through `ball.sv` — show the collision detection logic and trajectory FSM |
| 1:00–1:30 | Show `spi_control.sv` — explain the ADXL345 init sequence and why SPI mode matters |
| 1:30–2:00 | Open Quartus → Compilation Report → show 1,789 LEs, Fmax 80.73 MHz |
| 2:00–2:30 | Show the `vga_controller.sv` pixel address → color mapping |
| 2:30–3:00 | Demo video — live game running on the DE10-Lite board |
