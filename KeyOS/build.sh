#!/bin/bash
set -e
set -o pipefail

echo "========================================="
echo " Building KeyOS (Universal Pipeline) "
echo "========================================="

rm -rf build
mkdir -p build

echo "[1/3] Compiling all ASM files..."
for asm_file in $(find . -name "*.asm" -not -path "./build/*"); do
    obj_file="build/${asm_file#./}"
    obj_file="${obj_file%.asm}.o"
    mkdir -p "$(dirname "$obj_file")"
    echo " -> $asm_file"
    nasm -f elf32 "$asm_file" -o "$obj_file"
done

echo "[2/3] Compiling all C files..."
for c_file in $(find . -name "*.c" -not -path "./build/*"); do
    obj_file="build/${c_file#./}"
    obj_file="${obj_file%.c}.o"
    mkdir -p "$(dirname "$obj_file")"
    echo " -> $c_file"
    gcc -m32 -ffreestanding -fno-pie -fno-pic -c "$c_file" -o "$obj_file"
done

echo "[3/3] Linking..."
BOOT_OBJ="build/boot/boot.o"

if [ ! -f "$BOOT_OBJ" ]; then
    echo "[ERROR] build/boot/boot.o not found!"
    exit 1
fi

OTHER_OBJS=$(find build -name "*.o" ! -path "$BOOT_OBJ")

echo "Objects to link: $BOOT_OBJ $OTHER_OBJS"

ld -m elf_i386 -N -Ttext 0x7c00 --oformat binary -o build/myMBR.bin $BOOT_OBJ $OTHER_OBJS

size=$(stat -c%s build/myMBR.bin)
echo "Current size: $size bytes"

if [ $size -gt 510 ]; then
    echo "[ERROR] Code too big for MBR! (Max 510 bytes)"
    exit 1
fi

truncate -s 510 build/myMBR.bin

printf '\x55\xAA' >> build/myMBR.bin

echo "[OK] Boot signature added."
echo "-----------------------------------------"

echo "Starting QEMU..."
qemu-system-x86_64 -drive format=raw,file=build/myMBR.bin
