SUMMARY = "PolyOS RESTful API"
SECTION = "base"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690"

PROVIDES += "polyos-restapi"

SRC_URI = " \
	file://polycommand.js \
	file://polyos-restapi.js \
	file://polylog.js \
	file://polyrouter.js \
	file://polyserver.js \
	file://polysettings.js \
	file://polysource.js \
	file://polyos-restapi.service \
	"

S = "${WORKDIR}"

do_install () {

	install -d ${D}${sbindir}/polyos-restapi
	install -m 0755 ${WORKDIR}/polycommand.js ${D}${sbindir}/polyos-restapi/
	install -m 0755 ${WORKDIR}/polyos-restapi.js ${D}${sbindir}/polyos-restapi/
	install -m 0755 ${WORKDIR}/polylog.js ${D}${sbindir}/polyos-restapi/
	install -m 0755 ${WORKDIR}/polyrouter.js ${D}${sbindir}/polyos-restapi/
	install -m 0755 ${WORKDIR}/polyserver.js ${D}${sbindir}/polyos-restapi/
	install -m 0755 ${WORKDIR}/polysettings.js ${D}${sbindir}/polyos-restapi/
	install -m 0755 ${WORKDIR}/polysource.js ${D}${sbindir}/polyos-restapi/

	install -d ${D}${systemd_system_unitdir}
    	install -m 0644 ${WORKDIR}/polyos-restapi.service ${D}${systemd_system_unitdir}
}

inherit systemd

FILES_${PN} += "${sbindir}/polyos-restapi/*"
SYSTEMD_SERVICE_${PN} = "polyos-restapi.service"

