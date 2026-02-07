#!/bin/sh
#stage3 :- customises a vanilla rootfs

OLD_UMASK="$(umask)"
umask 0022

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
rm /dev/null
rm /dev/zero
mknod -m 666 /dev/null c 1 3
mknod -m 666 /dev/zero c 1 5
mknod -m 666 /dev/random c 1 8
mknod -m 666 /dev/urandom c 1 9
chown root:root /dev/null /dev/zero /dev/random /dev/urandom

#fix permissions problems
chmod -Rv 700 /var/cache/apt/archives/partial/

chown -Rv _apt:root /var/cache/apt/archives/partial/

#add messagebus group
/usr/sbin/groupadd messagebus

export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C
export LANG=C
export LANGUAGE=C

#change default shell to ash
chsh -s /bin/ash

#this stuff doesn't like chroots, so we get rid of it for the purposes of building
apt-get -y autoremove  exim4-config exim4-base exim4-daemon-light exim4-config-2 exim4

#update the system
apt-get -y update && apt-get -y upgrade

##====BLACKLIST STARTS HERE===##
#note, we are lenient on firmware

blacklist()
{

outname="$(printf "99-blacklist-%s" "${1}" | tr -d .)"
#function for blacklisting
echo "Package: ${1}" > "/etc/apt/preferences.d/${outname}"
echo 'Pin: release *' >> "/etc/apt/preferences.d/${outname}"
echo 'Pin-Priority: -1' >> "/etc/apt/preferences.d/${outname}"
}

#we blacklist these in addition
#we use our own yt-dlp
blacklist "yt-dlp"
#buggy so removed
blacklist "xfdesktop4"

#based off of https://trisquel.info/en/wiki/software-does-not-respect-free-system-distribution-guidelines
blacklist "boinc"
blacklist "boinc-app-seti"
blacklist "debian-reference"
blacklist "konqueror"
blacklist "lucida"
blacklist "icedove"
blacklist "thunderbird"
blacklist "xchat"
blacklist "a2ps-perl-ja"
blacklist "acetoneiso"
blacklist "aee"
blacklist "afio"
blacklist "app-install-data-commercial"
blacklist "starfighter"
blacklist "bnetd"
blacklist "chromium-browser"
blacklist "d4x"
blacklist "dosemu"
blacklist "ee"
blacklist "envyng-core"
blacklist "envyng-gtk"
blacklist "envyng-qt"
blacklist "gnome-app-install"
blacklist "gstreamer0.10-pitfdll"
blacklist "helix-player"
blacklist "iceape"
blacklist "iceweasel"
blacklist "isdnutils"
blacklist "ivman"
blacklist "jockey"
blacklist "libxprintapputil"
blacklist "mame"
blacklist "mesademos"
blacklist "mol"
blacklist "mol-drivers-linux"
blacklist "mac"
blacklist "moon"
blacklist "mp32ogg"
blacklist "ndiswrapper"
blacklist "ndisgtk"
blacklist "nikto"
blacklist "openoffice.org"
blacklist "pvpgn"
blacklist "rman"
blacklist "scribus-ng-doc"
blacklist "seamonkey"
blacklist "simutrans"
blacklist "simutrans-pak64"
blacklist "simutrans-pak128.britain"
blacklist "testdrive"
blacklist "kubuntu-meta"
blacklist "ubuntu-meta"
blacklist "unetbootin"
blacklist "unrar-nonfree"
blacklist "virtualbox-guest-additions-iso"
blacklist "vrms"
blacklist "xv"

#additional packages from https://github.com/trisquelgnulinux/ubuntu-purge/blob/master/purge-bionic
#reason for these packages being blacklisted in trisquel isn't clear
blacklist "9menu"
blacklist "app-install-data-partner"
blacklist "bibledit"
blacklist "bible-kjv"
blacklist "biblememorizer"
blacklist "bibletime"
blacklist "biblesync"
blacklist "bumblebee"
blacklist "chromium-codecs-ffmpeg"
blacklist "easycrypt"
blacklist "efilinux-signed"
blacklist "emacs23"
blacklist "flashplugin-nonfree"
blacklist "fonts-ubuntu-title"
blacklist "freesci"
blacklist "gdecrypt"
blacklist "gnome-speech"
blacklist "grub2-signed"
blacklist "kde-config-whoopsie"
blacklist "kubuntu-firefox-installer"
blacklist "kubuntu-driver-manager"
blacklist "libubuntuone"
blacklist "maptransfer"
blacklist "maptransfer-server"
blacklist "nvclock"
blacklist "ophcrack"
blacklist "origami"
blacklist "pipsi"
blacklist "pypibrowser"
blacklist "qsampler"
blacklist "qstat"
blacklist "rhythmbox-ubuntuone-music-store"
blacklist "scribus-doc"
blacklist "shim-signed"
blacklist "simutrans-data"
blacklist "simutrans-makeobj"
blacklist "smtube"
blacklist "software-center"
blacklist "snapd"
blacklist "snapd-xdg-open"
blacklist "sweethome3d-furniture-nonfree"
blacklist "tatan"
blacklist "torbrowser-launcher"
blacklist "ubuntu-advantage-tools"
blacklist "ubuntu-drivers-common"
blacklist "ubuntu-online-tour"
blacklist "ubuntuone-client"
blacklist "ubuntuone-dev-tools"
blacklist "ubuntuone-storage-protocol"
blacklist "ubuntu-download-manager"
blacklist "ubuntu-restricted-extras"
blacklist "w9wm"
blacklist "xdrawchem"
blacklist "xqf"

