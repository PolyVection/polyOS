# Copyright (C) 2013-2016 PolyVection

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
DESCRIPTION = "Wireless firmware for Realtek based hardware"

PROVIDES += "wireless-firmware-rtl"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690 \
                    file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = "file://rtlwifi/rtl8192cfw.bin \
	   file://rtlwifi/rtl8192cfwU.bin \
	   file://rtlwifi/rtl8192cfwU_B.bin \
	   file://rtlwifi/rtl8192cufw.bin \
           file://rtlwifi/rtl8192cufw_A.bin \
	   file://rtlwifi/rtl8192cufw_B.bin \
	   file://rtlwifi/rtl8192cufw_TMSC.bin \
	   file://rtlwifi/rtl8192defw.bin \
	   file://rtlwifi/rtl8192eefw.bin \
	   file://rtlwifi/rtl8192eu_ap_wowlan.bin \
	   file://rtlwifi/rtl8192eu_nic.bin \
	   file://rtlwifi/rtl8192eu_wowlan.bin \
	   file://rtlwifi/rtl8192sefw.bin \
	   file://rtlwifi/LICENCE.rtlwifi_firmware.txt \
	   "
S = "${WORKDIR}"

do_install () {
	install -d ${D}/lib/firmware/rtlwifi/
	cp ${WORKDIR}/rtlwifi/rtl8192cfw.bin ${D}/lib/firmware/rtlwifi/
	cp ${WORKDIR}/rtlwifi/rtl8192cfwU.bin ${D}/lib/firmware/rtlwifi/
	cp ${WORKDIR}/rtlwifi/rtl8192cfwU_B.bin ${D}/lib/firmware/rtlwifi/
	cp ${WORKDIR}/rtlwifi/rtl8192cufw.bin ${D}/lib/firmware/rtlwifi/
	cp ${WORKDIR}/rtlwifi/rtl8192cufw_A.bin ${D}/lib/firmware/rtlwifi/
	cp ${WORKDIR}/rtlwifi/rtl8192cufw_B.bin ${D}/lib/firmware/rtlwifi/
	cp ${WORKDIR}/rtlwifi/rtl8192cufw_TMSC.bin ${D}/lib/firmware/rtlwifi/
	cp ${WORKDIR}/rtlwifi/rtl8192defw.bin ${D}/lib/firmware/rtlwifi/
	cp ${WORKDIR}/rtlwifi/rtl8192eefw.bin ${D}/lib/firmware/rtlwifi/
	cp ${WORKDIR}/rtlwifi/rtl8192eu_ap_wowlan.bin ${D}/lib/firmware/rtlwifi/
	cp ${WORKDIR}/rtlwifi/rtl8192eu_nic.bin ${D}/lib/firmware/rtlwifi/
	cp ${WORKDIR}/rtlwifi/rtl8192eu_wowlan.bin ${D}/lib/firmware/rtlwifi/
	cp ${WORKDIR}/rtlwifi/rtl8192sefw.bin ${D}/lib/firmware/rtlwifi/
	cp ${WORKDIR}/rtlwifi/LICENCE.rtlwifi_firmware.txt ${D}/lib/firmware/rtlwifi/
}

FILES_${PN} = " \
	/lib/firmware/rtlwifi/rtl8192cfw.bin \
	/lib/firmware/rtlwifi/rtl8192cfwU.bin \
	/lib/firmware/rtlwifi/rtl8192cfwU_B.bin \
	/lib/firmware/rtlwifi/rtl8192cufw.bin \
	/lib/firmware/rtlwifi/rtl8192cufw_A.bin \
	/lib/firmware/rtlwifi/rtl8192cufw_B.bin \
	/lib/firmware/rtlwifi/rtl8192cufw_TMSC.bin \
	/lib/firmware/rtlwifi/rtl8192defw.bin \
	/lib/firmware/rtlwifi/rtl8192eefw.bin \
	/lib/firmware/rtlwifi/rtl8192eu_ap_wowlan.bin \
	/lib/firmware/rtlwifi/rtl8192eu_nic.bin \
	/lib/firmware/rtlwifi/rtl8192eu_wowlan.bin \
	/lib/firmware/rtlwifi/rtl8192sefw.bin \
	/lib/firmware/rtlwifi/LICENCE.rtlwifi_firmware.txt \
    "

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(mx6|mx6ul|mx7)"
