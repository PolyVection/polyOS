do_install_append() {

	ln -sf ${systemd_unitdir}/system/serial-getty@.service \
					${D}${sysconfdir}/systemd/system/getty.target.wants/serial-getty@ttyGS0.service

}
