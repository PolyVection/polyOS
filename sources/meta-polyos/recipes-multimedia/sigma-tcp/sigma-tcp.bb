
DESCRIPTION = "Sigma-TCP for Sigma-Studio network config"
DEPENDS = "libconfig libxml2"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690 \
                    file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

SRCBRANCH = "dev"
SRCREV = "${AUTOREV}"
SRC_URI = "git://github.com/polyvection/sigma-tcp.git;branch=${SRCBRANCH} "
SRC_URI += "file://sigma-tcp.in"

S = "${WORKDIR}/git"

INITSCRIPT_NAME = "sigma-tcp"
INITSCRIPT_PARAMS = "defaults 80 10"

do_compile_prepend () {
	cp ${WORKDIR}/git/* ${WORKDIR}/build/
}

do_install_append () {
	install -d ${D}${sbindir}
	install -m 0755 ${WORKDIR}/build/sigma_tcp ${D}${sbindir}/

	install -d ${D}${sysconfdir}/init.d
	install -m 0755 ${WORKDIR}/sigma-tcp.in ${D}${sysconfdir}/init.d/sigma-tcp
	chmod a+x ${D}${sysconfdir}/init.d/sigma-tcp
}

FILES_${PN} += "${sbindir}/sigma_tcp"

inherit autotools pkgconfig update-rc.d

RDEPENDS_${PN} = "initscripts"
CONFFILES_${PN} += "${sysconfdir}/init.d/sigma-tcp"


