# KeyOS

A custom x86 operating system built from scratch. The goal of this project is to gain a deep understanding of low-level computer architecture, memory management, and system programming without relying on existing frameworks.

## 🚀 Current Status
* [x] 16-bit Real Mode bootloader (MBR)
* [x] Transition to 32-bit Protected Mode (GDT, A20 line)
* [x] VGA text mode driver in Freestanding C (direct memory access at `0xB8000`)
* [x] Modular build system (ASM + C)
* [ ] Interrupt Descriptor Table (IDT) — *in progress*

## 🛠️ Tech Stack
* **Languages:** C (Freestanding), x86 Assembly (NASM)
* **Tools:** GCC, GNU ld, QEMU, GDB, Bash

## ⚙️ How to Build and Run
1. Ensure you have `nasm`, `gcc`, `ld`, and `qemu-system-x86_64` installed.
2. Clone the repository.
3. Make the build script executable:
   ```bash
   chmod +x build.sh
