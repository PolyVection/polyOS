inherit image_types

DEPENDS =+ "zip-native"

IMAGE_BOOTLOADER ?= "u-boot"

# Handle u-boot suffixes
UBOOT_SUFFIX ?= "bin"
UBOOT_SUFFIX_SDCARD ?= "${UBOOT_SUFFIX}"

#
# Handles i.MX mxs bootstream generation
#
MXSBOOT_NAND_ARGS ?= ""

# IMX Bootlets Linux bootstream
do_image_linux.sb[depends] += "elftosb-native:do_populate_sysroot \
                               imx-bootlets:do_deploy \
                               virtual/kernel:do_deploy"
IMAGE_LINK_NAME_linux.sb = ""
IMAGE_CMD_linux.sb () {
	kernel_bin="`readlink ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${MACHINE}.bin`"
	kernel_dtb="`readlink ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${MACHINE}.dtb || true`"
	linux_bd_file=imx-bootlets-linux.bd-${MACHINE}
	if [ `basename $kernel_bin .bin` = `basename $kernel_dtb .dtb` ]; then
		# When using device tree we build a zImage with the dtb
		# appended on the end of the image
		linux_bd_file=imx-bootlets-linux.bd-dtb-${MACHINE}
		cat $kernel_bin $kernel_dtb \
		    > $kernel_bin-dtb
		rm -f ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${MACHINE}.bin-dtb
		ln -s $kernel_bin-dtb ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${MACHINE}.bin-dtb
	fi

	# Ensure the file is generated
	rm -f ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.linux.sb
	(cd ${DEPLOY_DIR_IMAGE}; elftosb -z -c $linux_bd_file -o ${IMAGE_NAME}.linux.sb)

	# Remove the appended file as it is only used here
	rm -f ${DEPLOY_DIR_IMAGE}/$kernel_bin-dtb
}

# IMX Bootlets barebox bootstream
do_image_barebox-mxsboot-sdcard[depends] += "elftosb-native:do_populate_sysroot \
                                             u-boot-mxsboot-native:do_populate_sysroot \
                                             imx-bootlets:do_deploy \
                                             barebox:do_deploy"
IMAGE_CMD_barebox-mxsboot-sdcard () {
	barebox_bd_file=imx-bootlets-barebox_ivt.bd-${MACHINE}

	# Ensure the files are generated
	(cd ${DEPLOY_DIR_IMAGE}; rm -f ${IMAGE_NAME}.barebox.sb ${IMAGE_NAME}.barebox-mxsboot-sdcard; \
	 elftosb -f mx28 -z -c $barebox_bd_file -o ${IMAGE_NAME}.barebox.sb; \
	 mxsboot sd ${IMAGE_NAME}.barebox.sb ${IMAGE_NAME}.barebox-mxsboot-sdcard)
}

# U-Boot mxsboot generation to SD-Card
UBOOT_SUFFIX_SDCARD_mxs ?= "mxsboot-sdcard"
do_image_uboot-mxsboot-sdcard[depends] += "u-boot-mxsboot-native:do_populate_sysroot \
                                           u-boot:do_deploy"
IMAGE_CMD_uboot-mxsboot-sdcard = "mxsboot sd ${DEPLOY_DIR_IMAGE}/u-boot-${MACHINE}.${UBOOT_SUFFIX} \
                                             ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.uboot-mxsboot-sdcard"

do_image_uboot-mxsboot-nand[depends] += "u-boot-mxsboot-native:do_populate_sysroot \
                                         u-boot:do_deploy"
IMAGE_CMD_uboot-mxsboot-nand = "mxsboot ${MXSBOOT_NAND_ARGS} nand \
                                             ${DEPLOY_DIR_IMAGE}/u-boot-${MACHINE}.${UBOOT_SUFFIX} \
                                             ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.uboot-mxsboot-nand"

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

