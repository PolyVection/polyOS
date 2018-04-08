SUMMARY = "SNAPCAST"
SECTION = "base"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690"

DEPENDS = "alsa-lib avahi libvorbis flac alsa-utils"
PROVIDES += "snapcast"

SRC_URI = 	"file://snapserver_0.11.1 \
		file://snapclient_0.11.1 \
		file://snapclient.service \
		file://snapserver.service \
		file://snapserver.etc_default \
		file://snapclient.etc_default \
	   	"

S = "${WORKDIR}"

do_install () {

	install -d ${D}${bindir}
	install -m 0755 ${WORKDIR}/snapserver_0.11.1 ${D}${bindir}/snapserver
	install -m 0755 ${WORKDIR}/snapclient_0.11.1 ${D}${bindir}/snapclient

    	install -d ${D}${systemd_system_unitdir}
    	install -m 0644 ${WORKDIR}/snapserver.service ${D}${systemd_system_unitdir}
	install -m 0644 ${WORKDIR}/snapclient.service ${D}${systemd_system_unitdir}

	install -d ${D}${sysconfdir}/default/
	install -m 0755 ${WORKDIR}/snapserver.etc_default  ${D}${sysconfdir}/default/snapserver
	install -m 0755 ${WORKDIR}/snapclient.etc_default  ${D}${sysconfdir}/default/snapclient
	
}

FILES_${PN} += "${bindir}/snapserver"
FILES_${PN} += "${bindir}/snapclient"
FILES_${PN} += "${systemd_system_unitdir}/snapserver.service"
FILES_${PN} += "${systemd_system_unitdir}/snapclient.service"
FILES_${PN} += "${sysconfdir}/default/snapclient"
FILES_${PN} += "${sysconfdir}/default/snapserver"
