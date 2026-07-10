# UART FPGA - Two-Board Data Transfer System

UART communication system for Intel/Altera FPGAs. One board edits a 4-digit BCD value on a 7-segment display and transmits it over UART; another board receives and displays it.

## Structure

- `rtl/` — Verilog source files (UART TX/RX, baud rate generator, 7-segment display controller, debouncer)
- `sim/` — Testbenches (loopback test and dual-board simulation)
- `quartus/` — Quartus Prime project files (`.qpf`, `.qsf`)

## Modules

| Module | Description |
|--------|-------------|
| `uart_top` | Top-level: ties display, UART TX/RX, and baud gen together |
| `tx` | UART transmitter: 1 start, 8 data (LSB first), 1 stop |
| `rx` | UART receiver with oversampling and mid-bit sampling |
| `baud_rate_generator` | Clock divider for TX and RX baud ticks |
| `seven_seg_mux` | 4-digit 7-segment display with button editing and external load |
| `debouncer` | 20ms button debouncer |

## Simulation

Run `uart1_tb` to simulate Master setting BCD=5678 and transmitting over UART to Slave.
