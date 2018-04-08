FILESEXTRAPATHS_prepend := "${THISDIR}/openssh:"
SRC_URI += "file://init"
SRC_URI += "file://sshdgenkeys.service"


do_install_append() {
	#install -d ${D}${sysconfdir}/init.d
	#install -m 0755 ${WORKDIR}/init ${D}${sysconfdir}/init.d/sshd
	install -d ${D}${systemd_system_unitdir}
    	install -m 0644 ${WORKDIR}/sshdgenkeys.service ${D}${systemd_system_unitdir}
}
