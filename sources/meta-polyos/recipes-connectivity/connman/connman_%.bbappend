FILESEXTRAPATHS_prepend := "${THISDIR}/connman:"
SRC_URI += "file://connman.service.in"

inherit systemd

do_install_append() {
	install -d ${D}${systemd_system_unitdir}
    	install -m 0644 ${WORKDIR}/connman.service.in ${D}${systemd_system_unitdir}/connman.service
}

SYSTEMD_SERVICE_${PN} = "connman.service"
