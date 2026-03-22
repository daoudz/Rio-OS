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
