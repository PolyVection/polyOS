LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690"


do_install () {
    install -d ${D}${systemd_system_unitdir}/
    install -m 0644 ${WORKDIR}/serial-getty@ttyGS0.service ${D}${systemd_system_unitdir}
    ln -s /lib/systemd/system/serial-getty@.service ${D}${systemd_system_unitdir}/getty.target.wants/serial-getty\@ttyGS0.service
}


