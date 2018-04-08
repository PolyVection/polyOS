# Freescale imx extra configuration 
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

RDEPENDS_${PN} += " bash "

do_install_append() {

    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/inittab ${D}${sysconfdir}/inittab
    echo "\nmxc0:12345:respawn:/bin/start_getty 115200 ttymxc0" >> ${D}${sysconfdir}/inittab
    echo "1:12345:respawn:/sbin/getty 38400 tty1" >> ${D}${sysconfdir}/inittab
    echo "2:12345:respawn:/bin/start_getty 115200 ttyGS0" >> ${D}${sysconfdir}/inittab
}

PACKAGE_ARCH_mx6 = "${MACHINE_ARCH}"
