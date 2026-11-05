#!/bin/bash

set -e

echo "---Building KeyOS Bootloader---"

nasm -f bin myMBR.asm -o myMBR.bin
echo "[OK] Compilation successful."

cp myMBR.bin myMBR.img
echo "[OK] Disk image created."

echo "---Starting QEMU---"
qemu-system-x86_64 -drive format=raw,file=myMBR.img
