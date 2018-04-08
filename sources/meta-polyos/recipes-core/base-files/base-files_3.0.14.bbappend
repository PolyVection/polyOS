FILESEXTRAPATHS_prepend := "${THISDIR}/base-files:"

do_install_append(){
	install -m 0755 -d ${D}/mnt/data
}
