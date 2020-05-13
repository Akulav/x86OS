# x86OS
SIMPLE 16-BIT OS

EXISTING COMMANDS: HELP, user, clear, draw.

COMPILE WITH: 

#!/bin/sh
nasm -fbin bootloader.asm -o bootloader.bin
nasm -fbin kernel.asm -o kernel.bin
cat bootloader.bin kernel.bin > result.bin
dd if=/dev/zero of=1.raw bs=1k count=1440
dd if=result.bin of=1.img conv=notrunc
rm bootloader.bin
rm kernel.bin
rm result.bin
qemu-system-x86_64 -drive format=raw,file=1.img
rm 1.raw
rm 1.img
