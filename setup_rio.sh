#!/bin/bash
set -e

RIO=~/Rio-OS

# === Buildroot defconfig ===
cat > "$RIO/configs/buildroot_defconfig" << 'EOF'
BR2_x86_64=y
BR2_x86_corei7=y
BR2_TOOLCHAIN_BUILDROOT_MUSL=y
BR2_LINUX_KERNEL=y
BR2_LINUX_KERNEL_CUSTOM_VERSION=y
BR2_LINUX_KERNEL_CUSTOM_VERSION_VALUE="6.6.70"
BR2_LINUX_KERNEL_USE_CUSTOM_CONFIG=y
BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE="$(BR2_EXTERNAL_RIO_PATH)/configs/linux-rio.config"
BR2_LINUX_KERNEL_BZIMAGE=y
BR2_TARGET_ROOTFS_CPIO=y
BR2_TARGET_ROOTFS_CPIO_GZIP=y
BR2_TARGET_ROOTFS_ISO9660=y
BR2_TARGET_ROOTFS_ISO9660_BOOT_MENU="$(BR2_EXTERNAL_RIO_PATH)/configs/isolinux.cfg"
BR2_TARGET_ROOTFS_ISO9660_HYBRID=y
BR2_TARGET_SYSLINUX=y
BR2_INIT_BUSYBOX=y
BR2_ROOTFS_OVERLAY="$(BR2_EXTERNAL_RIO_PATH)/overlay"
BR2_SYSTEM_DHCP=""
BR2_TARGET_GENERIC_GETTY=y
BR2_TARGET_GENERIC_GETTY_PORT="tty1"
BR2_SYSTEM_BIN_SH_BUSYBOX=y
BR2_PACKAGE_MC=y
BR2_PACKAGE_NCURSES=y
BR2_PACKAGE_NCURSES_WCHAR=y
BR2_PACKAGE_E2FSPROGS=y
BR2_PACKAGE_DOSFSTOOLS=y
BR2_PACKAGE_DOSFSTOOLS_FSCK_FAT=y
BR2_PACKAGE_DOSFSTOOLS_MKFS_FAT=y
BR2_PACKAGE_EXFAT=y
BR2_PACKAGE_EXFAT_UTILS=y
BR2_PACKAGE_UTIL_LINUX=y
BR2_PACKAGE_UTIL_LINUX_MOUNT=y
BR2_PACKAGE_UTIL_LINUX_LSBLK=y
BR2_PACKAGE_UTIL_LINUX_BLKID=y
BR2_PACKAGE_UTIL_LINUX_FINDMNT=y
EOF
echo "Created buildroot_defconfig"

# === ISOLINUX config ===
cat > "$RIO/configs/isolinux.cfg" << 'EOF'
PROMPT 0
TIMEOUT 30
DEFAULT rio

SAY ========================================
SAY    Rio-OS - Portable File Manager
SAY ========================================
SAY

LABEL rio
  MENU LABEL Rio-OS
  KERNEL /boot/bzImage
  APPEND initrd=/boot/rootfs.cpio.gz console=tty1 quiet
EOF
echo "Created isolinux.cfg"

# === Init script ===
cat > "$RIO/overlay/etc/init.d/rcS" << 'INITEOF'
#!/bin/sh

# Rio-OS Init Script
# Mount essential filesystems
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
mkdir -p /dev/pts /dev/shm
mount -t devpts devpts /dev/pts
mount -t tmpfs tmpfs /dev/shm
mount -t tmpfs tmpfs /tmp
mount -t tmpfs tmpfs /run

# Set up console
clear

# Display splash
if [ -f /usr/share/rio/splash.txt ]; then
    cat /usr/share/rio/splash.txt
    sleep 2
fi

# Create mount directory
mkdir -p /mnt

# Enable kernel hotplug via mdev
echo /sbin/mdev > /proc/sys/kernel/hotplug
mdev -s

# Scan and mount FAT/exFAT partitions
echo "Scanning drives..."
DRIVE_NUM=0
for DEV in $(blkid -o device 2>/dev/null); do
    [ -b "$DEV" ] || continue
    FSTYPE=$(blkid -s TYPE -o value "$DEV" 2>/dev/null)
    case "$FSTYPE" in
        vfat|fat|msdos|exfat)
            LABEL=$(blkid -s LABEL -o value "$DEV" 2>/dev/null)
            DRIVE_NUM=$((DRIVE_NUM + 1))
            if [ -n "$LABEL" ]; then
                MOUNT_NAME="drive${DRIVE_NUM}_${LABEL}"
            else
                MOUNT_NAME="drive${DRIVE_NUM}"
            fi
            mkdir -p "/mnt/$MOUNT_NAME"
            if mount -t "$FSTYPE" "$DEV" "/mnt/$MOUNT_NAME" 2>/dev/null; then
                echo "  Mounted $DEV -> /mnt/$MOUNT_NAME ($FSTYPE)"
            else
                rmdir "/mnt/$MOUNT_NAME" 2>/dev/null
            fi
            ;;
        ntfs)
            echo "  Skipped $DEV (NTFS)"
            ;;
    esac