SDCARD_GENERATION_COMMAND_mxs = "generate_mxs_sdcard"
SDCARD_GENERATION_COMMAND_mx25 = "generate_imx_sdcard"
SDCARD_GENERATION_COMMAND_mx5 = "generate_imx_sdcard"
SDCARD_GENERATION_COMMAND_mx6ul = "generate_imx_sdcard"
SDCARD_GENERATION_COMMAND_mx7 = "generate_imx_sdcard"
SDCARD_GENERATION_COMMAND_vf = "generate_imx_sdcard"


#
# Generate the boot image with the boot scripts and required Device Tree
# files
_generate_boot_image() {
	local boot_part=$1

	# Create boot partition image
	BOOT_BLOCKS=$(LC_ALL=C parted -s ${SDCARD} unit b print \
	                  | awk "/ $boot_part / { print substr(\$4, 1, length(\$4 -1)) / 1024 }")

	# mkdosfs will sometimes use FAT16 when it is not appropriate,
	# resulting in a boot failure from SYSLINUX. Use FAT32 for
	# images larger than 512MB, otherwise let mkdosfs decide.
	if [ $(expr $BOOT_BLOCKS / 1024) -gt 512 ]; then
		FATSIZE="-F 32"
	fi

	rm -f ${WORKDIR}/boot.img
	mkfs.vfat -n "${BOOTDD_VOLUME_ID}" -S 512 ${FATSIZE} -C ${WORKDIR}/boot.img $BOOT_BLOCKS

	mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${MACHINE}.bin ::/${KERNEL_IMAGETYPE}

	# Copy boot scripts
	for item in ${BOOT_SCRIPTS}; do
		src=`echo $item | awk -F':' '{ print $1 }'`
		dst=`echo $item | awk -F':' '{ print $2 }'`

		mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/$src ::/$dst
	done

	# Copy device tree file
	if test -n "${KERNEL_DEVICETREE}"; then
		for DTS_FILE in ${KERNEL_DEVICETREE}; do
			DTS_BASE_NAME=`basename ${DTS_FILE} | awk -F "." '{print $1}'`
			if [ -e "${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${DTS_BASE_NAME}.dtb" ]; then
				kernel_bin="`readlink ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${MACHINE}.bin`"
				kernel_bin_for_dtb="`readlink ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${DTS_BASE_NAME}.dtb | sed "s,$DTS_BASE_NAME,${MACHINE},g;s,\.dtb$,.bin,g"`"
				if [ $kernel_bin = $kernel_bin_for_dtb ]; then
					mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${DTS_BASE_NAME}.dtb ::/${DTS_BASE_NAME}.dtb
				fi
			else
				bbfatal "${DTS_FILE} does not exist."
			fi
		done
	fi

	# Copy extlinux.conf to images that have U-Boot Extlinux support.
	if [ "${UBOOT_EXTLINUX}" = "1" ]; then
		mmd -i ${WORKDIR}/boot.img ::/extlinux
		mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/extlinux.conf ::/extlinux/extlinux.conf
	fi
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
	parted -s ${SD_COL} unit KiB mkpart primary ${ROOTFS_ALIGNMENT} $(expr ${RFSA_RFS1})

	# software bank 2
	parted -s ${SD_COL} unit KiB mkpart primary $(expr ${RFSA_RFS1}) $(expr ${RFSA_RFS1_RFS2})

	# data partition
	parted -s ${SD_COL} unit KiB mkpart primary $(expr  ${RFSA_RFS1_RFS2}) $(expr ${RFSA_RFS1_RFS2_DFS})

	parted ${SD_COL} print

	# Burn bootloader
	case "${IMAGE_BOOTLOADER}" in
		imx-bootlets)
		bberror "The imx-bootlets is not supported for i.MX based machines"
		exit 1
		;;
		u-boot)
		if [ -n "${SPL_BINARY}" ]; then
			dd if=${DEPLOY_DIR_IMAGE}/${SPL_BINARY} of=${SDCARD} conv=notrunc seek=2 bs=512
			dd if=${DEPLOY_DIR_IMAGE}/u-boot-${MACHINE}.${UBOOT_SUFFIX_SDCARD} of=${SDCARD} conv=notrunc seek=69 bs=1K
		else
			#dd if=${DEPLOY_DIR_IMAGE}/u-boot-${MACHINE}.${UBOOT_SUFFIX_SDCARD} of=${SDCARD} conv=notrunc seek=2 bs=512
			dd if=${UBOOT_DIR_POLY} of=${SD_COL} conv=notrunc seek=2 bs=512
		fi
		;;
		barebox)
		dd if=${DEPLOY_DIR_IMAGE}/barebox-${MACHINE}.bin of=${SDCARD} conv=notrunc seek=1 skip=1 bs=512
		dd if=${DEPLOY_DIR_IMAGE}/bareboxenv-${MACHINE}.bin of=${SDCARD} conv=notrunc seek=1 bs=512k
		;;
		"")
		;;
		*)
		bberror "Unknown IMAGE_BOOTLOADER value"
		exit 1
		;;
	esac

	#_generate_boot_image 1

	# Burn Partition
	#dd if=${WORKDIR}/boot.img of=${SDCARD} conv=notrunc,fsync seek=1 bs=$(expr ${IMAGE_ROOTFS_ALIGNMENT} \* 1024)
	#dd if=${SDCARD_ROOTFS} of=${SDCARD} conv=notrunc,fsync seek=1 bs=$(expr ${BOOT_SPACE_ALIGNED} \* 1024 + ${IMAGE_ROOTFS_ALIGNMENT} \* 1024)

	#e2label ${SDCARD_ROOTFS} "root1" 
	e2label ${EXT4_COL} "root1" 
	
	dd if=/dev/zero of=${COLLECTOR}/root2.img bs=1024 count=0 seek=${ROOTFS_2_SIZE}
	mke2fs -t ext4 -F ${COLLECTOR}/root2.img
	e2label ${COLLECTOR}/root2.img "root2"

	dd if=/dev/zero of=${COLLECTOR}/data.img bs=1024 count=0 seek=${DATAFS_SIZE}
	mke2fs -t ext4 -F ${COLLECTOR}/data.img
	e2label ${COLLECTOR}/data.img "data"

	#_generate_boot_image 1

	# Burn Partition
	dd if=${EXT4_COL} of=${SD_COL} conv=notrunc,fsync seek=1 bs=$(expr ${ROOTFS_ALIGNMENT} \* 1024)
	dd if=${COLLECTOR}/root2.img of=${SD_COL} conv=notrunc,fsync seek=1 bs=$(expr ${RFSA_RFS1} \* 1024)
	dd if=${COLLECTOR}/data.img of=${SD_COL} conv=notrunc,fsync seek=1 bs=$(expr ${RFSA_RFS1_RFS2} \* 1024)

