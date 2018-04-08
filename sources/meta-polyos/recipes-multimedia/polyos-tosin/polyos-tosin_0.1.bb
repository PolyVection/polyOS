SUMMARY = "PolyOS TOSLINK-In"
SECTION = "base"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690"

PROVIDES += "polyos-tosin"

SRC_URI = 	"file://polyos-tosin \
		 file://polyos-tosin.service \
		"
S = "${WORKDIR}"

do_install () {

	install -d ${D}${sbindir}
	install -m 0755 ${WORKDIR}/polyos-tosin ${D}${sbindir}/

	install -d ${D}${systemd_system_unitdir}
    	install -m 0644 ${WORKDIR}/polyos-tosin.service ${D}${systemd_system_unitdir}
}

FILES_${PN} += "${sbindir}/polyos-tosin"
FILES_${PN} += "${systemd_system_unitdir}/polyos-tosin.service"