done

echo ""
echo "Drive scan complete. Starting file manager..."
sleep 1

# Set TERM for proper display
export TERM=linux
export HOME=/root

# Start Midnight Commander in dual-pane mode on /mnt
exec mc /mnt /mnt
INITEOF
chmod +x "$RIO/overlay/etc/init.d/rcS"
echo "Created init script"

# === mdev.conf ===
cat > "$RIO/overlay/etc/mdev.conf" << 'EOF'
# Provide user, group, and mode information for devices
sd[a-z].* 0:0 660
mmcblk.* 0:0 660
nvme.* 0:0 660
EOF
echo "Created mdev.conf"

# === Norton Commander style MC skin ===
cat > "$RIO/overlay/etc/mc/skins/norton.ini" << 'EOF'
[skin]
    description = Norton Commander Classic
    256colors = false

[core]
    _default_ = lightgray;blue
    selected = black;cyan
    marked = yellow;blue
    markselect = yellow;cyan
    gauge = white;black
    input = black;cyan
    inputunchanged = gray;cyan
    inputmark = cyan;black
    disabled = gray;blue
    reverse = black;lightgray
    commandlinemark = black;lightgray
    header = yellow;blue

[dialog]
    _default_ = black;lightgray
    dfocus = black;cyan
    dhotnormal = blue;lightgray
    dhotfocus = blue;cyan
    dtitle = blue;lightgray
    dcustom = black;lightgray

[error]
    _default_ = white;red
    errdfocus = black;lightgray
    errdhotnormal = yellow;red
    errdhotfocus = yellow;lightgray
    errdtitle = yellow;red

[filehighlight]
    directory = white;
    executable = green;
    symlink = lightgray;
    stalelink = brightred;
    device = brightmagenta;
    special = black;
    core = red;
    temp = gray;
    archive = brightmagenta;
    doc = brown;
    source = cyan;
    media = green;
    graph = green;

[menu]
    _default_ = black;lightgray
    menusel = white;black
    menuhot = yellow;lightgray
    menuhotsel = yellow;black
    menuinactive = lightgray;lightgray

[popupmenu]
    _default_ = black;lightgray
    menusel = white;black
    menutitle = blue;lightgray

[buttonbar]
    hotkey = black;lightgray
    button = black;cyan

[statusbar]
    _default_ = black;cyan

[help]
    _default_ = black;lightgray
    helpitalic = red;lightgray
    helpbold = blue;lightgray
    helplink = black;cyan
    helpslink = yellow;lightgray
    helptitle = blue;lightgray

[editor]
    _default_ = lightgray;blue
    editbold = yellow;green
    editmarked = black;cyan
    editwhitespace = brightblue;blue
    editlinestate = white;cyan
    bookmark = white;red
    bookmarkfound = black;green

[viewer]
    _default_ = lightgray;blue
    viewbold = ;
    viewunderline = ;
    viewselected = yellow;cyan

[diffviewer]
    changedline = white;blue
    changednew = red;blue
    changed = white;blue
    added = white;green
    removed = white;red

[widget-panel]
    sort-up-char = ^
    sort-down-char = v
    hiddenfiles-sign-show = .
    hiddenfiles-sign-hide = .
    history-prev-item-sign = <
    history-next-item-sign = >
    history-show-list-sign = ^
    filename-scroll-left-char = {
    filename-scroll-right-char = }
EOF
echo "Created Norton MC skin"

# === MC config ===
mkdir -p "$RIO/overlay/root/.config/mc"
cat > "$RIO/overlay/root/.config/mc/ini" << 'EOF'
[Midnight-Commander]
verbose=true
shell_patterns=true
auto_save_setup=true
auto_menu=false
use_internal_view=true
use_internal_edit=true
clear_before_exec=true
confirm_delete=true
confirm_overwrite=true
confirm_execute=false
confirm_exit=false
safe_delete=false
navigate_with_arrows=true
keybar_visible=true
message_visible=true
xterm_title=false
skin=norton
EOF
echo "Created MC config"

# === Splash screen ===
cat > "$RIO/overlay/usr/share/rio/splash.txt" << 'EOF'

    ██████╗ ██╗ ██████╗        ██████╗ ███████╗
    ██╔══██╗██║██╔═══██╗      ██╔═══██╗██╔════╝
    ██████╔╝██║██║   ██║█████╗██║   ██║███████╗
    ██╔══██╗██║██║   ██║╚════╝██║   ██║╚════██║
    ██║  ██║██║╚██████╔╝      ╚██████╔╝███████║
    ╚═╝  ╚═╝╚═╝ ╚═════╝       ╚═════╝ ╚══════╝

        Portable File Manager OS v1.0
        Scanning hardware...

