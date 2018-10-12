# Copyright (C) 2013-2017 PolyVection

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
DESCRIPTION = "Wireless firmware for Qualcomm based hardware"

PROVIDES += "wireless-firmware-qcom"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690 \
                    file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = "file://fw1.in \
	   file://fw2.in \
	   file://fw3.in \
	   file://fw4.in \
           file://fw5.in \
	   file://fwbt1.in \
           file://fwbt2.in \
	   file://WCNSS_cfg.dat \
	   file://WCNSS_qcom_cfg.usb.ini \
	   file://notice.txt \
	   "
S = "${WORKDIR}"

do_install () {
	install -d ${D}/lib/firmware/wlan/
	cp ${WORKDIR}/fw1.in ${D}/lib/firmware/bdwlan30.bin
	cp ${WORKDIR}/fw2.in ${D}/lib/firmware/otp30.bin
	cp ${WORKDIR}/fw3.in ${D}/lib/firmware/qwlan30.bin
	cp ${WORKDIR}/fw4.in ${D}/lib/firmware/utf30.bin
	cp ${WORKDIR}/fw5.in ${D}/lib/firmware/utfbd30.bin
	cp ${WORKDIR}/notice.txt ${D}/lib/firmware/
	cp ${WORKDIR}/WCNSS_cfg.dat ${D}/lib/firmware/wlan/cfg.dat
	cp ${WORKDIR}/WCNSS_qcom_cfg.usb.ini ${D}/lib/firmware/wlan/qcom_cfg.ini

	install -d ${D}/lib/firmware/qca/
	cp ${WORKDIR}/fwbt1.in ${D}/lib/firmware/qca/tfbtnv11.bin
	cp ${WORKDIR}/fwbt2.in ${D}/lib/firmware/qca/tfbtfw11.tlv
}

FILES_${PN} = " \
	/lib/firmware/bdwlan30.bin \
	/lib/firmware/otp30.bin \
	/lib/firmware/qwlan30.bin \
	/lib/firmware/utf30.bin \
	/lib/firmware/utfbd30.bin \
	/lib/firmware/qca/tfbtnv11.bin \
	/lib/firmware/qca/tfbtfw11.tlv \
	/lib/firmware/notice.txt \
	/lib/firmware/wlan/cfg.dat \
	/lib/firmware/wlan/qcom_cfg.ini \
    "

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(mx6|mx6ul|mx7|voltastream-a64)"
