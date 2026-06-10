# 4-Stage Pipeline Multiplier using Verilog HDL

**B.Tech Pre-Final Year Project | University of Delhi, Faculty of Technology**
**Session: 2025–26**

**Team:** Abhishek Kumar | Inshal Ahmed | Hari Singh | Sadaf Quraishi
**Guided by:** Dr. Sweta Rani & Dr. Khushwant Sehra

---

## Overview

A power-efficient, high-speed **16×16-bit pipelined multiplier** designed in Verilog HDL.
The design achieves **100% throughput** (1 product/cycle) at **100 MHz** with a fixed
4-cycle latency.

### Key Novelty: Zero-Skip Bypass Controller
Traditional multipliers waste power even when multiplying by zero.
Our design detects zero-valued input nibbles at Stage 1 and **freezes** subsequent
pipeline stages — preventing unnecessary switching and reducing dynamic power consumption.

---

## Architecture

The multiplier uses a **4-stage K-pipeline** with structural-behavioral hybrid design:

| Stage | Function |
|-------|----------|
| Stage 1 | Nibble decomposition, 16 parallel partial products + Zero Detection |
| Stage 2 | Masked row summation, positional shifting → four 20-bit sums |
| Stage 3 | RCA-based reduction → two 28-bit half-products |
| Stage 4 | Final 32-bit RCA resolution → registered output |

---

## Performance Metrics

| Parameter | Value |
|-----------|-------|
| Operand Width | 16 × 16 bit |
| Output Width | 32-bit |
| Clock Frequency | 100 MHz |
| Throughput | 1 product/cycle |
| Pipeline Latency | 4 clock cycles |
| Total Power | 0.051 W |
| Test Results | 54 PASS / 0 FAIL |

---

## Tools Used

- **Language:** Verilog HDL
- **Simulator/Synthesizer:** Xilinx Vivado Design Suite
- **Verification:** Custom self-checking testbench

---

## How to Simulate

1. Clone the repository:
```bash
   git clone https://github.com/YOUR_USERNAME/4-stage-pipeline-multiplier.git
```
2. Open **Xilinx Vivado**
3. Create a new project and add all `.v` files from `src/` and `testbench/`
4. Set `Pipeline_ET_full_tb.v` as the top simulation module
5. Run Behavioral Simulation
6. Check the TCL console for PASS/FAIL results

---

## Verification Cases

| Case | Input | Result |
|------|-------|--------|
| Max Value | 0xFFFF × 0xFFFF | PASS ✅ |
| Upper Half Zero | 255 × 255 | PASS ✅ (75% switching reduced) |
| Alternating Zero | 0x0F0F × 0xF0F0 | PASS ✅ |
| Full Bypass | 0 × 65535 | PASS ✅ |
| Random (50 tests) | Random 16-bit | All PASS ✅ |

---

## License
This project is submitted for academic purposes at University of Delhi.
