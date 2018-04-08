FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

IMX_PATCH = " file://0001-hciattach-add-QCA9377-Tuffello-support.patch \
"

SRC_URI_append_mx6 = "${IMX_PATCH}"
SRC_URI_append_mx7 = "${IMX_PATCH}"

PACKAGE_ARCH_mx6 = "${MACHINE_SOCARCH}"
PACKAGE_ARCH_mx7 = "${MACHINE_SOCARCH}"
