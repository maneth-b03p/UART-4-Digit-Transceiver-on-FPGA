# UART FPGA - Two-Board Data Transfer System

UART communication system for Intel/Altera FPGAs. One board edits a 4-digit BCD value on a 7-segment display and transmits it over UART; another board receives and displays it.

## Structure

- `rtl/` — Verilog source files (top-level, UART TX/RX, baud rate generator, 7-segment display controller)
- `sim/` — Testbenches (loopback test and dual-board simulation)
- `quartus/` — Quartus Prime project files (`.qpf`, `.qsf`)

## Modules (file -> module)

| Module (file) | Description |
|---------------|-------------|
| `uart_top` (rtl/uart_top.v) | Top-level: ties display, UART transmitter and receiver, and baud generator together. Uses active-low reset `rst_n` on the top interface. |
| `transmitter` (rtl/tx.v) | UART transmitter: 1 start, 8 data bits (LSB first), 1 stop. Driven by the `tx_enb` tick from the baud generator. |
| `receiver` (rtl/rx.v) | UART receiver with oversampling (16x) and mid-bit sampling; asserts `rdy` and provides `data_out` when a byte is received. |
| `baud_rate_generator` (rtl/baud_rate_generator.v) | Clock divider that produces `tx_enb` and `rx_enb` ticks. Designed for a 50 MHz input clock and 9600 baud with 16x oversampling (see notes below). |
| `seven_seg_mux` (rtl/seven_seg_mux.v) | 4-digit 7-segment display controller with button-based editing and an external-load path for incoming UART digits. Includes debounce logic for the front-panel buttons. |


## Notes on behavior and wiring

- Reset polarity: the top-level module uses an active-low reset input named `rst_n`. Submodules expect active-high reset signals where appropriate; `uart_top` converts polarity for those submodules as required.

- External load via UART: when the receiver asserts `rdy`, `uart_top` checks the received byte and asserts the display module's `external_load` only when the received byte is in the decimal range 0x00..0x09 (ASCII/encoding of digits 0-9 is not required — the value must be 0..9). The 4-bit `external_data` supplied to the display is the lower nibble of the received byte. In short: receiving a byte with value 0..9 will shift previous digits and load that digit into the ones place.

- Baud/timing assumptions: `baud_rate_generator` uses constants chosen for a 50 MHz clock and targets 9600 baud. The `tx_enb` tick period corresponds to ~5209 clock cycles (approx 9600 baud) and the `rx_enb` tick aligns to produce ~16x oversampling for the receiver. If you use a different clock, update the generator parameters (or replace the magic numbers with parameterized calculations).

## Simulation

- The `sim/uart1_tb.v` testbench runs a two-board simulation: it drives one `uart_top` as the Master, programs its 4-digit BCD value to 5678 using the front-panel button stimulus, then triggers a send so the Slave `uart_top` receives and updates its display. The testbench sets the clock to 50 MHz (20 ns period) to match the baud generator assumptions.



## How to run on hardware / Quartus

See `quartus/` for a sample project file set. You will need to assign pins in the .qsf file to match your FPGA board and the wiring for the 7-segment display and UART pins. The design assumes a 50 MHz input clock unless you change the baud generator constants.

