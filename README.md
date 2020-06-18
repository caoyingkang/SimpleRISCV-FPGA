# SimpleRISCV-FPGA

A calculator implemented on FPGA written in Verilog, with core component a simplified 32bit RISC-V single-cycle processor. This calculator supports such operations as *addition*, *subtraction*, and *multiplication*.

The I/O devices on FPGA board comprise of:

- *4 buttons* (`btnL`, `btnC`, `btnR` and `btnU`) for different input commands;
- *16 dial switches* for 4-digit input number in BCD format;
- an array of *16 LEDs* for output number in binary format;
- a *4-digit 7-segment display* for human-readable output.

All the I/O queries are implemented directly in program query mode.

The instruction set adopted in this RISC-V processor is a subset of RV32I, which includes `add`, `addi`, `sub`, `and`, `andi`, `or`, `ori`, `xor`, `xori`, `slt`, `slti`, `slli`, `srli`, `beq`, `bne`, `j`, `lui`, `lw`, `sw`. Notice that `srli` here is different from that defined in RISC-V in that the shift amount is always taken as one, regardless of the value of `shamt` appeared in the binary instruction code. That is, instruction `srli x2 x2 3` behaves the same as `srli x2 x2 1`.

The processor is divided into two main parts: **controller** and **data-path**. Data-path is further decomposed into several modules: **ALU**, **register file**, **immediate extender**, and **multiplexers**.

Physical address space is organized as follows:

- `0x0000-0x03FF`: instruction memory (`imem`)
  - read-only; 256 words = 1KB in size; instruction address is word (4 bytes) aligned.
- `0x1000-0x103F`: data memory (`dmem_io`)
  - read-write; 16 words = 64B in size; data address is word (4 bytes) aligned.
- `0x7F00-0x7FFF`: I/O registers/ports (`dmem_io`)
  - PORTA: `0x7F00`; read-only; lower 4bits store the input states of buttons `btnL`, `btnC`, `btnR` and `btnU` after synchronizer.
  - PORTB: `0x7F10`; read-only; 16bits store the binary input number after BCD-to-binary conversion from 16 dial switches `sw[15:0]`.
  - PORTC: `0x7F20`; read-write; 16bits store the binary output number before binary-to-BCD conversion for 4-digit 7-segment display.
  - PORTD: `0x7FFC`; read-write; 16bits store the output states of 16 LEDs `led[15:0]` for display.
- other: reserved.

Buttons function as commands to the calculator:

- `btnL`: add. Update register `x5 += portB` and output result to `portC`.
- `btnC`: sub. Update register `x5 -= portB` and output result to `portC`.
- `btnR`: multiply. Update register `x5 *= portB` and output result to `portC`.
- `btnU`: equal. Output `x5` to `portC`.
- `btnD`: reset. Restart the fetch-decode-execute cycle at instruction address `0x0000`.

In order to download any assembly program onto FPGA board, you'll want to: (Let's say you are using Vivado IDE and Xilinx Basys3 FPGA board)

1. Make sure that all the instructions are supported, and access to `imem` and `dmem_io` is within the available address space.
2. Compile the assembly program into machine codes, really, in hexadecimal text format (See `calc.dat` for example). [RARS](https://github.com/TheThirdOne/rars) is a wonderful tool in case you don't know how to dump the codes.
3. Convert the `.dat` file into `.coe` file (See `calc.coe` for example).
4. Launch Vivado project and generate module `imem_fpga` with *IP catalog - RAMs&ROMs - Distributed Memory Generator* using the `.coe` file (set *memory type* as ROM, *data width* as 32).
5. Add constraint file `.xdc` into the Vivado project.
6. Run *synthesis* and *implementation*.
