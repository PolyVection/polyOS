
DESCRIPTION = "Shairport-Sync - AirPlay audio player"
DEPENDS = "libdaemon libconfig popt avahi alsa-utils alsa-lib"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSES;md5=9f329b7b34fcd334fb1f8e2eb03d33ff"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

SRCREV = "7eed53914653f8ef3196e81d7f59496bbe553254"
SRC_URI = 	"git://github.com/mikebrady/shairport-sync.git \
		file://shairport-sync_3.2.0.conf \
		file://shairport-sync.in \
		file://Makefile.am \
		file://shairport-sync.service"

S = "${WORKDIR}/git"

INITSCRIPT_NAME = "shairport-sync"
INITSCRIPT_PARAMS = "defaults 90 10"


do_configure_prepend() {	
	cp ${WORKDIR}/shairport-sync.in ${WORKDIR}/git/scripts/shairport-sync.in
	rm -f ${WORKDIR}/git/Makefile.am
	cp ${WORKDIR}/Makefile.am ${WORKDIR}/git/Makefile.am
}

do_compile_prepend() {
	cp ${WORKDIR}/shairport-sync_3.2.0.conf ${WORKDIR}/build/scripts/shairport-sync.conf		
}

do_install_append() {

    	install -d ${D}${systemd_system_unitdir}
    	install -m 0644 ${WORKDIR}/shairport-sync.service ${D}${systemd_system_unitdir}
}

EXTRA_OECONF_append = " --sysconfdir=/etc --with-configfiles --with-alsa --with-avahi --with-ssl=openssl --with-metadata"
RDEPENDS_${PN} = "openssl popt initscripts avahi-daemon"

inherit autotools pkgconfig update-rc.d systemd

CONFFILES_${PN} += "${sysconfdir}/init.d/shairport-sync"
SYSTEMD_SERVICE_${PN} = "shairport-sync.service"
