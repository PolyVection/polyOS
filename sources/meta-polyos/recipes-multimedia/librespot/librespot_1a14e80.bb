SUMMARY = "Open source client library for Spotify"
SECTION = "base"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690"

DEPENDS = "alsa-lib"
PROVIDES += "librespot"

SRC_URI = "file://librespot-v20170916-1a14e80 \
	   file://librespot.service"

S = "${WORKDIR}"

inherit systemd

do_install () {

	install -d ${D}${sbindir}
	install -m 0755 ${WORKDIR}/librespot-v20170916-1a14e80 ${D}${sbindir}/librespot

    	install -d ${D}${systemd_system_unitdir}
    	install -m 0644 ${WORKDIR}/librespot.service ${D}${systemd_system_unitdir}
}

FILES_${PN} += "${sbindir}/librespot"

SYSTEMD_SERVICE_${PN} = "librespot.service"
