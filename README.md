# KeyOS

KeyOS is a custom, from-scratch x86 operating system. The goal of this project is to deeply understand low-level computer architecture, memory management, and system programming without relying on existing frameworks.

## 🚀 Current Status
The project is currently in the early boot stage.
* [x] 16-bit Real Mode bootloader
* [x] Transition to 32-bit Protected Mode (GDT, A20 line)
* [x] Basic VGA text mode driver (screen clearing, string printing)
* [x] Modular architecture (separated `boot.asm` and `kernel.asm`)

## 🛠️ Tech Stack & Tools
* **Language:** x86 Assembly (NASM)
* **Linker:** GNU `ld`
* **Emulator:** QEMU
* **Build System:** Bash (`build.sh`)

## ⚙️ How to Build and Run
1. Ensure you have `nasm`, `ld`, and `qemu-system-x86_64` installed.
2. Clone the repository.
3. Make the build script executable:
   `chmod +x build.sh`
4. Run the script:
   `./build.sh`

This will compile the sources, link them into a 512-byte bootable image, and launch QEMU.

## 🗺️ Roadmap
* [ ] Transition kernel development to C (Freestanding)
* [ ] Implement Interrupt Descriptor Table (IDT)
* [ ] Keyboard driver
* [ ] Memory management (Paging)
* [ ] Simple filesystem
* [ ] Custom shell
