LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690"
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

SRC_URI = 	"file://wpa-wlan0.service"

inherit systemd

do_install () {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/wpa-wlan0.service ${D}${systemd_system_unitdir}
}

SYSTEMD_SERVICE_${PN} = "wpa-wlan0.service"
