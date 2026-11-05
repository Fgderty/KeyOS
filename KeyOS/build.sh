#!/bin/bash
set -e

echo "======================================================"
echo "  Building KeyOS (Multi-Directory)"
echo "======================================================"

echo "[1/3] Compiling boot/boot.asm..."
nasm -f elf32 boot/boot.asm -o boot/boot.o

echo "[2/3] Compiling kernel/kernel.asm..."
nasm -f elf32 kernel/kernel.asm -o kernel/kernel.o

echo "[3/3] Linking..."
ld -m elf_i386 -N -Ttext 0x7c00 --oformat binary -o myMBR.tmp boot/boot.o kernel/kernel.o

cp myMBR.tmp myMBR.bin
truncate -s 510 myMBR.bin
printf '\x55\xAA' >> myMBR.bin

echo "======================================================"
echo "[OK] Build successful."
echo "  Output size: $(stat -c%s myMBR.bin) bytes"
echo "======================================================"

qemu-system-x86_64 -drive format=raw,file=myMBR.bin