##====BLACKLIST ENDS HERE===##


if [ "$THEARCH" = "i*86" ] || [ "$THEARCH" = "x86_64" ]; then
apt-get -m -y install grub-efi-ia32
fi

apt-get -m -y install efibootmgr \
task-laptop \
task-english \
sysvinit-core \
sysv-rc \
live-config-sysvinit \
xorg \
xserver-xorg-input-all \
xserver-xorg-video-all \

#install xfce4-terminal before apt gets a chance to install other x terminal like zutty or whatever else...
apt-get -m -y install --no-install-recommends xfce4-terminal

apt-get -m -y install \
firefox-esr \
xdg-utils \
alsa-utils \
va-driver-all openbox \
obconf \
pulseaudio \
lightdm \
blueman \
qalculate-gtk \
xfburn \
viking \
kolourpaint \
hexchat \
telegram-desktop \
vlc \
mousepad \
pavucontrol \
libreoffice \
file-roller \
evince \
gparted \
htop \
claws-mail \
firmware-linux-free \
grub2 xorriso mtools \
busybox-static \
thunar \
dialect \
acl \
python3-pip \
ntpsec \
mirage \
mpv

#transmission-gtk \

apt-get -m -y install --no-install-recommends \
"$2" \
xfce4-terminal \
live-task-base \
xfce4-panel \
xfce4-pulseaudio-plugin \
xfce4-whiskermenu-plugin \
xfce-polkit \
xfce4-power-manager xfce4-power-manager-data xfce4-power-manager-plugins \
xfce4-session \
console-setup-mini \
pciutils \
bc \
breeze-icon-theme \
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
connman \
connman-gtk \
dns323-firmware-tools \
firmware-linux-free \
grub-firmware-qemu \
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

###for dooble
##apt-get -m -y install --no-install-recommends \
##libqt5webenginewidgets5 libqt5charts5 libqt5sql5t64 libqt5sql5-sqlite

echo "TYPE PASSWORD FOR: root"
passwd root

echo "TYPE PASSWORD FOR: user"
adduser --shell /bin/ash user

gpasswd -a user sudo
/usr/sbin/groupadd power
gpasswd -a user power
gpasswd -a user users
gpasswd -a user bluetooth
gpasswd -a user plugdev
gpasswd -a user video
/usr/sbin/groupadd lpadmin
gpasswd -a user lpadmin

if [ -f "/etc/sudoers" ]; then
	if [ "$(grep "%users ALL = NOPASSWD:/usr/lib/${THEARCH}-linux-gnu/xfce4/session/xfsm-shutdown-helper" /etc/sudoers)" = "" ]; then

	echo "" >> /etc/sudoers
	echo "# Allow members of group sudo to execute any command" >> /etc/sudoers
	echo "%sudo   ALL=(ALL:ALL) ALL" >> /etc/sudoers
	echo "" >> /etc/sudoers
	echo "# Allow anyone to shut the machine down" >> /etc/sudoers
	echo "%users ALL = NOPASSWD:/usr/lib/${THEARCH}-linux-gnu/xfce4/session/xfsm-shutdown-helper" >> /etc/sudoers

	fi
else
	echo "" > /etc/sudoers
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

#for some reasons the permissions got changed once, so I set them here just to be safe
chown root:messagebus /usr/lib/dbus-1.0/dbus-daemon-launch-helper
chmod 4754 /usr/lib/dbus-1.0/dbus-daemon-launch-helper


chown -R user:user /home/user

#install upstream yt-dlp
wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/bin/yt-dlp
chmod a+rx /usr/bin/yt-dlp

sudo chmod 750 /etc/sudoers.d
sudo chmod 0440 /etc/sudoers

###make dooble the default browser
##update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/Dooble-normal.sh 501
##update-alternatives --config x-www-browser
##xdg-mime default Dooble-normal.desktop text/html

apt-get clean

#cd /workdir
#/workdir/getEquiptmentHost.sh /workdir
#/workdir/installEquiptmentHost.sh /workdir

rm /etc/resolv.conf
rm -rf /tmp/*

if [ -f "/root/.bash_history" ]; then 
	rm /root/.bash_history
fi

#unmount stuff
umount /proc
umount /sys
umount /dev/pts

umask "${OLD_UMASK}"