EOF
echo "Created splash screen"

# === BR2_EXTERNAL structure (for Buildroot external tree) ===
cat > "$RIO/external.desc" << 'EOF'
name: RIO
desc: Rio-OS portable file manager
EOF

cat > "$RIO/external.mk" << 'EOF'
# Empty - we use standard Buildroot packages
EOF

cat > "$RIO/Config.in" << 'EOF'
# Empty - no custom packages yet
EOF
echo "Created BR2_EXTERNAL files"

# === Top-level Makefile ===
cat > "$RIO/Makefile" << 'MAKEEOF'
# Rio-OS Build Makefile
BUILDROOT_DIR := $(CURDIR)/buildroot
OUTPUT_DIR := $(CURDIR)/output
DEFCONFIG := $(CURDIR)/configs/buildroot_defconfig

.PHONY: all defconfig build clean menuconfig linux-menuconfig

all: build

defconfig:
	$(MAKE) -C $(BUILDROOT_DIR) O=$(OUTPUT_DIR) BR2_EXTERNAL=$(CURDIR) defconfig BR2_DEFCONFIG=$(DEFCONFIG)

build: defconfig
	$(MAKE) -C $(BUILDROOT_DIR) O=$(OUTPUT_DIR)

menuconfig:
	$(MAKE) -C $(BUILDROOT_DIR) O=$(OUTPUT_DIR) BR2_EXTERNAL=$(CURDIR) menuconfig

linux-menuconfig:
	$(MAKE) -C $(BUILDROOT_DIR) O=$(OUTPUT_DIR) linux-menuconfig

clean:
	rm -rf $(OUTPUT_DIR)
MAKEEOF
echo "Created Makefile"

# === Build script ===
cat > "$RIO/scripts/build.sh" << 'BUILDEOF'
#!/bin/bash
set -e
cd "$(dirname "$0")/.."

echo "================================================"
echo "  Building Rio-OS"
echo "================================================"
echo ""

# Clean previous output if requested
if [ "$1" = "clean" ]; then
    echo "Cleaning build..."
    make clean
fi

# Run full build
echo "Starting build (this may take 30-60 minutes on first run)..."
make all

ISO_PATH="output/images/rootfs.iso9660"
if [ -f "$ISO_PATH" ]; then
    echo ""
    echo "================================================"
    echo "  BUILD SUCCESSFUL!"
    echo "  ISO: $ISO_PATH"
    echo "  Size: $(du -h "$ISO_PATH" | cut -f1)"
    echo ""
    echo "  To burn to USB (Linux):"
    echo "    sudo dd if=$ISO_PATH of=/dev/sdX bs=4M status=progress"
    echo ""
    echo "  To test in QEMU:"
    echo "    qemu-system-x86_64 -cdrom $ISO_PATH -m 256"
    echo "================================================"
else
    echo "ERROR: ISO not found at $ISO_PATH"
    exit 1
fi
BUILDEOF
chmod +x "$RIO/scripts/build.sh"
echo "Created build script"

# === README ===
cat > "$RIO/README.md" << 'EOF'
# Rio-OS — Portable File Manager OS

A minimal, portable operating system that boots from USB and provides a Norton Commander-style dual-pane file manager. Supports FAT12/16/32 and exFAT filesystems.

## Features
- Boots on any x86/64 machine (BIOS)
- Norton Commander-style dual-pane file manager (Midnight Commander)
- FAT12/16/32 and exFAT read/write support
- Auto-detects and mounts drives on boot
- Full keyboard navigation
- Tiny footprint (< 50 MB)

## Building

### Prerequisites (Ubuntu/Debian)
```bash
sudo apt install build-essential gcc g++ make git bc flex bison \
  libncurses-dev unzip rsync cpio xorriso wget curl file libssl-dev \
  python3 perl
```

### Build
```bash
./scripts/build.sh
```

First build takes 30-60 minutes. The ISO will be at `output/images/rootfs.iso9660`.

### Test in QEMU
```bash
qemu-system-x86_64 -cdrom output/images/rootfs.iso9660 -m 256
```

### Burn to USB
```bash
sudo dd if=output/images/rootfs.iso9660 of=/dev/sdX bs=4M status=progress
```

## Keyboard Shortcuts (Midnight Commander)
| Key | Action |
|-----|--------|
| Tab | Switch panels |
| Enter | Open dir / execute file |
| F3 | View file |
| F4 | Edit file |
| F5 | Copy |
| F6 | Move |
| F7 | Create directory |
| F8 | Delete |
| F10 | Quit (reboot) |
| Insert | Select file |

## License
MIT
EOF
echo "Created README.md"

echo ""
echo "==========================================="
echo " All Rio-OS files created successfully!"
echo "==========================================="
ls -la "$RIO/"