#
#
#	GENERATE POLYOS IMAGES AND CHKSUMS
#
#

	# Create PolyOS release folder
	
	mkdir -p ${POLYOS_FOLDER}
	
	# Create subfolder for version
	
	mkdir -p ${POLYOS_VER}
	
	# Create subfolder for compressed files
	
	mkdir -p ${POLYOS_VER_REL}

	

	###### GENERATE UPDATE ######

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

	

	###### GENERATE FLASHABLE SDIMG ######
	
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
	
	###### GERERATE LINKS ######
	
	# Write new PolyOS version string to latest_version_version
	echo ${DISTRO_VERSION} > ${POLYOS_VER}/polyos_latest_version

	# Write link for polyos_x.x.x.x_update.tar.bz2 to polyos_x.x.x.x_update.link
	echo "${REL_URL_PV}/polyos_${DISTRO_VERSION}_update.tar.gz" > \
		${POLYOS_VER}/polyos_${DISTRO_VERSION}_update.link

	# Write link for polyos_x.x.x.x_sdcard.zip to polyos_x.x.x.x_sdcard.link
	echo "${REL_URL_PV}/polyos_${DISTRO_VERSION}_sdcard.zip" > \
		${POLYOS_VER}/polyos_${DISTRO_VERSION}_sdcard.link

	# Write link for latest_update to latest_update.link
	echo "${REL_URL_PV}/polyos_${DISTRO_VERSION}_update.tar.gz" > \
		${POLYOS_VER}/polyos_latest_update.link

	# Write link for latest_sdcard to latest_sdcard.link
	echo '<!DOCTYPE HTML>' > \
		${POLYOS_VER}/polyos_latest_sdcard.link
	echo '<html lang="en-US">' >> \
		${POLYOS_VER}/polyos_latest_sdcard.link
	echo '<head>' >> \
		${POLYOS_VER}/polyos_latest_sdcard.link
	echo '<meta charset="UTF-8">' >> \
		${POLYOS_VER}/polyos_latest_sdcard.link
	echo '<meta http-equiv="refresh" content="1; url=${REL_URL_PV}/polyos_${DISTRO_VERSION}_sdcard.zip">' >> \
		${POLYOS_VER}/polyos_latest_sdcard.link
	echo '<script type="text/javascript">' >> \
		${POLYOS_VER}/polyos_latest_sdcard.link
	echo 'window.location.href = "${REL_URL_PV}/polyos_${DISTRO_VERSION}_sdcard.zip"' >> \
		${POLYOS_VER}/polyos_latest_sdcard.link
	echo '</script>' >> \
		${POLYOS_VER}/polyos_latest_sdcard.link
	echo '<title>Page Redirection</title>' >> \
		${POLYOS_VER}/polyos_latest_sdcard.link
	echo '</head>' >> \
		${POLYOS_VER}/polyos_latest_sdcard.link
	echo '<body>' >> \
		${POLYOS_VER}/polyos_latest_sdcard.link
	echo 'If you are not redirected automatically, follow this <a href="${REL_URL_PV}/polyos_${DISTRO_VERSION}_sdcard.zip">link</a>.' >> \
		${POLYOS_VER}/polyos_latest_sdcard.link
	echo '</body>' >> \
		${POLYOS_VER}/polyos_latest_sdcard.link
	echo '</html>' >> \
		${POLYOS_VER}/polyos_latest_sdcard.link


	# Write link for changelog to polyos_x.x.x.x_changelog.txt
	echo "PolyOS ${DISTRO_VERSION} - Initial Release" > \
		${POLYOS_VER}/polyos_latest_changelog.txt

	
}



