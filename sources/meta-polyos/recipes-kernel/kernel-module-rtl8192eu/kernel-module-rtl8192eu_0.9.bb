DESCRIPTION = "Out-of-tree kernel module for Realtek RTL8192EU"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690 \
                    file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRCBRANCH = "realtek-4.4.x_PV"
SRCREV = "${AUTOREV}"
SRC_URI = "git://github.com/PolyVection/rtl8192eu-linux.git;branch=${SRCBRANCH} "


S = "${WORKDIR}/git"

inherit module 

EXTRA_OECONF += "--with-linux=${STAGING_KERNEL_DIR} \
    "

EXTRA_OEMAKE += 'SYSROOT="${D}"'


