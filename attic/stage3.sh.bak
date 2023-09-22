#!/bin/sh
#stage3 :- customises a vanilla rootfs

if [ "$1" = "" ]; then
	echo "Argv1: <arch>"
	echo "eg. \"i386\""
	exit
else
	THEARCH="$1"
fi

if [ "$(echo "$2" | cut -c 1-12)" != "linux-image-" ]; then
	echo "Argv2: the name of the kernel package for your architecture"
	echo "eg. \"linux-image-686\""
	exit
fi

#we mount the stuff for apt
mount none -t proc /proc
mount none -t sysfs /sys
mkdir -p /dev/pts
mount none -t devpts /dev/pts

#create /dev/null and /dev/zero
mknod -m 666 /dev/null c 1 3
mknod -m 666 /dev/zero c 1 5
chown root:root /dev/null /dev/zero

#fix permissions problems
chmod -Rv 700 /var/cache/apt/archives/partial/

chown -Rv _apt:root /var/cache/apt/archives/partial/

export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C
export LANG=C
export LANGUAGE=C

#this stuff doesn't like chroots, so we get rid of it for the purposes of building
apt-get -y autoremove  exim4-config exim4-base exim4-daemon-light exim4-config-2 exim4

#update the system
apt-get -y update && apt-get -y upgrade

apt-get -m -y install efibootmgr syslinux-efi \
task-laptop \
task-english \
alsa-utils \
sysvinit-core \
sysv-rc \
live-config-sysvinit \
xdg-utils \
xorg \
xserver-xorg-input-all \
xserver-xorg-video-all \
va-driver-all openbox \
obconf \
pulseaudio \
xfce4-panel \
xfce4-pulseaudio-plugin \
xfce4-terminal \
xfce4-whiskermenu-plugin \
thunar \
thunar-archive-plugin \
xdm \
blueman \
qalculate-gtk \
xfburn \
viking \
kolourpaint \
hexchat \
telegram-desktop \
transmission-gtk \
vlc \
mousepad \
pavucontrol \
libreoffice \
file-roller \
evince \
gparted \
htop \
claws-mail \
firmware-linux-free

apt-get -m -y install --no-install-recommends \
"$2" \
console-setup-mini \
pciutils \
bc \
breeze-icon-theme \
extlinux \
syslinux-common \
wget \
nano \
vim \
file \
iputils-ping \
fonts-crosextra-caladea \
fonts-crosextra-carlito \
fonts-liberation2 \
fonts-linuxlibertine \
fonts-noto-core \
fonts-noto-extra \
fonts-noto-ui-core \
fonts-sil-gentium-basic \
libreoffice \
xfdesktop4 \
xfdesktop4-data \
locales \
whois \
telnet \
aptitude \
lsof \
time \
tnftp \
xserver-xorg-input-synaptics \
gnome-icon-theme \
sudo \
fdisk \
less \
xfce4-session \
connman \
connman-gtk \
xfce4-power-manager \
xfce4-power-manager-plugins \
dns323-firmware-tools \
firmware-linux-free \
grub-firmware-qemu \
hdmi2usb-fx2-firmware \
sigrok-firmware-fx2lafw \
amd64-microcode \
bluez-firmware \
dahdi-firmware-nonfree \
firmware-amd-graphics \
firmware-atheros \
firmware-bnx2 \
firmware-bnx2x \
firmware-brcm80211 \
firmware-cavium \
firmware-intel-sound \
firmware-iwlwifi \
firmware-libertas \
firmware-linux \
firmware-linux-nonfree \
firmware-misc-nonfree \
firmware-myricom \
firmware-netronome \
firmware-netxen \
firmware-qcom-media \
firmware-qlogic \
firmware-realtek \
firmware-samsung \
firmware-siano \
firmware-ti-connectivity \
firmware-zd1211 \
intel-microcode \
tzdata

echo "TYPE PASSWORD FOR: root"
passwd root

echo "TYPE PASSWORD FOR: user"
adduser user

gpasswd -a user sudo
/usr/sbin/groupadd power
gpasswd -a user power
gpasswd -a user users
gpasswd -a user bluetooth
gpasswd -a user plugdev
gpasswd -a user video
/usr/sbin/groupadd lpadmin
gpasswd -a user lpadmin

if [ "$(grep "%users ALL = NOPASSWD:/usr/lib/${THEARCH}-linux-gnu/xfce4/session/xfsm-shutdown-helper" /etc/sudoers)" = "" ]; then
	echo "" >> /etc/sudoers
	echo "# Allow members of group sudo to execute any command" >> /etc/sudoers
	echo "%sudo   ALL=(ALL:ALL) ALL" >> /etc/sudoers
	echo "" >> /etc/sudoers
	echo "# Allow anyone to shut the machine down" >> /etc/sudoers
	echo "%users ALL = NOPASSWD:/usr/lib/${THEARCH}-linux-gnu/xfce4/session/xfsm-shutdown-helper" >> /etc/sudoers
fi

if [ -f "rootfs/usr/share/X11/xorg.conf.d/40-libinput.conf" ]; then
	#delete this because we will write to it
	if [ -f "rootfs/etc/X11/xorg.conf.d/40-libinput.conf" ]; then
	rm "rootfs/etc/X11/xorg.conf.d/40-libinput.conf"
	fi
	OLD_IFS="$IFS"
	IFS="$(printf "\n")"
	cat "rootfs/usr/share/X11/xorg.conf.d/40-libinput.conf" | while read line; do
		if [ "$line" = "        Identifier \"libinput touchpad catchall\"" ]; then
			echo "$line" >> "rootfs/etc/X11/xorg.conf.d/40-libinput.conf"
			echo "        Option \"Tapping\" \"on\"" >> "rootfs/etc/X11/xorg.conf.d/40-libinput.conf"
		else
			echo "$line" >> "rootfs/etc/X11/xorg.conf.d/40-libinput.conf"
		fi
	done
	IFS="$OLD_IFS"
fi

apt-get clean

#cd /workdir
#/workdir/getEquiptmentHost.sh /workdir
#/workdir/installEquiptmentHost.sh /workdir

rm /etc/resolv.conf
rm -rf /tmp/*

rm /root/.bash_history

#unmount stuff
umount /proc
umount /sys
umount /dev/pts
