SUMMARY = "PolyOS Updater"
SECTION = "base"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690"

PROVIDES += "polyos-updater"

SRC_URI = "file://polyos-updater"
S = "${WORKDIR}"

do_install () {

	install -d ${D}${sbindir}
	install -m 0755 ${WORKDIR}/polyos-updater ${D}${sbindir}/
}

FILES_${PN} += "${sbindir}/polyos-updater"
RDEPENDS_${PN} = "wget tar bzip2 util-linux"


