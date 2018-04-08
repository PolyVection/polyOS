SUMMARY = "PolyOS OpenSND"
SECTION = "base"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690"

PROVIDES += "polyos-opensnd"

SRC_URI = "file://silence.wav \
	   file://polyos-opensnd.service"

S = "${WORKDIR}"

do_install () {

	install -d ${D}${sysconfdir}/wav
	install -m 0755 ${WORKDIR}/silence.wav ${D}${sysconfdir}/wav/

	install -d ${D}${systemd_system_unitdir}
    	install -m 0644 ${WORKDIR}/polyos-opensnd.service ${D}${systemd_system_unitdir}
}

inherit systemd

FILES_${PN} += "${sysconfdir}/wav/silence.wav"
SYSTEMD_SERVICE_${PN} = "polyos-opensnd.service"

