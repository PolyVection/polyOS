SECTION = "multimedia"
SUMMARY = "A stable, documented, asynchronous API library for interfacing MPD in the C, C++ & Objective C languages"
HOMEPAGE = "http://www.musicpd.org/libs/libmpdclient/"


LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=06b9dfd2f197dc514d8ef06549684b77"

SRC_URI="http://www.musicpd.org/download/libmpdclient/2/libmpdclient-${PV}.tar.xz"
SRC_URI[md5sum] = "63a3c3f757f073be6f225b1ecc2b8116"
SRC_URI[sha256sum] = "5115bd52bc20a707c1ecc7587e6389c17305348e2132a66cf767c62fc55ed45d"

EXTRA_OECONF="--disable-documentation"

inherit meson

do_install_append () {
    find "${D}" -name 'vala' -exec rm -fr {} +
}
