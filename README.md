Overview
This repository contains a fully synthesizable, cycle-accurate AES-128 encryption core written in strict Verilog-2001. The architecture implements the Advanced Encryption Standard (AES) algorithm as specified by FIPS-197.

The design was developed entirely at the RTL level and verified using Xilinx ISim. The objective of the project was to design a modular, synthesizable encryption engine capable of performing all ten AES encryption rounds while maintaining clear hardware hierarchy, robust control path design, and precise datapath synchronization.

Architecture
The design avoids a massive, monolithic block in favor of a highly modular, spatially unrolled datapath governed by a centralized Moore Finite State Machine (FSM). This structure closely matches the mathematical description of the AES standard.

Datapath: A shared combinational datapath consisting of SubBytes (16 parallel S-boxes), ShiftRows, MixColumns, and AddRoundKey. A bypass multiplexer dynamically skips the MixColumns stage during the final round.

Key Schedule: Key expansion is computed on-the-fly combinationally, minimizing register utilization while maintaining standard compliance.

Control Path: An iterative FSM handles the initial Round 0 AddRoundKey bypass, sequences the standard 9 rounds, executes the final round, and asserts a ciphertext_valid flag upon completion.

Engineering Challenges & Architectural Solutions
Translating a software-centric cryptographic algorithm into a reliable RTL pipeline presents several unique hardware challenges. Throughout development, specific focus was placed on solving both mathematical and microarchitectural issues:

1. FSM Sequencing & Metastability Mitigation
Challenge: Ensuring every AES transformation occurred in the correct clock cycle required careful FSM sequencing. Furthermore, driving the core with an asynchronous start pulse risked injecting metastability directly into the combinational logic cone of the round controller.

Solution: The round controller was refined to strictly track state transitions and round counts. To handle asynchronous inputs safely, an industry-standard 3-stage flip-flop synchronizer was implemented. The input is safely stabilized before the rising edge detector triggers the S_LOAD state.

2. Key Expansion Timing & Phase Alignment
Challenge: In an iterative hardware architecture, data processing and key expansion happen in parallel. The expanded round keys needed to be available exactly when required by the datapath, avoiding off-by-one timing conflicts where the Round(n) datapath accidentally XORs with the Round(n-1) key.

Solution: The key scheduling logic was restructured and strictly phase-aligned. The AddRoundKey stage combinations now dynamically tap the next_key output of the key expansion module, ensuring the on-the-fly key generation latency perfectly matches the datapath transformations cycle-by-cycle.

3. Finite-Field Arithmetic & Big-Endian Vector Mapping
Challenge: Implementing Galois field arithmetic for MixColumns required extreme precision, as even a single-bit error produces completely invalid ciphertext. Additionally, software algorithms often default to Little-Endian arrays, whereas FIPS-197 strictly dictates a Big-Endian matrix representation.

Solution: The MixColumns arithmetic was isolated and verified independently against known AES intermediate values. To ensure compliance, the byte-indexing across both ShiftRows and MixColumns was explicitly mapped to a Big-Endian 128-bit vector (where [127:120] represents Byte 0). This explicit assignment prevents synthesis index-math bugs and ensures 100% standard compliance.

4. Advanced Functional Verification & Fault Isolation
Challenge: Debugging a deep combinational cryptographic pipeline is difficult because incorrect outputs can originate from any of the four internal transformations, making standard waveform viewing highly inefficient.

Solution: A custom Cycle-Accurate Telemetry Testbench (tb_aes_fips_trace.v) was developed. Instead of only checking the final ciphertext, the testbench monitors intermediate encryption states cycle-by-cycle and cross-references them against official FIPS-197 Known Answer Tests (KAT). It generates a structured ASCII table in the console, automatically isolating failures to the exact module and clock cycle.

Tools & Target Environment
Language: Verilog-2001 (Strictly synthesizable, no vendor-specific IP blocks)

Simulation & Verification: Xilinx ISim

Development Suite: Xilinx ISE Design Suite 14.7

Target Hardware Profile: Designed with Spartan-6 / 6-input LUT architectures in mind.

Project Structure
Plaintext
rtl/
    aes_top.v            # Top-level integration
    aes_controller.v     # Moore FSM
    aes_params.v         # Global definitions
    add_round_key.v
    key_expansion.v
    mix_columns.v
    shift_rows.v
    sub_bytes.v
    sbox.v               # 256x8 LUT
    gf_arith.v           # Galois Field multipliers
    register_ce.v        # Parameterized storage
    round_counter.v

testbench/
    tb_aes_fips_trace.v  # Cycle-accurate telemetry verifier

output/
    Console verification & Simulation Window outputs
Future Enhancements
Possible future enhancements include:

AXI4-Stream Integration: Wrap the core in an AXI-Stream interface to support seamless integration into larger SoC architectures or video processing pipelines.

Sub-Pipelining: Insert pipeline registers immediately following the SubBytes (S-box) stage to break the critical combinational path, effectively doubling clock frequency at the cost of doubling block latency.

Expanded Standard Support: Add support for AES-192 and AES-256 key lengths.

Decryption Module: Implement the inverse transformations (InvSubBytes, InvMixColumns, etc.) for full transceiver capability.

License
This project is released under the MIT License.
