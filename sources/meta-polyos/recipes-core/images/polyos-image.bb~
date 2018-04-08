include recipes-core/images/core-image-minimal.bb

######################
### KERNEL MODULES ###
######################

IMAGE_INSTALL += " \
	kernel-modules \
	" 

################
### FEATURES ###
################

IMAGE_FEATURES += " ssh-server-openssh"


###############
### NETWORK ###
###############

IMAGE_INSTALL_append +=" \
	wpa-supplicant \
	polyos-wifi \
	iperf \
	ntp \
	iw \
	wireless-firmware-rtl \
	curl \
	"


#############
### AUDIO ###
#############

IMAGE_INSTALL_append +=" \
	alsa-utils \
	alsa-asound \
	fsl-alsa-plugins \
	"


#################
### STREAMING ###
#################

IMAGE_INSTALL_append +=" \
	shairport-sync \
	"


##############
### SYSTEM ###
##############

IMAGE_INSTALL_append +=" \
	pv \
	libxml2-dev \
	usbutils \
	i2c-tools \
	u-boot-fw-utils-pv \
	polyos-updater \
	"

#################
### ROOT SIZE ###
#################

IMAGE_ROOTFS_SIZE = "490000" 


