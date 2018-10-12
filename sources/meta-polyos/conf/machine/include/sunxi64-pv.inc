SOC_FAMILY ??= ""
include conf/machine/include/soc-family.inc

PREFERRED_PROVIDER_virtual/kernel ?= "linux-mainline-pv"
PREFERRED_PROVIDER_u-boot ?= "u-boot-mainline-pv"
PREFERRED_PROVIDER_virtual/bootloader ?= "u-boot-mainline-pv"

KERNEL_IMAGETYPE ?= "Image"

IMAGE_CLASSES += "image_types_sunix_pv"
IMAGE_FSTYPES += "ext4 tar.gz sdcard"

MACHINE_EXTRA_RRECOMMENDS = "kernel-modules"

UBOOT_LOCALVERSION = "-g${@d.getVar('SRCPV', True).partition('+')[2][0:7]}"

UBOOT_ENTRYPOINT ?= "0x40008000"
UBOOT_LOADADDRESS ?= "0x400080OB00"

UBOOT_BINARY ?= "u-boot.itb"
SPL_BINARY ?= "spl/sunxi-spl.bin"

SERIAL_CONSOLE ?= "115200 ttyS0"
MACHINE_FEATURES ?= "alsa apm keyboard rtc serial screen usbgadget usbhost vfat"
