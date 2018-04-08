# Copyright (C) 2013-2016 PolyVection

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
DESCRIPTION = "Systemd network files."

PROVIDES += "systemd-network"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690 \
                    file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = "file://20-wired.network \
	   file://25-wireless.network \
	  "
S = "${WORKDIR}"

do_install () {
	install -d ${D}${sysconfdir}/systemd/network/
 	install -m 0644 ${WORKDIR}/*.network ${D}${sysconfdir}/systemd/network/
}

FILES_${PN} += "{sysconfdir}/systemd/network/*"

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(mx6|mx6ul|mx7)"
