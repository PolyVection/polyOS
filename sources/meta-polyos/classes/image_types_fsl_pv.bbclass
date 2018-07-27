inherit image_types

DEPENDS =+ "zip-native"

IMAGE_BOOTLOADER ?= "u-boot"

# Handle u-boot suffixes
UBOOT_SUFFIX ?= "bin"
UBOOT_SUFFIX_SDCARD ?= "${UBOOT_SUFFIX}"

# Boot partition volume id
BOOTDD_VOLUME_ID ?= "Boot ${MACHINE}"

# Boot partition size [in KiB]
BOOT_SPACE ?= "8192"

# Barebox environment size [in KiB]
BAREBOX_ENV_SPACE ?= "512"

# Set alignment to 4MB [in KiB]
IMAGE_ROOTFS_ALIGNMENT = "4096"

do_image_sdcard[depends] = "parted-native:do_populate_sysroot \
                            dosfstools-native:do_populate_sysroot \
                            mtools-native:do_populate_sysroot \
                            virtual/kernel:do_deploy \
                            ${@d.getVar('IMAGE_BOOTLOADER', True) and d.getVar('IMAGE_BOOTLOADER', True) + ':do_deploy' or ''}"

SDCARD = "${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.sdcard"

SDCARD_GENERATION_COMMAND_mx6ul = "generate_imx_sdcard"
SDCARD_GENERATION_COMMAND_mx7 = "generate_imx_sdcard"
SDCARD_GENERATION_COMMAND_vf = "generate_imx_sdcard"


#
# Generate the boot image with the boot scripts and required Device Tree
# files
_generate_boot_image() {

}

#
# Create an image that can by written onto a SD card using dd for use
# with i.MX SoC family
#
# External variables needed:
#   ${SDCARD_ROOTFS}    - the rootfs image to incorporate
#   ${IMAGE_BOOTLOADER} - bootloader to use {u-boot, barebox}
#
# The disk layout used is:
#
#    0                      -> IMAGE_ROOTFS_ALIGNMENT         - reserved to bootloader (not partitioned)
#    IMAGE_ROOTFS_ALIGNMENT -> BOOT_SPACE                     - kernel and other data
#    BOOT_SPACE             -> SDIMG_SIZE                     - rootfs
#
#                                                     Default Free space = 1.3x
#                                                     Use IMAGE_OVERHEAD_FACTOR to add more space
#                                                     <--------->
#            4MiB           512MiB              512MiB               512MiB
# <-----------------> <----------------> <----------------> <------------------->
#  ------------------ ------------------ ------------------ ---------------------
# | ROOTFS_ALIGNMENT | ROOTFS_1_SIZE    | ROOTFS_2_SIZE    |     DATAFS_SIZE    |
#  ------------------ ------------------ ------------------ ---------------------
# ^                  ^                  ^                  ^                    ^
# |                  |                  |                  |                    |
# 0                 4M               4M + 512M     4M + 512M + 512M   4M + 512M + 512M + 512M

# partition size [in KiB]
ROOTFS_ALIGNMENT 	= "4000"
ROOTFS_1_SIZE 		= "1000000"
RFSA_RFS1		= "1004000"
ROOTFS_2_SIZE		= "1000000"
RFSA_RFS1_RFS2		= "2004000"
DATAFS_SIZE 		= "1000000"
RFSA_RFS1_RFS2_DFS	= "3004000"

POLYOS_FOLDER = "${DEPLOY_DIR_IMAGE}/_PolyOS_release"
POLYOS_VER = "${DEPLOY_DIR_IMAGE}/_PolyOS_release/${DISTRO_VERSION}"
POLYOS_VER_REL = "${DEPLOY_DIR_IMAGE}/_PolyOS_release/${DISTRO_VERSION}/release"
REL_URL_GH = "https://github.com/polyvection/meta-polyvection/releases/download/${DISTRO_VERSION}"
REL_URL_PV = "https://polyvection.com/software/polyos/voltastream0"

# UGLY HACK #
COLLECTOR = "${DEPLOY_DIR_IMAGE}/_COLLECTOR"
UBOOT_DIR_POLY = "${DEPLOY_DIR_IMAGE}/u-boot-voltastream.imx"

ROOT_EXT4 = "${IMGDEPLOYDIR}/polyos-image-voltastream.ext4"
TAR_EXT4 = "${IMGDEPLOYDIR}/polyos-image-voltastream.tar.bz2"
EXT4_COL = "${COLLECTOR}/polyos-image-voltastream.ext4"
SD_COL = "${COLLECTOR}/polyos-image-voltastream.rootfs.sdcard"
TAR_COL = "${COLLECTOR}/polyos-image-voltastream.tar.bz2"



