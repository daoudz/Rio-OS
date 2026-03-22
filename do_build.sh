#!/bin/bash
# Rio-OS full build script - runs in clean WSL environment
set -e

# Clean PATH to avoid Windows spaces issue
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

RIO="$HOME/Rio-OS"
cd "$RIO"

echo "================================================"
echo "  Building Rio-OS"
echo "  $(date)"
echo "================================================"

# Clean previously failed extraction if any
if [ -d "output/build/linux-headers-6.6.70" ] && [ ! -f "output/build/linux-headers-6.6.70/.stamp_extracted" ]; then
    echo "Cleaning failed linux-headers extraction..."
    rm -rf "output/build/linux-headers-6.6.70"
fi

if [ -d "output/build/linux-6.6.70" ] && [ ! -f "output/build/linux-6.6.70/.stamp_extracted" ]; then
    echo "Cleaning failed linux extraction..."
    rm -rf "output/build/linux-6.6.70"
fi

# Run buildroot directly (bypass our top-level Makefile to avoid path issues)
echo ""
echo "Loading defconfig..."
make -C "$RIO/buildroot" O="$RIO/output" BR2_EXTERNAL="$RIO" \
    defconfig BR2_DEFCONFIG="$RIO/configs/buildroot_defconfig"

echo ""
echo "Starting full build..."
make -C "$RIO/buildroot" O="$RIO/output"

echo ""
echo "================================================"
echo "  BUILD COMPLETE!"
echo "================================================"
ls -lah "$RIO/output/images/" 2>/dev/null || echo "No images found"
