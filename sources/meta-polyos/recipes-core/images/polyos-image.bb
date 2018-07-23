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
	hostapd-rtl \
	dhcp-server \
	systemd-network \
	systemd-wlan0 \
	connman \
	connman-client \
	bluez5 \
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
	gmrender-resurrect \
	snapcast \
	squeezelite \
	mpd \
	mpc \
    spotifyd \
    slimserver \
	"


##############
### SYSTEM ###
##############

IMAGE_INSTALL_append +=" \
	pv \
	libxml2-dev \
	usbutils \
	i2c-tools \
	polyos-updater \
	u-boot-fw-utils-pv \
	systemd-serialgetty \
	polyos-opensnd \
	udev \
	polyos-datapart \
	polyos-setup \
	cronie \
	nodejs \
	nodejs-npm \
	polyos-restapi \
	"

#################
### ROOT SIZE ###
#################

IMAGE_ROOTFS_SIZE = "950000" 




