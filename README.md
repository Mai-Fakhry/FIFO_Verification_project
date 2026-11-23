# Synchronous FIFO – SystemVerilog Functional Verification

## Overview

This project focuses on the functional verification of a synchronous FIFO (First-In, First-Out) using SystemVerilog.

The FIFO design and its verification environment were developed to validate correct operation under normal conditions, boundary conditions, and simultaneous read/write transactions.

The project uses constrained-random stimulus, SystemVerilog Assertions (SVA), and code coverage analysis to evaluate the design's correctness and verification completeness.

## FIFO Specifications

| Parameter | Value |
|---|---|
| FIFO Type | Synchronous FIFO |
| Data Width | 16 bits |
| FIFO Depth | 8 entries |
| Reset | Active-low asynchronous reset |
| Clocking | Single clock domain |
| Verification Language | SystemVerilog |

## Features Verified

- Write and read operations
- FIFO full and empty conditions
- Almost-full and almost-empty flags
- Overflow detection
- Underflow detection
- Write acknowledgment
- Simultaneous read and write operations
- Reset behavior
- FIFO boundary conditions

## Verification Methodology

### 1. Constrained-Random Stimulus

Developed a transaction class with randomized control signals and distribution constraints to generate different FIFO operating scenarios.

### 2. Directed Testing

Implemented directed test scenarios to exercise important conditions, including:

- Filling the FIFO completely.
- Attempting a write while the FIFO is full.
- Reading from a full FIFO.
- Draining the FIFO until empty.
- Attempting a read while the FIFO is empty.
- Simultaneous read/write operations.
- Reset and boundary-condition testing.

### 3. Assertion-Based Verification

Implemented SystemVerilog Assertions (SVA) to check FIFO behavior and internal consistency.

Assertions cover:
- Reset values and pointer initialization.
- Full and empty flag correctness.
- Almost-full and almost-empty flag behavior.
- Overflow and underflow conditions.
- Write acknowledgment behavior.
- FIFO counter and pointer updates.
- Illegal or unexpected FIFO states.

### 4. Coverage Analysis

Used ModelSim code coverage and functional coverage reports to evaluate verification completeness and identify untested scenarios.

## Verification Results

The simulation and coverage analysis produced the following results:

| Metric | Result |
|---|---:|
| Assertion Checks | 19/19 Passed |
| Statement Coverage | 100% |
| Branch Coverage | 96.87% (31/32) |

The coverage reports are included in the repository for reference.

## Tools & Technologies

- SystemVerilog
- ModelSim Intel FPGA Edition
- SystemVerilog Assertions (SVA)
- Constrained-Random Verification
- Code Coverage Analysis
- Functional Coverage

## Repository Structure

```text
FIFO_Verification_project/
│
├── FIFO.sv
├── FIFO_INTERFACE.SV
├── FIFO_MONITOR.sv
├── FIFO_TB.SV
├── FIFO_TOP.SV
│
├── shared_pkg.SV
├── pkg_1.sv
├── pkg_2.sv
├── pkg_3.sv
│
├── run.do
│
├── code_coverage_report.txt
├── fcover_report.txt
├── important_coverage_report.txt
│
└── Project.pdf
```

## Running the Simulation

1. Open ModelSim.
2. Navigate to the project directory.
3. Execute the simulation script:

```tcl
do run.do
```

The script compiles the SystemVerilog source files, launches the FIFO top-level testbench, runs the simulation, and generates coverage reports.

## Project Objectives

This project demonstrates practical experience in:

- Developing SystemVerilog verification environments.
- Writing constrained-random test scenarios.
- Implementing assertion-based verification.
- Analyzing code and functional coverage.
- Identifying and handling FIFO corner cases.
- Using simulation results to evaluate RTL correctness.

## Author

**Mai Fakhry**

Computer and AI Engineering  
Ain Shams University

[GitHub Repository](https://github.com/Mai-Fakhry/FIFO_Verification_project)