IMAGE_CMD_sdcard () {
	if [ -z "${SDCARD_ROOTFS}" ]; then
		bberror "SDCARD_ROOTFS is undefined. To use sdcard image from Freescale's BSP it needs to be defined."
		exit 1
	fi

	mkdir -p ${COLLECTOR} 

	# Align boot partition and calculate total SD card image size
	BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE} + ${IMAGE_ROOTFS_ALIGNMENT} - 1)
	BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE_ALIGNED} - ${BOOT_SPACE_ALIGNED} % ${IMAGE_ROOTFS_ALIGNMENT})
	SDCARD_SIZE=$(expr ${IMAGE_ROOTFS_ALIGNMENT} + ${BOOT_SPACE_ALIGNED} + $ROOTFS_SIZE + ${IMAGE_ROOTFS_ALIGNMENT} + $ROOTFS_SIZE + ${IMAGE_ROOTFS_ALIGNMENT} + $ROOTFS_SIZE + ${IMAGE_ROOTFS_ALIGNMENT})
	SDCARD_SIZE=$(expr ${RFSA_RFS1_RFS2_DFS} + 1024)
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

my_postprocess_function() {
   cp ${DTB_PV_VS0} ${IMAGE_ROOTFS}/boot/imx6ull-voltastream0.dtb
   cp ${DTB_PV_VSA1} ${IMAGE_ROOTFS}/boot/imx6ull-voltastream-amp1.dtb
   cp ${DTB_PV_VSM1_0006} ${IMAGE_ROOTFS}/boot/imx6ull-vsm1-0006.dtb
#   cp ${ZIMAGE_PV} ${IMAGE_ROOTFS}/boot/zImage
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
}
#openssl passwd -1 -salt $(openssl rand -base64 6) polyvection

ROOTFS_POSTPROCESS_COMMAND_append = " \
  my_postprocess_function; \
"

