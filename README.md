# Synchronous FIFO in Verilog

A parameterized synchronous FIFO (first-in, first-out) implemented in Verilog HDL.

The repository includes the RTL, a scenario-based testbench, and waveform screenshots for the main operating cases.

## Features

* Parameterized data width, FIFO depth, and almost-full/almost-empty threshold
* Synchronous, active-high reset
* Read/write pointers with an extra wrap bit
* `full`, `empty`, `almost_full`, and `almost_empty` status outputs
* Prevents writes while full and reads while empty
* Supports simultaneous read/write when the FIFO contains data
* Implements an empty simultaneous read/write bypass: `rd_data` captures `wr_data`, while the FIFO remains empty

## Design parameters

| Parameter   | Default | Meaning                                           |
|-------------|--------:|---------------------------------------------------|
| `WIDTH`     | 8       | Number of bits in each FIFO word                  |
| `DEPTH`     | 16      | Number of words the FIFO can store                |
| `THRESHOLD` | 2       | Margin used for almost-full/almost-empty flags    |

**Parameter constraint:** The current pointer/index implementation assumes `DEPTH` is a power of two and at least 2. `THRESHOLD` should be chosen in the range `0` through `DEPTH`.

## Interface

| Port                  | Direction | Description                                        |
|-----------------------|-----------|----------------------------------------------------|
| `clk`                 | Input     | Clock; state updates on the rising edge            |
| `rst`                 | Input     | Synchronous, active-high reset                     |
| `wr_en`               | Input     | Requests a write                                   |
| `rd_en`               | Input     | Requests a read                                    |
| `wr_data[WIDTH-1:0]`  | Input     | Data to write                                      |
| `rd_data[WIDTH-1:0]`  | Output    | Registered read data                               |
| `full`                | Output    | FIFO occupancy equals `DEPTH`                      |
| `empty`               | Output    | FIFO occupancy equals 0                            |
| `almost_full`         | Output    | Occupancy is at least `DEPTH - THRESHOLD`          |
| `almost_empty`        | Output    | Occupancy is at most `THRESHOLD`                   |

### Operation notes

* A write request is ignored when the FIFO is full, except when `wr_en` and `rd_en` are both asserted while full; in that case one item is read and one item is written.
* A read request is ignored when the FIFO is empty, except for the simultaneous empty read/write bypass.
* During the empty bypass, the output captures the incoming write data, but no word is stored and the FIFO stays empty.
* Reset clears the pointers and `rd_data`; it does not clear every memory location. Do not treat memory contents as valid until written.
* `rd_data` holds its previous value when no read (or empty bypass) updates it.

## Files

```text
syn_fifo/
├── syn_fifo.v       # FIFO RTL (module name: fifo)
├── tb_syn_fifo.v    # Scenario-based testbench (top: syn_fifo_tb)
├── README.md
├── .gitignore
└── waveforms/       # Captured waveform screenshots
```

## Simulation

### Xilinx Vivado Simulator

1. Create or open a Vivado project.
2. Add `syn_fifo.v` as a design source.
3. Add `tb_syn_fifo.v` as a simulation source.
4. Set `syn_fifo_tb` as the simulation top and run behavioral simulation.
5. Inspect the signals `wr_en`, `rd_en`, `wr_data`, `rd_data`, `full`, `empty`, `almost_full`, and `almost_empty`.

## Waveform scenarios

| Scenario                                      | Screenshot |
|-----------------------------------------------|------------|
| Reset and initialization                      | [`waveforms/00_reset_initialization.png`](waveforms/00_reset_initialization.png) |
| Write overflow attempt                        | [`waveforms/01_write_overflow.png`](waveforms/01_write_overflow.png) |
| Read underflow attempt                        | [`waveforms/02_read_underflow.png`](waveforms/02_read_underflow.png) |
| Simultaneous read/write while empty (bypass)  | [`waveforms/03_simultaneous_rw_empty_bypass.png`](waveforms/03_simultaneous_rw_empty_bypass.png) |
| Write several words, then read                | [`waveforms/04_write_then_read.png`](waveforms/04_write_then_read.png) |
| Simultaneous read/write with nonzero occupancy| [`waveforms/05_simultaneous_rw_nonempty.png`](waveforms/05_simultaneous_rw_nonempty.png) |
| Simultaneous read/write while full            | [`waveforms/06_simultaneous_rw_full.png`](waveforms/06_simultaneous_rw_full.png) |
| Reset during operation                        | [`waveforms/07_reset_during_operation.png`](waveforms/07_reset_during_operation.png) |

## Verification status and next improvement

The included testbench applies directed stimulus for the scenarios above, and the repository includes captured waveform screenshots. The testbench is **not yet self-checking**.
