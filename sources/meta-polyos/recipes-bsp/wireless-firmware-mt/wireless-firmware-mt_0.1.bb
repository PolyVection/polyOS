# Copyright (C) 2013-2016 PolyVection

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
DESCRIPTION = "Wireless firmware for MediaTek modules on PolyVection boards."

PROVIDES += "wireless-firmware-mt"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690 \
                    file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = "file://mt7601u.bin \
	   "
S = "${WORKDIR}"

do_install () {
	install -d ${D}/lib/firmware/
	cp ${WORKDIR}/mt7601u.bin ${D}/lib/firmware/
}

FILES_${PN} = " \
	/lib/firmware/mt7601u.bin \
    "

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(mx6|mx6ul|mx7)"
