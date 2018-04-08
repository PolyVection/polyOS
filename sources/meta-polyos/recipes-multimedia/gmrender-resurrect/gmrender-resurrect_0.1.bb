
DESCRIPTION = "Gmedia Renderer - UPNP media renderer"
DEPENDS = "initscripts libdaemon libconfig libupnp gstreamer1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav alsa-lib"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=4325afd396febcb659c36b49533135d4"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

SRCREV = "f8afaff9a55c7d0693b76a4ff9f98c95632b5586"
SRC_URI = 	"git://github.com/PolyVection/gmrender-resurrect.git \
		file://gmediarenderer \
		file://gmediarenderer.service"

S = "${WORKDIR}/git"

INITSCRIPT_NAME = "gmediarenderer"
INITSCRIPT_PARAMS = "defaults 90 10"


do_configure_prepend() {	

}

do_compile_prepend() {
	
}

do_compile_append() {
	
}

do_install_append () {
	#install -d ${D}${sysconfdir}/init.d
	#install -m 0755 ${WORKDIR}/gmediarenderer  ${D}${sysconfdir}/init.d/

	install -d ${D}${systemd_system_unitdir}
    	install -m 0644 ${WORKDIR}/gmediarenderer.service ${D}${systemd_system_unitdir}
}

FILES_${PN} += "/usr/share/gmediarender/grender-64x64.png \
	       /usr/share/gmediarender/grender-128x128.png"

RDEPENDS_${PN} = "initscripts libdaemon libconfig libupnp gstreamer1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav"

inherit autotools pkgconfig update-rc.d systemd

CONFFILES_${PN} += "${sysconfdir}/init.d/gmediarenderer"
SYSTEMD_SERVICE_${PN} = "gmediarenderer.service"
