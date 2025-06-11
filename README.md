# Generic LFSR-based Memory Scrambling Scheme
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)
![RT-Level: VHDL](https://img.shields.io/badge/RT--Level-VHDL-8877cc.svg)
![Software-Level: Python](https://img.shields.io/badge/Software--Level-Python-3776AB.svg)

This repository provides a generic and extensible simulation framework for analyzing Linear Feedback Shift Registers (LFSRs). The primary goal is to evaluate the **cycle length** of randomly selected tap configurations, under the constraint that the characteristic polynomial **always includes the `x^n` and `x` terms** (i.e., the most significant and least significant bits are always feedback-connected).

## 📁 Repository Structure

Generic_LFSR_Scheme/
<pre>  
├── src/ # Core Python scripts for LFSR simulation
│ ├── lfsr_cycle_length.py
├── tap_points/ # Pre-generated or manually selected tap configurations
│ ├── taps_16bit_LFSR.pdf
│ ├── taps_20bit_LFSR.pdf
│ ├── taps_24bit_LFSR.pdf
│ └── ...
├── vhdl/ # VHDL code of proposed generic LFSR memory scrambler
│ ├── LFSR_Scrambling
│ │  ├── SDRAM_controller_tb.v
│ │  ├── SDRAM_module.v
│ │  ├── hostcont.v
│ │  ├── inc.vh
│ │  ├── sdram.v
│ │  ├── sdramcnt.v
│ ├── proposed  
│ │  ├── scrambler.vhd # Updated after acceptance of research paper
├── README.md # Project documentation
</pre>  

## 🚀 Getting Started

### Requirements

- Python 3.6 or higher
- NumPy
