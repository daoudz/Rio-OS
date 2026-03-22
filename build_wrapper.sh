#!/bin/bash
# Rio-OS Build Wrapper - cleans PATH to avoid Windows spaces issue
set -e

# Clean PATH: keep only standard Linux directories
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

cd ~/Rio-OS

echo "================================================"
echo "  Building Rio-OS (clean PATH environment)"
echo "  $(date)"
echo "================================================"

# Run defconfig
echo "[1/2] Loading defconfig..."
make -C buildroot O="$(pwd)/output" BR2_EXTERNAL="$(pwd)" \
    defconfig BR2_DEFCONFIG="$(pwd)/configs/buildroot_defconfig"

# Run full build
echo ""
echo "[2/2] Building (this will take 30-60 minutes)..."
make -C buildroot O="$(pwd)/output" 2>&1

ISO="output/images/rootfs.iso9660"
if [ -f "$ISO" ]; then
    echo ""
    echo "================================================"
    echo "  BUILD SUCCESSFUL!"
    echo "  ISO: $ISO ($(du -h "$ISO" | cut -f1))"
    echo "================================================"
else
    echo "ERROR: ISO not found. Check build.log for details."
    exit 1
fi
