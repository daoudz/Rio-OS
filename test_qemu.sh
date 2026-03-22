#!/bin/bash
# Test Rio-OS in QEMU with a FAT test disk
set -e
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

RIO="~/ws/Rio-OS"

# Create a small FAT32 test disk with some files
echo "Creating test FAT32 disk image..."
dd if=/dev/zero of=/tmp/fat_test.img bs=1M count=32
mkfs.vfat -F 32 -n "TESTDRIVE" /tmp/fat_test.img

# Mount it and add test files
mkdir -p /tmp/fat_mnt
sudo mount -o loop /tmp/fat_test.img /tmp/fat_mnt
sudo mkdir -p /tmp/fat_mnt/Documents /tmp/fat_mnt/Photos /tmp/fat_mnt/Music
echo "Hello from Rio-OS test!" | sudo tee /tmp/fat_mnt/readme.txt > /dev/null
echo "Test document 1" | sudo tee /tmp/fat_mnt/Documents/test1.txt > /dev/null
echo "Test document 2" | sudo tee /tmp/fat_mnt/Documents/test2.txt > /dev/null
echo "Photo placeholder" | sudo tee /tmp/fat_mnt/Photos/photo1.txt > /dev/null
sudo umount /tmp/fat_mnt
rmdir /tmp/fat_mnt
echo "Test disk created with sample files."

echo ""
echo "Testing Rio-OS in QEMU..."
echo "The VM will boot. Press Ctrl+C to stop after verifying."
echo ""

# Run QEMU in non-graphical mode to capture output
# -nographic mode so we can see console output
timeout 30 qemu-system-x86_64 \
    -cdrom "$RIO/output/images/rootfs.iso9660" \
    -hdb /tmp/fat_test.img \
    -m 256 \
    -nographic \
    -no-reboot \
    -serial mon:stdio 2>&1 || true

echo ""
echo "QEMU test complete."