generate_imx_sdcard () {

	cp ${UBOOT_DIR_POLY} ${COLLECTOR}
	cp ${ROOT_EXT4} ${COLLECTOR}
	cp ${TAR_EXT4} ${COLLECTOR}

	# Create partition table
	parted -s ${SD_COL} mklabel msdos

	# software bank 1
	parted -s ${SD_COL} unit KiB mkpart primary $(expr  ${IMAGE_ROOTFS_ALIGNMENT} \+ ${BOOT_SPACE_ALIGNED}) $(expr ${IMAGE_ROOTFS_ALIGNMENT} \+ ${BOOT_SPACE_ALIGNED} \+ $ROOTFS_SIZE)

	parted ${SD_COL} print

	# Burn bootloader
    dd if=${UBOOT_DIR_POLY} of=${SD_COL} conv=notrunc seek=2 bs=512

	# Burn Partition
	#dd if=${WORKDIR}/boot.img of=${SDCARD} conv=notrunc,fsync seek=1 bs=$(expr ${IMAGE_ROOTFS_ALIGNMENT} \* 1024)
	#dd if=${SDCARD_ROOTFS} of=${SDCARD} conv=notrunc,fsync seek=1 bs=$(expr ${BOOT_SPACE_ALIGNED} \* 1024 + ${IMAGE_ROOTFS_ALIGNMENT} \* 1024)

	#e2label ${SDCARD_ROOTFS} "root1" 
	e2label ${EXT4_COL} "root1"

	# Burn Partition
	dd if=${EXT4_COL} of=${SD_COL} conv=notrunc,fsync seek=1 bs=$(expr ${BOOT_SPACE_ALIGNED} \* 1024 + ${IMAGE_ROOTFS_ALIGNMENT} \* 1024)



##########################################
### GENERATE POLYOS IMAGES AND CHKSUMS ###
##########################################

	# Create PolyOS release folder
	mkdir -p ${POLYOS_FOLDER}

	# Create subfolder for version
	mkdir -p ${POLYOS_VER}
	
	# Create subfolder for compressed files
	mkdir -p ${POLYOS_VER_REL}



#######################
### GENERATE UPDATE ###
#######################


	# Remove old tar
	rm -f ${POLYOS_VER_REL}/polyos_${DISTRO_VERSION}_update.tar.gz

	# Compress EXT4 image to polyos_x.x.x.x_update.tar.gz
	cp ${COLLECTOR}/polyos-image-voltastream.ext4 ${POLYOS_VER_REL}/polyos_${DISTRO_VERSION}_update.ext4
	tar -zcvf ${POLYOS_VER_REL}/polyos_${DISTRO_VERSION}_update.tar.gz \
			${POLYOS_VER_REL}/polyos_${DISTRO_VERSION}_update.ext4

	# Remove Temp copy of ext4
	rm -f ${POLYOS_VER_REL}/polyos_${DISTRO_VERSION}_update.ext4

	# Generate sha256 for polyos_x.x.x.x_update.tar.gz
	DL_SUM=`sha256sum ${POLYOS_VER_REL}/polyos_${DISTRO_VERSION}_update.tar.gz | cut -d " " -f1`
	
	# Write sha256 for polyos_x.x.x.x_update.tar.gz to polyos_x.x.x.x_update.sha256
	echo ${DL_SUM} > ${POLYOS_VER}/polyos_${DISTRO_VERSION}_update.sha256



################################
### GENERATE FLASHABLE SDIMG ###
################################
	
	# Remove old zip
	rm -f ${POLYOS_VER_REL}/polyos_${DISTRO_VERSION}_sdcard.zip

	# Temp copy of .rootfs.sdcard
	cp ${SD_COL} ${POLYOS_VER_REL}/polyos_${DISTRO_VERSION}_sdcard.img
	
	# Compress SDCARD image to polyos_x.x.x.x_sdcard.zip
	zip -j ${POLYOS_VER_REL}/polyos_${DISTRO_VERSION}_sdcard.zip \
		${POLYOS_VER_REL}/polyos_${DISTRO_VERSION}_sdcard.img

	# Remove Temp copy of .rootfs.sdcard and ext4
	rm -f ${POLYOS_VER_REL}/polyos_${DISTRO_VERSION}_sdcard.img

	# Generate sha256 for polyos_x.x.x.x_sdcard.tar.bz2
	DL_SUM=`sha256sum ${POLYOS_VER_REL}/polyos_${DISTRO_VERSION}_sdcard.zip | cut -d " " -f1`

	# Write sha256 for polyos_x.x.x.x_sdcard.zip to polyos_x.x.x.x_update.sha256
	echo ${DL_SUM} > ${POLYOS_VER}/polyos_${DISTRO_VERSION}_sdcard.sha256

}



