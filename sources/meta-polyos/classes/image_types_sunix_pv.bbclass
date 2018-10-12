inherit image_types

DEPENDS =+ "zip-native"

#
# Create an image that can by written onto a SD card using dd.
# Originally written for rasberrypi adapt for the needs of allwinner sunxi based boards
#
# The disk layout used is:
#
#    0                      -> 8*1024                           - reserverd
#    8*1024                 ->                                  - arm combined spl/u-boot or aarch64 spl
#    40*1024                ->                                  - aarch64 u-boot
#    2048*1024              -> BOOT_SPACE                       - bootloader and kernel
#
#

# This image depends on the rootfs image
IMAGE_TYPEDEP_sdcard = "${SDIMG_ROOTFS_TYPE}"
IMAGE_TYPEDEP_sdcard += "tar.bz2"

# Boot partition volume id
BOOTDD_VOLUME_ID ?= "${MACHINE}"

# Boot partition size [in KiB]
BOOT_SPACE ?= "40960"

# First partition begin at sector 2048 : 2048*1024 = 2097152
IMAGE_ROOTFS_ALIGNMENT = "2048"

# Use an uncompressed ext4 by default as rootfs
SDIMG_ROOTFS_TYPE ?= "ext4"
SDIMG_ROOTFS = "${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.${SDIMG_ROOTFS_TYPE}"

do_image_sdcard[depends] = "parted-native:do_populate_sysroot \
                            dosfstools-native:do_populate_sysroot \
                            mtools-native:do_populate_sysroot \
                            virtual/kernel:do_deploy \
                            ${@d.getVar('IMAGE_BOOTLOADER', True) and d.getVar('IMAGE_BOOTLOADER', True) + ':do_deploy' or ''}"

# SD card image name
SDCARD = "${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.sdcard"

POLYOS_FOLDER = "${DEPLOY_DIR_IMAGE}/_PolyOS_release"
POLYOS_VER = "${DEPLOY_DIR_IMAGE}/_PolyOS_release/${DISTRO_VERSION}"
POLYOS_VER_REL = "${DEPLOY_DIR_IMAGE}/_PolyOS_release/${DISTRO_VERSION}/release"
REL_URL_GH = "https://github.com/polyvection/meta-polyvection/releases/download/${DISTRO_VERSION}"
REL_URL_PV = "https://polyvection.com/software/polyos/voltastream0"

# UGLY HACK #
COLLECTOR = "${DEPLOY_DIR_IMAGE}/_COLLECTOR"
UBOOT_DIR_POLY = "${DEPLOY_DIR_IMAGE}/u-boot.sunxi"

ROOT_EXT4 = "${IMGDEPLOYDIR}/polyos-image-voltastream-a64.ext4"
TAR_ROOTFS = "${IMGDEPLOYDIR}/polyos-image-voltastream-a64.tar.bz2"
EXT4_COL = "${COLLECTOR}/polyos-image-voltastream-a64.ext4"
SD_COL = "${COLLECTOR}/polyos-image-voltastream-a64.rootfs.sdcard"
TAR_ROOTFS_COL = "${COLLECTOR}/polyos-image-voltastream-a64.tar.bz2"


