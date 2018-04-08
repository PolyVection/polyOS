SUMMARY = "PolyOS Line-In"
SECTION = "base"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690"

PROVIDES += "polyos-linein"

SRC_URI = 	"file://polyos-linein \
		 file://polyos-linein.service \
		"
S = "${WORKDIR}"

do_install () {

	install -d ${D}${sbindir}
	install -m 0755 ${WORKDIR}/polyos-linein ${D}${sbindir}/

	install -d ${D}${systemd_system_unitdir}
    	install -m 0644 ${WORKDIR}/polyos-linein.service ${D}${systemd_system_unitdir}
}

FILES_${PN} += "${sbindir}/polyos-linein"
FILES_${PN} += "${systemd_system_unitdir}/polyos-linein.service"



