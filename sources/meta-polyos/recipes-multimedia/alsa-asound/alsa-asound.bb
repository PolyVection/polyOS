SUMMARY = "PolyOS WiFi connector"
SECTION = "base"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690"

PROVIDES += "alsa-asound"

SRC_URI = "file://asound.conf"
S = "${WORKDIR}"

do_install () {

	install -d ${D}${sysconfdir}
	install -m 0755 ${WORKDIR}/asound.conf ${D}${sysconfdir}/
}

FILES_${PN} += "${sbindir}/alsa-asound"


