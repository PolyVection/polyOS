SUMMARY = "PolyOS HostName"
SECTION = "base"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690"

PROVIDES += "polyos-hostname"

SRC_URI = "file://polyos-hostname \
	   file://polyos-hostname.service"

S = "${WORKDIR}"

do_install () {

	install -d ${D}${sbindir}
	install -m 0755 ${WORKDIR}/polyos-hostname ${D}${sbindir}/

	install -d ${D}${systemd_system_unitdir}
    	install -m 0644 ${WORKDIR}/polyos-hostname.service ${D}${systemd_system_unitdir}
}

inherit systemd

FILES_${PN} += "${sbindir}/polyos-hostname"
SYSTEMD_SERVICE_${PN} = "polyos-hostname.service"

