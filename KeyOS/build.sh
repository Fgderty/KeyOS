#!/bin/bash
set -e
set -o pipefail

echo "========================================="
echo " Building KeyOS (Universal Pipeline) "
echo "========================================="

rm -rf build
mkdir -p build

#==============================================
#	1. COMPILATION ASM
#==============================================
echo "[1/3] Compiling all ASM files..."
for asm_file in $(find . -name "*.asm" -not -path "./build/*"); do
    obj_file="build/${asm_file#./}"
    obj_file="${obj_file%.asm}.o"
    mkdir -p "$(dirname "$obj_file")"
    echo " -> $asm_file"
    nasm -f elf32 "$asm_file" -o "$obj_file"
done

#==============================================
#   2. COMPILATION C
#==============================================
echo "[2/3] Compiling all C files..."
for c_file in $(find . -name "*.c" -not -path "./build/*"); do
    obj_file="build/${c_file#./}"
    obj_file="${obj_file%.c}.o"
    mkdir -p "$(dirname "$obj_file")"
    echo " -> $c_file"
    gcc -m32 -ffreestanding -fno-pie -fno-pic -fno-stack-protector -mno-sse -mno-sse2 -mpreferred-stack-boundary=2 -c "$c_file" -o "$obj_file"
done

#==============================================
#   3. LINKING
#==============================================
echo "[3/3] Linking..."

BOOT_OBJ="build/boot/boot.o"
if [ ! -f "$BOOT_OBJ" ]; then
    echo "[ERROR] build/boot/boot.o not found!"
    exit 1
fi

echo "Linking bootloader (0x7c00)..."

ld -m elf_i386 -N -Ttext 0x7c00 --oformat binary -o build/boot.bin $BOOT_OBJ

size=$(stat -c%s build/boot.bin)
echo "Current size: $size bytes"

if [ $size -gt 510 ]; then
    echo "[ERROR] Bootloader too big! (Max 510 bytes)"
    exit 1
fi

truncate -s 510 build/boot.bin
printf '\x55\xAA' >> build/boot.bin
echo "[OK] Boot signature added (512 bytes total)."

echo " -> Linking kernel (0x1000)..."

KERNEL_OBJS=$(find build/kernel -name "*.o" | sort)

ld -m elf_i386 -T linker.ld --oformat binary -o build/kernel.bin $KERNEL_OBJS

echo "[OK] Kernel linked. Size: $(stat -c%s build/kernel.bin) bytes."

echo "Creating final disk image..."

cat build/boot.bin build/kernel.bin > build/KeyOS.img
truncate -s 1440K build/KeyOS.img

echo "-----------------------------------------"
echo "[OK] Build successful!"
echo "-----------------------------------------"

echo "Starting QEMU..."
qemu-system-x86_64 -drive format=raw,file=build/KeyOS.img
