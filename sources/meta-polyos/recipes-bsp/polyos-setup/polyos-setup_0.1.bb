SUMMARY = "PolyOS Setup"
SECTION = "base"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

PROVIDES += "polyos-setup"

SRC_URI = 	"file://polyos-setup \
		 file://polywifi.py \
		 file://polyaudio.py \
		 file://polyterminal.py \
		"
S = "${WORKDIR}"

do_install () {

	install -d ${D}${sbindir}
	install -m 0755 ${WORKDIR}/polyos-setup ${D}${sbindir}/
	install -m 0755 ${WORKDIR}/polywifi.py ${D}${sbindir}/
	install -m 0755 ${WORKDIR}/polyaudio.py ${D}${sbindir}/
	install -m 0755 ${WORKDIR}/polyterminal.py ${D}${sbindir}/
}

FILES_${PN} += "${sbindir}/polyos-setup"
FILES_${PN} += "${sbindir}/polywifi.py"
FILES_${PN} += "${sbindir}/polyaudio.py"
FILES_${PN} += "${sbindir}/polyterminal.py"
RDEPENDS_${PN} = "python3 python3-argparse python3-fcntl python3-subprocess python3-signal python3-argparse python3-json python3-re python3-pygobject python3-dbus"


