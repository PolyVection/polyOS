
DESCRIPTION = "Shairport-Sync - AirPlay audio player"
DEPENDS = "libdaemon libconfig popt avahi"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSES;md5=926dc741301c0ecd801c957fa35c097a"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

SRCREV = "6c55d89abf243582ff77f833f522dfa217f9988d"
SRC_URI = 	"git://github.com/mikebrady/shairport-sync.git \
		file://shairport-sync.conf \
		file://shairport-sync.in"

S = "${WORKDIR}/git"

INITSCRIPT_NAME = "shairport-sync"
INITSCRIPT_PARAMS = "defaults 90 10"


do_configure_prepend() {	
	cp ${WORKDIR}/shairport-sync.in ${WORKDIR}/git/scripts/shairport-sync.in
}

do_compile_prepend() {
	cp ${WORKDIR}/shairport-sync.conf ${WORKDIR}/build/scripts/shairport-sync.conf		
}

EXTRA_OECONF_append = " --sysconfdir=/etc --with-alsa --with-avahi --with-ssl=openssl --with-metadata --with-systemv"
RDEPENDS_${PN} = "alsa-lib openssl popt initscripts avahi-daemon"

inherit autotools pkgconfig update-rc.d

CONFFILES_${PN} += "${sysconfdir}/init.d/shairport-sync"
