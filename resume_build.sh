#!/bin/bash
# Resume Rio-OS build after fixing dependencies
set -e
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

RIO="~/ws/Rio-OS"
cd "$RIO"

echo "Resuming Rio-OS build at $(date)"

# Clean the failed kernel build stamp so it retries
rm -f "$RIO/output/build/linux-6.6.70/.stamp_built"

# Resume the build from where it left off
make -C "$RIO/buildroot" O="$RIO/output" 2>&1

echo ""
echo "================================================"
echo "  BUILD COMPLETE at $(date)"
echo "================================================"
ls -lah "$RIO/output/images/" 2>/dev/null || echo "No images found"