IMAGE_CMD_sdcard () {

    mkdir -p ${COLLECTOR}

    # Align boot partition and calculate total SD card image size
    BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE} + ${IMAGE_ROOTFS_ALIGNMENT} - 1)
    BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE_ALIGNED} - ${BOOT_SPACE_ALIGNED} % ${IMAGE_ROOTFS_ALIGNMENT})
    SDCARD_SIZE=$(expr ${IMAGE_ROOTFS_ALIGNMENT} + ${BOOT_SPACE_ALIGNED} + $ROOTFS_SIZE + ${IMAGE_ROOTFS_ALIGNMENT})

    # Initialize a sparse file
    dd if=/dev/zero of=${SD_COL} bs=1 count=0 seek=$(expr 1024 \* ${SDCARD_SIZE})

    cp ${UBOOT_DIR_POLY} ${COLLECTOR}
    cp ${ROOT_EXT4} ${COLLECTOR}
    cp ${TAR_ROOTFS} ${COLLECTOR}

    # Create partition table
    parted -s ${SD_COL} mklabel msdos

    # software bank 1
    parted -s ${SD_COL} unit KiB mkpart primary $(expr  ${IMAGE_ROOTFS_ALIGNMENT} \+ ${BOOT_SPACE_ALIGNED}) $(expr ${IMAGE_ROOTFS_ALIGNMENT} \+ ${BOOT_SPACE_ALIGNED} \+ $ROOTFS_SIZE)

    parted ${SD_COL} print

    # Burn bootloader
    dd if=${UBOOT_DIR_POLY} of=${SD_COL} conv=notrunc seek=1 bs=8k

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
    rm -f ${POLYOS_VER_REL}/polyos_${DISTRO_VERSION}_update.tar.bz2

    rm -rf ${COLLECTOR}/tmp
    mkdir ${COLLECTOR}/tmp
    tar -xjf ${TAR_ROOTFS_COL} -C ${COLLECTOR}/tmp
    tar cvzf ${COLLECTOR}/tmp.tar.gz -C ${COLLECTOR}/tmp .
    mv ${COLLECTOR}/tmp.tar.gz ${POLYOS_VER_REL}/polyos_${DISTRO_VERSION}_update.tar.gz

    # Compress EXT4 image to polyos_x.x.x.x_update.tar.gz
    #cp ${COLLECTOR}/polyos-image-voltastream.ext4 ${POLYOS_VER_REL}/polyos_${DISTRO_VERSION}_update.ext4
    #tar -zcvf ${POLYOS_VER_REL}/polyos_${DISTRO_VERSION}_update.tar.gz \
    #        ${POLYOS_VER_REL}/polyos_${DISTRO_VERSION}_update.ext4


    # Remove Temp copy of ext4
    #rm -f ${POLYOS_VER_REL}/polyos_${DISTRO_VERSION}_update.ext4

    # Generate sha256 for polyos_x.x.x.x_update.tar.gz
    DL_SUM=`sha256sum ${POLYOS_VER_REL}/polyos_${DISTRO_VERSION}_update.tar.bz2 | cut -d " " -f1`

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



ZIMAGE_PV = "${DEPLOY_DIR_IMAGE}/zImage"
IMAGE_PV = "${DEPLOY_DIR_IMAGE}/Image"
DTB_PV_VS0 = "${DEPLOY_DIR_IMAGE}/zImage-imx6ull-voltastream0.dtb"
DTB_PV_VSA1 = "${DEPLOY_DIR_IMAGE}/zImage-imx6ull-voltastream-amp1.dtb"
DTB_PV_VSM1_0006 = "${DEPLOY_DIR_IMAGE}/zImage-imx6ull-vsm1-0006.dtb"
DTB_PV_VSM1_0007 = "${DEPLOY_DIR_IMAGE}/zImage-imx6ull-vsm1-0007.dtb"
DTB_PV_VSM1_0007 = "${DEPLOY_DIR_IMAGE}/zImage-imx6ull-vsm1-0007.dtb"
DTB_PV_VSA64 = "${DEPLOY_DIR_IMAGE}/Image-sun50i-a64-olinuxino.dtb"


my_postprocess_function() {

    cp ${DTB_PV_VSA64} ${IMAGE_ROOTFS}/boot/a64-vsm2-0010.dtb
    cp ${IMAGE_PV} ${IMAGE_ROOTFS}/boot/Image
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

    cp ${UBOOT_DIR_POLY} ${IMAGE_ROOTFS}/boot/u-boot.sunxi
}


ROOTFS_POSTPROCESS_COMMAND_append = " \
    my_postprocess_function; \
"
