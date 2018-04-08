SUMMARY = "Lightweight headless squeezebox emulator"
HOMEPAGE = "https://code.google.com/p/squeezelite/"
LICENSE = "GPLv3"
SRC_URI = "git://github.com/ralph-irving/squeezelite.git \
	   file://squeezelite.service "
SRCREV = "58d0892d9bdfc9507e5e099b845585bc065375f6"

S = "${WORKDIR}/git"
DEPENDS = "alsa-lib flac libvorbis libmad mpg123 faad2"
RDEPENDS_${PN} = "flac libvorbis libmad mpg123 faad2"

LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=4a6efe45e946fda532470a3da05195c3"
LDFLAGS += "-lasound -lpthread -lm -lrt -ldl -lFLAC -lmad -lvorbisfile -lfaad -lmpg123"
CFLAGS_append = "-DLINKALL"

FILES_${PN} = "${bindir}/squeezelite"

inherit systemd

do_install() {
        install -d ${D}${bindir}
        install -m 0755 ${B}/${PN} ${D}${bindir}/

    	install -d ${D}${systemd_system_unitdir}
    	install -m 0644 ${WORKDIR}/squeezelite.service ${D}${systemd_system_unitdir}
}

SYSTEMD_SERVICE_${PN} = "squeezelite.service"
