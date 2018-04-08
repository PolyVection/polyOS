# Copyright (C) 2013-2016 PolyVection

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
DESCRIPTION = "Wireless firmware for WiLink8 module on PolyVection boards."

PROVIDES += "wireless-firmware-ti"
RDEPENDS_${PN} = "uim"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690 \
                    file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = "file://ti-connectivity/TIInit_11.8.32.bts \
	   file://ti-connectivity/wl18xx-conf.bin \
	   file://ti-connectivity/wl18xx-fw-4.bin \
	   file://ti-connectivity/LICENCE.ti-connectivity \
	   "
S = "${WORKDIR}"

do_install () {
	install -d ${D}/lib/firmware/ti-connectivity/
	cp ${WORKDIR}/ti-connectivity/TIInit_11.8.32.bts ${D}/lib/firmware/ti-connectivity/
	cp ${WORKDIR}/ti-connectivity/wl18xx-conf.bin ${D}/lib/firmware/ti-connectivity/
	cp ${WORKDIR}/ti-connectivity/wl18xx-fw-4.bin ${D}/lib/firmware/ti-connectivity/
	cp ${WORKDIR}/ti-connectivity/LICENCE.ti-connectivity ${D}/lib/firmware/ti-connectivity/
}

FILES_${PN} = " \
	/lib/firmware/ti-connectivity/TIInit_11.8.32.bts \
	/lib/firmware/ti-connectivity/wl18xx-conf.bin \
	/lib/firmware/ti-connectivity/wl18xx-fw-4.bin \
	/lib/firmware/ti-connectivity/LICENCE.ti-connectivity \
    "

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(mx6|mx6ul|mx7)"
