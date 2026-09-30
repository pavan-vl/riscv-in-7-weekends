# RISCV-in-7-weekends

RV32I single-cycle and 5-stage pipelined cores in Verilog, with forwarding. A hobby project built over 7 weekends.

## What's inside

| Core | Description |
|---|---|
| **Single-cycle** | Every instruction completes in one clock. |
| **Pipelined** | Classic 5-stage pipeline (IF → ID → EX → MEM → WB) with a hazard unit that forwards results from MEM and WB back to the ALU inputs. |

Both designs follow the Harris & Harris *Digital Design and Computer Architecture (RISC-V Edition)* datapath.

## Supported instructions

| Instruction | Single-cycle | Pipelined |
|---|:---:|:---:|
| `add`, `sub`, `and`, `or`, `slt` | ✅ | ✅ |
| `lw` | ✅ | ✅ |
| `sw` | ✅ | ⚠️ datapath supports it, not yet tested |
| `addi` | ❌ | ✅ |

**Not yet:** `beq` / branches, load-use stall, branch flush.

## Repo layout

```
riscv-in-7-weekends/
├── single_cycle/
│   ├── core_top.v          # top level (includes the files below)
│   ├── alu.v
│   ├── cu.v                # main decoder + ALU decoder
│   ├── proc_comps.v        # PC, instruction/data memory, register file
│   └── tb_riscv_core.v     # self-checking testbench
├── pipeline/
│   ├── core_pipe_top.v     # top level + pipeline registers
│   ├── fetch.v
│   ├── decode.v
│   ├── execute.v
│   ├── memory.v
│   ├── writeback.v
│   ├── hazard_unit.v       # forwarding logic
│   ├── cu_pipe.v
│   ├── proc_comps_pipe.v   # ALU, memories, register file, muxes, extender
│   └── tb_riscv_pipe.v     # self-checking testbench
├── docs/
│   ├── pipeline_waveform.png
│   ├── pipeline_waveform_annotated.png
│   └── tcl_console_single_cycle.png
└── README.md
```

## Running the simulations

Both testbenches load their program directly into instruction memory (no hex file needed), run it, and print `PASS` / `FAIL` for every destination register.

**Vivado:** add the design files and the testbench as simulation sources, set the testbench as the simulation top, and click Run Simulation.

**Icarus Verilog:**

```bash
# single-cycle (core_top.v includes the other files)
cd single_cycle
iverilog -g2005 -o sim tb_riscv_core.v core_top.v && vvp sim

# pipelined
cd pipeline
iverilog -g2005 -o sim *.v && vvp sim
```

## Results

### Single-cycle

Test program: `add`, `sub`, `or`, `and`, `slt`, `sw`, `lw`, one instruction per clock.

![Single-cycle TCL console output](docs/tcl_console_single_cycle.png)

### Pipelined

Test program:

```asm
addi t0, x0, 5      # t0 = 5
addi t1, x0, 3      # t1 = 3
add  t2, t0, t1     # t2 = 8   <- t0 forwarded from WB, t1 from MEM
lw   s0, 0(x0)      # s0 = 0
addi s1, x0, 1      # s1 = 1
add  a0, s0, s1     # a0 = 1   <- s0 forwarded from WB, s1 from MEM
```

The two `add`s read registers that haven't been written back yet. The register file still returns 0, but the hazard unit forwards the correct values, so the ALU computes the right result.

![Annotated pipeline waveform](docs/pipeline_waveform_annotated.png)

*Each colour is one instruction moving through the pipeline stages. Dashed arrows show forwarding into the ALU inputs.*

<details>
<summary>Raw waveform (no annotations)</summary>

![Pipeline waveform](docs/pipeline_waveform.png)

</details>

## Things I learned the hard way

- **"It elaborated" does not mean "it works."** Verilog happily accepts an undriven `alu_out`, a 1-bit bus where 5 bits belong, or a typo'd `rsnt` that silently becomes a new wire.
- **Read the port-width warnings.** Icarus pads a missing select bit with 0, but Vivado's simulator left it as `Z`. That turned a clean mux into partial-X outputs like `0000000X`.
- **Forwarding isn't the whole story.** An instruction can read a register in the same cycle it's being written back, which forwarding can't cover. The register file needs a write-through bypass.

## Next up

- [ ] `beq` and branch flush
- [ ] Load-use stall
- [ ] Test `sw` on the pipeline
- [ ] More I-type ALU ops (`andi`, `ori`, `slti`)
