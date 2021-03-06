SUMMARY = "LMS - Logitech Media Server"
SECTION = "base"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

DEPENDS = "alsa-lib avahi libvorbis flac alsa-utils lame faad2 sox perl"
RDEPENDS_${PN} = "perl"
PROVIDES += "slimserver"

SRC_URI =   "\
            git://github.com/Logitech/slimserver.git;protocol=https;branch=public/7.9 \
            file://CPAN/* \
            file://slimserver.service \
            "

SRCREV = "${AUTOREV}"

#INSANE_SKIP_${PN} = "ldflags"
#INSANE_SKIP_${PN}-dev = "ldflags"
TARGET_CC_ARCH += "${LDFLAGS}"
do_package_qa[noexec] = "1"

S = "${WORKDIR}/git"

# EXCLUDE_FROM_WORLD = "1"

inherit useradd systemd

USERADD_PACKAGES = "${PN} "
USERADD_PARAM_${PN} = "-u 1202 -d /usr/bin/slimserver -r -s /bin/bash -P 'squeezeboxserver' squeezeboxserver"
GROUPADD_PARAM_${PN} = "-g 900 nogroup"

do_install () {

     #mkdir ${S}/CPAN_used
    # slimserver doesn't work with current DBIx/SQL versions, use bundled copies
     #mv ${S}/CPAN/DBIx ${S}/CPAN/SQL ${S}/CPAN_used
    rm -rf ${S}/CPAN/arch/5.10
    rm -rf ${S}/CPAN/arch/5.12
    rm -rf ${S}/CPAN/arch/5.14
    rm -rf ${S}/CPAN/arch/5.16
    rm -rf ${S}/CPAN/arch/5.18
    rm -rf ${S}/CPAN/arch/5.20
    rm -rf ${S}/CPAN/arch/5.22
    rm -rf ${S}/CPAN/arch/5.26
    rm -rf ${S}/CPAN/arch/5.8
    mv ${S}/CPAN/arch/5.24/aarch64-linux-thread-multi ${S}/CPAN/arch/5.24/aarch64-linux
    rm -rf ${S}/CPAN/arch/5.24/i386-linux-thread-multi-64int
    rm -rf ${S}/CPAN/arch/5.24/x86_64-linux-thread-multi
    rm -rf ${S}/CPAN/arch/5.24/arm-linux-gnueabihf-thread-multi-64int
    rm -rf ${S}/Bin/MSWin32-x86-multi-thread
    # rm -rf ${S}/Bin/aarch64-linux
    rm -rf ${S}/Bin/arm-linux
    rm -rf ${S}/Bin/darwin-x86_64
    rm -rf ${S}/Bin/darwin
    rm -rf ${S}/Bin/i386-freebsd-64int
    rm -rf ${S}/Bin/i386-linux
    rm -rf ${S}/Bin/i86pc-solaris-thread-multi-64int
    rm -rf ${S}/Bin/powerpc-linux
    rm -rf ${S}/Bin/sparc-linux
    rm -rf ${S}/Bin/x86_64-linux

     #touch ${S}/Makefile.PL
     #mv ${S}/lib ${S}/tmp
     #mkdir -p ${S}/lib/perl5/site_perl
     #mv ${S}/CPAN_used/* ${S}/lib/perl5/site_perl
     #cp -rf ${S}/tmp/* ${S}/lib/perl5/site_perl

    install -d ${D}${bindir}/slimserver
    cp -r ${S}/* ${D}${bindir}/slimserver/
    cp -r ${WORKDIR}/CPAN/* ${D}${bindir}/slimserver/CPAN/

    chown -R squeezeboxserver ${D}${bindir}/slimserver/
    chgrp -R nogroup ${D}${bindir}/slimserver/

}

do_install_append() {

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/slimserver.service ${D}${systemd_system_unitdir}
}

SYSTEMD_SERVICE_${PN} = "slimserver.service"

FILES_${PN} += "${bindir}/slimserver/*"
FILES_${PN} += "${systemd_system_unitdir}/slimserver.service"
