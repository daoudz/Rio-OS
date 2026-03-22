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
