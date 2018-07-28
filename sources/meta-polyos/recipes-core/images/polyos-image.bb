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
	iperf3 \
	ntp \
	iw \
	wireless-firmware-rtl \
	wireless-firmware-mt \
	wireless-firmware-qcom \
	curl \
	systemd-network \
	systemd-wlan0 \
	connman \
	connman-client \
	"


#############
### AUDIO ###
#############

IMAGE_INSTALL_append +=" \
	alsa-utils \
	alsa-asound \
	fsl-alsa-plugins \
	polyos-linein \
	polyos-tosin \
	"


#################
### STREAMING ###
#################

IMAGE_INSTALL_append +=" \
	shairport-sync \
	squeezelite \
    spotifyd \
    slimserver \
	"

#####################
### BUILDING CPAN ###
#####################

#IMAGE_INSTALL_append +=" \
#    nasm \
#    rsync \
#    git \
#    patch \
#    bash \
#    zlib \
#    packagegroup-core-buildessential \
#    perl-doc \
#"
#IMAGE_FEATURES += "staticdev-pkgs"

##############
### SYSTEM ###
##############

IMAGE_INSTALL_append +=" \
	pv \
	libxml2-dev \
	usbutils \
	i2c-tools \
	polyos-updater \
	systemd-serialgetty \
	polyos-opensnd \
	udev \
	polyos-datapart \
	polyos-setup \
	cronie \
	nodejs \
	nodejs-npm \
	polyos-restapi \
    perl \
    perl-modules \
    parted \
    e2fsprogs-resize2fs \
    e2fsprogs-mke2fs \
    io-socket-ssl-perl \
	"

#################
### ROOT SIZE ###
#################

#IMAGE_ROOTFS_SIZE = "950000"
#IMAGE_ROOTFS_EXTRA_SPACE = "100"
IMAGE_OVERHEAD_FACTOR = "1.01"




