DESCRIPTION = "Command-line (scriptable) Music Player Daemon (mpd) Client"
HOMEPAGE = "http://www.musicpd.org/mpc.shtml"
SECTION = "console/multimedia"

PR = "r2"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=751419260aa954499f7abaabaa882bbe"

SRC_URI = "https://www.musicpd.org/download/mpc/0/mpc-${PV}.tar.xz \
          "

EXTRA_OECONF = "--with-iconv-libraries=${STAGING_LIBDIR} \
		--with-iconv-includes=${STAGING_INCDIR}"

inherit autotools pkgconfig
RDEPENDS_${PN} = "libmpdclient"
DEPENDS = "libmpdclient"

do_install_append() {
    #install ${WORKDIR}/next_mpd_playlist.sh ${D}${bindir}
    #chmod +x ${D}${bindir}/next_mpd_playlist.sh

    #install -d ${D}/${localstatedir}/lib/mpd
    #touch ${D}/${localstatedir}/lib/mpd/current_playlist_index
    #chown mpd:mpd ${D}/${localstatedir}/lib/mpd/current_playlist_index
    #chmod ug+w ${D}/${localstatedir}/lib/mpd/current_playlist_index
}

FILES_${PN} += "${localstatedir}/lib/mpd/*"

SRC_URI[md5sum] = "e9cfaf17ab1db54dba4df4b08aa0db3f"
SRC_URI[sha256sum] = "a4337d06c85dc81a638821d30fce8a137a58d13d510be34a11c1cce95cabc547"


