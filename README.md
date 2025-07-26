# Computer Organization and Design (Organosi kai Sxediash Ypologistwn) - Lab Repository

This repository contains comprehensive lab assignments for the "Computer Organization and Design" course, covering fundamental concepts in computer engineering from low-level assembly programming to high-level parallel computing implementations.

## 📚 Course Overview

The course provides hands-on experience with:
- **Assembly Language Programming** (MIPS architecture)
- **Digital Logic Design** using Verilog HDL
- **CPU Architecture and Control Unit Design**
- **Performance-oriented C Programming**
- **Parallel and Multithreaded Programming** (OpenMP, pthreads)
- **Memory Management and Optimization**

## 🛠️ Prerequisites and Tools

### Required Software:
- **Assembly Labs (1-3):** MIPS simulator (MARS or SPIM)
- **Verilog Labs (4, 6-7):** 
  - Icarus Verilog (`iverilog`) for simulation
  - GTKWave for waveform visualization
- **C Programming Labs (8-9):**
  - GCC compiler with OpenMP support
  - Standard C libraries

### Installation (Ubuntu/Debian):
```bash
sudo apt update
sudo apt install iverilog gtkwave gcc libomp-dev build-essential
```

## 📁 Lab Structure and Detailed Usage

### Lab 1: Assembly Programming Fundamentals
**Files:** `ask1.asm`, `ask2.asm`

**Objectives:**
- Basic MIPS assembly syntax and operations
- Integer input/output using system calls
- Bitwise operations and leading zero counting
- Control flow and conditional branching

**Usage:**
```bash
cd lab1
# Run with MARS simulator or SPIM
mars ask1.asm
```

**Example:** `ask1.asm` implements a leading zero counter that takes an integer input and calculates the number of leading zeros in its binary representation.

### Lab 2: Advanced Assembly Programming
**Files:** `ask1.asm`, `ask2.asm`, `ex2.asm`

**Objectives:**
- Advanced MIPS programming techniques
- Subroutines and function calls
- File I/O operations
- Complex data manipulation

**Usage:**
```bash
cd lab2
mars ask1.asm
```

### Lab 3: Assembly Practice
**Files:** `ask1.asm`

**Objectives:**
- Reinforcement of assembly concepts
- Problem-solving using assembly language
- Optimization techniques

### Lab 4: Digital Logic Design
**Files:** `library.v`, `testbench.v`, `Lab4.pdf`

**Objectives:**
- Introduction to Verilog HDL
- Digital circuit design and simulation
- Testbench creation and verification

**Usage:**
```bash
cd lab4
iverilog -o test library.v testbench.v
vvp test
# View waveforms (if VCD file generated)
gtkwave tb_dumpfile.vcd
```

### Lab 6: CPU Architecture Implementation
**Files:** `cpu.v`, `control.v`, `library.v`, `testbench.v`, `program.asm`, `Makefile`

**Objectives:**
- Design and implement a simple CPU in Verilog
- Control unit logic implementation
- Instruction fetch, decode, and execute cycles
- Assembly program execution on custom CPU

**Usage:**
```bash
cd lab6
make all  # Compiles, simulates, and opens waveform viewer
# Or manually:
iverilog -Wall -Winfloop -o lab6a.out control.v library.v cpu.v testbench.v
vvp lab6a.out
gtkwave tb_dumpfile.vcd
```

**Features:**
- Custom instruction set architecture
- Program memory loaded from `program.hex`
- Comprehensive testbench with waveform output

### Lab 7: Advanced CPU Design
**Files:** Similar to Lab 6 with enhancements

**Objectives:**
- Enhanced CPU architecture
- Advanced control logic
- Performance improvements
- Extended instruction set

**Usage:**
```bash
cd lab7
make all
```

### Lab 8: Parallel Programming - K-means Clustering
**Files:** `kmeans.c`, `kmeans_omp2.c`, `qdbmp.c`, `qdbmp.h`, `Makefile`

**Objectives:**
- Implement K-means clustering algorithm
- Parallel programming with OpenMP
- Image processing using BMP format
- Performance comparison between serial and parallel implementations

**Usage:**
```bash
cd lab8
make all  # Compiles standard version
gcc -O3 -fopenmp -o kmeans_omp kmeans_omp2.c qdbmp.c  # OpenMP version

# Run clustering
./kmeans input.bmp output.bmp k_value
./kmeans_omp input.bmp output.bmp k_value
```

**Features:**
- BMP image processing library
- Multiple parallelization approaches (OpenMP, pthreads)
- Performance optimization flags (`-O3`, `-Ofast`)

### Lab 9: Performance Analysis and Memory Management
**Files:** `lab9_program.c`, `getmemusage.c`, `loop1`, `loop2`, `Lab9.pdf`

**Objectives:**
- Memory usage analysis and optimization
- Loop optimization techniques
- Performance measurement and profiling
- Cache efficiency analysis

**Usage:**
```bash
cd lab9
gcc -O2 -o lab9_program lab9_program.c
./lab9_program

# Memory usage analysis
gcc -o getmemusage getmemusage.c
./getmemusage

# Compare optimized vs unoptimized loops
./loop1 vs ./loop1_opt
./loop2 vs ./loop2_opt
```

## 🔧 Build and Compilation Guide

### Verilog Projects (Labs 4, 6, 7):
```bash
# Standard compilation
iverilog -Wall -Winfloop -o output_file source_files.v

# Run simulation
vvp output_file

# View waveforms
gtkwave waveform_file.vcd
```

### C Projects (Labs 8, 9):
```bash
# Standard compilation
gcc -O3 -Wall -std=c99 -o executable source.c

# OpenMP compilation
gcc -O3 -fopenmp -Wall -std=c99 -o executable source.c

# Performance optimization
gcc -Ofast -march=native -o executable source.c
```

## 📊 Performance Notes

- **Assembly Labs:** Focus on instruction efficiency and register usage
- **Verilog Labs:** Emphasize timing analysis and resource utilization
- **C Labs:** Leverage compiler optimizations and parallel processing

## 📖 Documentation

Each lab includes detailed PDF documentation (`Lab*.pdf`) containing:
- Theoretical background
- Implementation requirements
- Expected outputs
- Performance analysis guidelines

## 👥 Authors

- **Emmanouil Raftopoulos**
- **Charalampos Zachariadis**

## 🚀 Getting Started

1. Clone the repository
2. Install required tools (see Prerequisites section)
3. Navigate to desired lab directory
4. Follow lab-specific usage instructions
5. Refer to PDF documentation for detailed requirements

## 📝 Notes

- All assembly code is written for MIPS architecture
- Verilog code is synthesizable and tested with Icarus Verilog
- C programs are optimized for performance and include parallel implementations
- Some labs include multiple solution approaches for comparison