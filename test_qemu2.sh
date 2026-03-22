#!/bin/bash
set -x
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

RIO="~/ws/Rio-OS"

# Create disk image
dd if=/dev/zero of=$RIO/fat_test.img bs=1M count=32
mkfs.vfat -F 32 -n 'TESTDRIVE' $RIO/fat_test.img

# Boot QEMU pointing to the ISO and the new disk
timeout 30 qemu-system-x86_64 \
    -cdrom $RIO/output/images/rootfs.iso9660 \
    -boot d \
    -drive file=$RIO/fat_test.img,format=raw \
    -m 256 \
    -nographic \
    -no-reboot \
    -serial mon:stdio 2>&1