IMAGE_CMD_sdcard () {
	if [ -z "${SDCARD_ROOTFS}" ]; then
		bberror "SDCARD_ROOTFS is undefined. It needs to be defined."
		exit 1
	fi

	mkdir -p ${COLLECTOR} 

	# Align boot partition and calculate total SD card image size
    BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE} + ${IMAGE_ROOTFS_ALIGNMENT} - 1)
    BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE_ALIGNED} - ${BOOT_SPACE_ALIGNED} % ${IMAGE_ROOTFS_ALIGNMENT})
    SDCARD_SIZE=$(expr ${IMAGE_ROOTFS_ALIGNMENT} + ${BOOT_SPACE_ALIGNED} + $ROOTFS_SIZE + ${IMAGE_ROOTFS_ALIGNMENT})

	# Initialize a sparse file
	dd if=/dev/zero of=${SD_COL} bs=1 count=0 seek=$(expr 1024 \* ${SDCARD_SIZE})

	${SDCARD_GENERATION_COMMAND}
}

# The sdcard requires the rootfs filesystem to be built before using
# it so we must make this dependency explicit.
IMAGE_TYPEDEP_sdcard += "${@d.getVar('SDCARD_ROOTFS', 1).split('.')[-1]}"
IMAGE_TYPEDEP_sdcard += "tar.bz2"

# In case we are building for i.MX23 or i.MX28 we need to have the
# image stream built before the sdcard generation
IMAGE_TYPEDEP_sdcard += " \
    ${@bb.utils.contains('IMAGE_FSTYPES', 'uboot-mxsboot-sdcard', 'uboot-mxsboot-sdcard', '', d)} \
    ${@bb.utils.contains('IMAGE_FSTYPES', 'barebox-mxsboot-sdcard', 'barebox-mxsboot-sdcard', '', d)} \
"



ZIMAGE_PV = "${DEPLOY_DIR_IMAGE}/zImage"
DTB_PV_VS0 = "${DEPLOY_DIR_IMAGE}/zImage-imx6ull-voltastream0.dtb"
DTB_PV_VSA1 = "${DEPLOY_DIR_IMAGE}/zImage-imx6ull-voltastream-amp1.dtb"
DTB_PV_VSM1_0006 = "${DEPLOY_DIR_IMAGE}/zImage-imx6ull-vsm1-0006.dtb"
DTB_PV_VSM1_0007 = "${DEPLOY_DIR_IMAGE}/zImage-imx6ull-vsm1-0007.dtb"



my_postprocess_function() {

    cp ${DTB_PV_VS0} ${IMAGE_ROOTFS}/boot/imx6ull-voltastream0.dtb
    cp ${DTB_PV_VSA1} ${IMAGE_ROOTFS}/boot/imx6ull-voltastream-amp1.dtb
    cp ${DTB_PV_VSM1_0006} ${IMAGE_ROOTFS}/boot/imx6ull-vsm1-0006.dtb
    cp ${DTB_PV_VSM1_0007} ${IMAGE_ROOTFS}/boot/imx6ull-vsm1-0007.dtb
    #cp ${ZIMAGE_PV} ${IMAGE_ROOTFS}/boot/zImage
    echo ${DISTRO_VERSION} > ${IMAGE_ROOTFS}/polyos_version
    echo " " > ${IMAGE_ROOTFS}/etc/motd
    echo "### PolyOS ${DISTRO_VERSION} ###" >> ${IMAGE_ROOTFS}/etc/motd
    echo " " >> ${IMAGE_ROOTFS}/etc/motd
    echo "-----------------------------------------------" >> ${IMAGE_ROOTFS}/etc/motd
    echo "Use polyos-setup to configure WiFi and audio." >> ${IMAGE_ROOTFS}/etc/motd
    echo "-----------------------------------------------" >> ${IMAGE_ROOTFS}/etc/motd
    echo " " >> ${IMAGE_ROOTFS}/etc/motd

    echo "" > ${IMAGE_ROOTFS}/etc/shadow.new;
    sed 's%^root:[^:]*:%root:$1$68/DNc6J$tYRixcyRBumznKiQWiEaq.:%' \
        < ${IMAGE_ROOTFS}/etc/shadow \
        > ${IMAGE_ROOTFS}/etc/shadow.new;\
    mv ${IMAGE_ROOTFS}/etc/shadow.new ${IMAGE_ROOTFS}/etc/shadow ;
    #openssl passwd -1 -salt $(openssl rand -base64 6) polyvection

}


ROOTFS_POSTPROCESS_COMMAND_append = " \
  my_postprocess_function; \
"

