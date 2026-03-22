# Rio-OS 💿

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Size](https://img.shields.io/badge/ISO_Size-13_MB-g)

**Rio-OS** is an ultra-minimal, blazingly fast, and fully portable bootable operating system built exclusively to serve as a **Norton Commander-style File Manager**. 

Compiled down to a tiny **13 MB hybrid ISO**, Rio-OS can be burned to any USB flash drive and booted on almost any `x86_64` computer (BIOS or UEFI). It automatically mounts your local drives—including Windows FAT and exFAT formats—and drops you straight into a powerful, completely keyboard-driven dual-pane file manager interface.

## ✨ Features
- **Tiny Footprint:** The entire kernel, user space, and UI fits in a ~13 MB ISO.
- **Universal Compatibility:** Boots on modern UEFI and legacy BIOS `x86_64` systems.
- **Hardware Agnostic:** Built-in generic drivers for SATA AHCI, NVMe, MMC/SD, and all standard USB controllers (xHCI/EHCI/OHCI/UHCI).
- **Extensive Filesystem Support:** Natively auto-mounts `FAT12`, `FAT16`, `FAT32`, `vfat`, and `exFAT` drives dynamically using `mdev` hot-plugging.
- **Retro UI:** Boots straight into the highly-capable `Midnight Commander` heavily themed to look and behave like the classic *Norton Commander*, using a simple VGA text framebuffer. No heavy X11 or Wayland displays involved!

---

## 💾 Ready-to-Use Download

Don't want to build it yourself? You can download the latest compiled `rio-os.iso` directly from this repository:

**👉 [Download Rio-OS v1.0 (13 MB)](/Releases/rio-os.iso?raw=true)**

Use a tool like [Rufus](https://rufus.ie/en/) to burn the `.iso` to a USB flash drive (in **DD Image mode**) and boot it on any standard PC!

---

## 🚀 Building from Source

Rio-OS is built using **[Buildroot 2024.02.10](https://buildroot.org/)** and a heavily optimized custom Linux 6.6.70 kernel.

### Prerequisites (Ubuntu / Debian / WSL)
You will need a standard Linux build environment. On Ubuntu or WSL, install the dependencies:
```bash
sudo apt update
sudo apt install -y build-essential gcc make git ncurses-dev unzip \
                    xorriso wget bc cpio python3 python3-pip rsync \
                    libelf-dev gettext pkg-config qemu-system-x86
```

### Build Instructions
1. **Clone the repository:**
   ```bash
   git clone https://github.com/daoudz/Rio-OS.git
   cd Rio-OS
   ```
2. **Run the build environment setup script:**
   This script will automatically download the Buildroot matching version and configure the external overlays.
   ```bash
   bash setup_rio.sh
   ```
3. **Compile the OS:**
   Start the compilation process. *Note: this will build the cross-compilation toolchain from scratch and may take 30-60 minutes depending on your hardware.*
   ```bash
   bash do_build.sh
   # If the build gets interrupted, you can safely resume it with:
   # bash resume_build.sh
   ```
4. **Retrieve the ISO:**
   When finished, your compiled bootable image will be located at:
   ```text
   output/images/rootfs.iso9660
   ```

### Quick Test
Test out the ISO locally using QEMU before writing to a USB:
```bash
bash test_qemu.sh
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are always welcome! Since Rio-OS is a highly customized Buildroot environment, contributing takes a few specific forms:

### How to Contribute
1. **Fork the Project** on GitHub.
2. **Create a Feature Branch** (`git checkout -b feature/AmazingDriver`).
3. **Commit your Changes** (`git commit -m 'Add some AmazingDriver'`).
4. **Push to the Branch** (`git push origin feature/AmazingDriver`).
5. **Open a Pull Request**.

### Areas for Contribution
- **Kernel Drivers (`configs/linux-rio.config`):** 
  If Rio-OS fails to read a specific USB hub, storage controller, or keyboard array on newer hardware, you can submit a PR modifying the minimal kernel defconfig to include that exact driver. We aim to keep the kernel strictly below **8 MB**, so avoid adding broad/unnecessary networking or graphics drivers.
- **Midnight Commander Configurations (`Rio-OS-source/overlay/root/.config/mc/`):** 
  Improvements to the macro keys, Norton Commander color schemes, or specific `init` mounting behaviors (`Rio-OS-source/overlay/etc/init.d/rcS`).
- **Filesystem Enhancements:**
  Support for NTFS or APFS via read-only FUSE implementations, provided they do not heavily bloat the root userspace image.

### Updating Buildroot Configurations
If you wish to add new packages to the OS via `menuconfig`:
1. Run `make -C buildroot O=$PWD/output menuconfig`
2. Save your changes back to the tree using: `make -C buildroot O=$PWD/output savedefconfig`
3. Commit the changes made to `Rio-OS-source/configs/buildroot_defconfig`.

---

## 📜 License
Distributed under the MIT License. See `LICENSE` for more information.
