#!/bin/sh
#stage1 :- downloads a iso and extracts the root filesystem, then runs the later stages.

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

#to extract rootfs from iso
sudo apt-get -y install squashfs-tools

#enter directory containing this script
cd $(dirname $(realpath $0))

thepwd="${PWD}"

ISONAME="devuan_daedalus_5.0.0_amd64_minimal-live.iso"
wget "http://mirror.alpix.eu/devuan/devuan_daedalus/minimal-live/${ISONAME}"
mkdir "${thepwd}/mountpoint"
sudo mount -o loop "${ISONAME}" "${thepwd}/mountpoint"
cp -a "${thepwd}/mountpoint/live/filesystem.squashfs" .
sudo umount "${thepwd}/mountpoint"
sudo unsquashfs -f -no-xattrs -d "${thepwd}/mountpoint" filesystem.squashfs

#create /etc/resolv.conf for the outer rootfs
cat /etc/resolv.conf | sudo tee "${thepwd}/mountpoint/etc/resolv.conf"

##stage 2 - run stage two in the outer rootfs
sudo mkdir "${thepwd}/mountpoint/workdir"
sudo cp -a stage2.sh "${thepwd}/mountpoint/workdir/"
chmod +x "${thepwd}/mountpoint/workdir/stage2.sh"
sudo chroot "${thepwd}/mountpoint" /workdir/stage2.sh "${THEARCH}"

#copy build scripts to the outer rootfs
sudo chroot "${thepwd}/mountpoint" chown user:user "/workdir"
sudo cp -a "${thepwd}/myBuildsBuild" "${thepwd}/mountpoint/workdir"
sudo cp -a "${thepwd}/helpers" "${thepwd}/mountpoint/workdir"
sudo cp -a "${thepwd}/getEquiptmentBuild.sh" "${thepwd}/mountpoint/workdir"
sudo cp -a "${thepwd}/installEquiptmentBuild.sh" "${thepwd}/mountpoint/workdir"
sudo chmod +x "${thepwd}/mountpoint/workdir/getEquiptmentBuild.sh"
sudo chmod +x "${thepwd}/mountpoint/workdir/installEquiptmentBuild.sh"

#run build scripts in the outer rootfs
sudo chroot --userspec=user:user ${thepwd}/mountpoint /workdir/getEquiptmentBuild.sh /workdir
sudo chroot ${thepwd}/mountpoint /workdir/installEquiptmentBuild.sh /workdir

sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/workdir"

#copy some config files to /etc/skel in the inner rootfs
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/etc/skel/Desktop"
sudo chmod 755 "${thepwd}/mountpoint/workdir/rootfs/etc/skel"
sudo chmod 755 "${thepwd}/mountpoint/workdir/rootfs/etc/skel/Desktop"
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.config"
sudo chmod 755 "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.config"
sudo cp -a "${thepwd}/config/xfce4" "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.config/"
sudo cp -a "${thepwd}/config/spacefm" "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.config/"
sudo cp -a "${thepwd}/.xinitrc" "${thepwd}/mountpoint/workdir/rootfs/etc/skel/"
sudo cp -a "${thepwd}/.profile" "${thepwd}/mountpoint/workdir/rootfs/etc/skel/"
sudo chmod 700 "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.xinitrc"
sudo chmod 700 "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.profile"
sudo ln -s .xinitrc "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.xsession"
sudo chmod 700 "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.xsession" "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.xinitrc"
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.config/gtk-3.0"
sudo chmod 755 "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.config/gtk-3.0"
sudo cp -a "${thepwd}/config/gtk-3.0/gtk.css" "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.config/gtk-3.0/"
sudo cp -a "${thepwd}/config/gtk-3.0/settings.ini" "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.config/gtk-3.0/"
sudo cp -a "${thepwd}/.gtkrc-2.0" "${thepwd}/mountpoint/workdir/rootfs/etc/skel/"
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.local/share/xfce4/helpers"
sudo chmod -R 755 "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.local/share/xfce4/helpers"
sudo cp -a "${thepwd}/local/share/xfce4/helpers/custom-FileManager.desktop" "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.local/share/xfce4/helpers/custom-FileManager.desktop"
sudo cp -a "${thepwd}/local/share/xfce4/helpers/custom-TerminalEmulator.desktop" "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.local/share/xfce4/helpers/custom-TerminalEmulator.desktop"
sudo chmod 0644 "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.local/share/xfce4/helpers/custom-FileManager.desktop"
sudo chmod 0644 "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.local/share/xfce4/helpers/custom-TerminalEmulator.desktop"

#copy some config files to /root in the inner rootfs
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/root/Desktop"
sudo chmod 755 "${thepwd}/mountpoint/workdir/rootfs/root"
sudo chmod 755 "${thepwd}/mountpoint/workdir/rootfs/root/Desktop"
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/root/.config"
sudo chmod 755 "${thepwd}/mountpoint/workdir/rootfs/root/.config"
sudo cp -a ${thepwd}/config/xfce4 "${thepwd}/mountpoint/workdir/rootfs/root/.config/"
sudo cp -a "${thepwd}/config/spacefm" "${thepwd}/mountpoint/workdir/rootfs/root/.config/"
sudo cp -a ${thepwd}/.xinitrc "${thepwd}/mountpoint/workdir/rootfs/root/"
sudo cp -a ${thepwd}/.profile "${thepwd}/mountpoint/workdir/rootfs/root/"
sudo chmod 700 "${thepwd}/mountpoint/workdir/rootfs/root/.xinitrc"
sudo chmod 700 "${thepwd}/mountpoint/workdir/rootfs/root/.profile"
sudo ln -s .xinitrc "${thepwd}/mountpoint/workdir/rootfs/root/.xsession"
sudo chmod 700 "${thepwd}/mountpoint/workdir/rootfs/root/.xsession" "${thepwd}/mountpoint/workdir/rootfs/root/.xinitrc"
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/root/.config/gtk-3.0"
sudo chmod 755 "${thepwd}/mountpoint/workdir/rootfs/root/.config/gtk-3.0"
sudo cp -a "${thepwd}/config/gtk-3.0/gtk.css" "${thepwd}/mountpoint/workdir/rootfs/root/.config/gtk-3.0/"
sudo cp -a "${thepwd}/config/gtk-3.0/settings.ini" "${thepwd}/mountpoint/workdir/rootfs/root/.config/gtk-3.0/"
sudo cp -a "${thepwd}/.gtkrc-2.0" "${thepwd}/mountpoint/workdir/rootfs/root/"
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/root/.local/share/xfce4/helpers"
sudo chmod -R 755 "${thepwd}/mountpoint/workdir/rootfs/root/.local/share/xfce4/helpers"
sudo cp -a "${thepwd}/local/share/xfce4/helpers/custom-FileManager.desktop" "${thepwd}/mountpoint/workdir/rootfs/root/.local/share/xfce4/helpers/custom-FileManager.desktop"
sudo cp -a "${thepwd}/local/share/xfce4/helpers/custom-TerminalEmulator.desktop" "${thepwd}/mountpoint/workdir/rootfs/root/.local/share/xfce4/helpers/custom-TerminalEmulator.desktop"
sudo chmod 0644 "${thepwd}/mountpoint/workdir/rootfs/root/.local/share/xfce4/helpers/custom-FileManager.desktop"
sudo chmod 0644 "${thepwd}/mountpoint/workdir/rootfs/root/.local/share/xfce4/helpers/custom-TerminalEmulator.desktop"

#copy some config files to /home/user in the inner rootfs
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/home/user/Desktop"
sudo chmod 755 "${thepwd}/mountpoint/workdir/rootfs/home/user"
sudo chmod 755 "${thepwd}/mountpoint/workdir/rootfs/home/user/Desktop"
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/home/user/.config"
sudo chmod 755 "${thepwd}/mountpoint/workdir/rootfs/home/user/.config"
sudo cp -a ${thepwd}/config/xfce4 "${thepwd}/mountpoint/workdir/rootfs/home/user/.config/"
sudo cp -a "${thepwd}/config/spacefm" "${thepwd}/mountpoint/workdir/rootfs/home/user/.config/"
sudo cp -a ${thepwd}/.xinitrc "${thepwd}/mountpoint/workdir/rootfs/home/user/"
sudo cp -a ${thepwd}/.profile "${thepwd}/mountpoint/workdir/rootfs/home/user/"
sudo chmod 700 "${thepwd}/mountpoint/workdir/rootfs/home/user/.xinitrc"
sudo chmod 700 "${thepwd}/mountpoint/workdir/rootfs/home/user/.profile"
sudo chmod 700 "${thepwd}/mountpoint/workdir/rootfs/home/user/.xinitrc"
sudo chmod 700 "${thepwd}/mountpoint/workdir/rootfs/home/user/.profile"
sudo ln -s .xinitrc "${thepwd}/mountpoint/workdir/rootfs/home/user/.xsession"
sudo chmod 700 "${thepwd}/mountpoint/workdir/rootfs/home/user/.xsession" "${thepwd}/mountpoint/workdir/rootfs/root/.xinitrc"
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/home/user/.config/gtk-3.0"
sudo chmod 755 "${thepwd}/mountpoint/workdir/rootfs/home/user/.config/gtk-3.0"
sudo cp -a "${thepwd}/config/gtk-3.0/gtk.css" "${thepwd}/mountpoint/workdir/rootfs/home/user/.config/gtk-3.0/"
sudo cp -a "${thepwd}/config/gtk-3.0/settings.ini" "${thepwd}/mountpoint/workdir/rootfs/home/user/.config/gtk-3.0/"
sudo cp -a "${thepwd}/.gtkrc-2.0" "${thepwd}/mountpoint/workdir/rootfs/home/user/"
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/home/user/.local/share/xfce4/helpers"
sudo chmod -R 755 "${thepwd}/mountpoint/workdir/rootfs/home/user/.local/share/xfce4/helpers"
sudo cp -a "${thepwd}/local/share/xfce4/helpers/custom-FileManager.desktop" "${thepwd}/mountpoint/workdir/rootfs/home/user/.local/share/xfce4/helpers/custom-FileManager.desktop"
sudo cp -a "${thepwd}/local/share/xfce4/helpers/custom-TerminalEmulator.desktop" "${thepwd}/mountpoint/workdir/rootfs/home/user/.local/share/xfce4/helpers/custom-TerminalEmulator.desktop"
sudo chmod 0644 "${thepwd}/mountpoint/workdir/rootfs/home/user/.local/share/xfce4/helpers/custom-FileManager.desktop"
sudo chmod 0644 "${thepwd}/mountpoint/workdir/rootfs/home/user/.local/share/xfce4/helpers/custom-TerminalEmulator.desktop"

sudo chroot "${thepwd}/mountpoint" chown -R user:user /workdir/rootfs/home/user/.config
sudo chroot "${thepwd}/mountpoint" chown -R user:user /workdir/rootfs/home/user/Desktop
sudo chroot "${thepwd}/mountpoint" chown -R user:user /workdir/rootfs/home/user/.gtkrc-2.0
sudo chroot "${thepwd}/mountpoint" chown -R user:user /workdir/rootfs/home/user/.xinitrc
sudo chroot "${thepwd}/mountpoint" chown -R user:user /workdir/rootfs/home/user/.profile
sudo chroot "${thepwd}/mountpoint" chown -R user:user /workdir/rootfs/home/user/.xsession
sudo chroot "${thepwd}/mountpoint" chown -R user:user /workdir/rootfs/home/user/.local

#add ash as default shell
sudo cp "${thepwd}/ash" "${thepwd}/mountpoint/workdir/rootfs/bin/"
sudo chmod 755 "${thepwd}/mountpoint/workdir/rootfs/bin/ash"
cp "${thepwd}/mountpoint/workdir/rootfs/etc/shells" shells
echo "/bin/ash" >> shells
sudo mv shells "${thepwd}/mountpoint/workdir/rootfs/etc/shells"
sudo chmod 0644 "${thepwd}/mountpoint/workdir/rootfs/etc/shells"

#copy touchpad tap-to-click xorg setting to /usr/share/X11/xorg.conf.d in the inner rootfs
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/usr/share/X11/xorg.conf.d"
sudo cp "${thepwd}/50-synaptics.conf" "${thepwd}/mountpoint/workdir/rootfs/usr/share/X11/xorg.conf.d/50-synaptics.conf"

#create /etc/resolv.conf for inner rootfs
cat /etc/resolv.conf | sudo tee "${thepwd}/mountpoint/workdir/rootfs/etc/resolv.conf"

###copy build scripts to inner rootfs
##sudo cp -a "${thepwd}/myBuildsHost" "${thepwd}/mountpoint/workdir/rootfs/workdir/"
##sudo cp -a "${thepwd}/helpers" "${thepwd}/mountpoint/workdir/rootfs/workdir/"
##sudo cp -a "${thepwd}/getEquiptmentHost.sh" "${thepwd}/mountpoint/workdir/rootfs/workdir/"
##sudo cp -a "${thepwd}/installEquiptmentHost.sh" "${thepwd}/mountpoint/rootfs/workdir/"
##sudo chmod +x "${thepwd}/mountpoint/workdir/rootfs/workdir/getEquiptmentHost.sh"
##sudo chmod +x "${thepwd}/mountpoint/workdir/rootfs/workdir/installEquiptmentHost.sh"

#run stage three in the inner rootfs
sudo cp "${thepwd}/stage3.sh" "${thepwd}/mountpoint/workdir/rootfs/workdir/"
sudo chmod +x "${thepwd}/mountpoint/workdir/rootfs/workdir/stage3.sh"
sudo chroot "${thepwd}/mountpoint/workdir/rootfs" /workdir/stage3.sh "${THEARCH}" "$2"

##back up permissions that have sbit set to restore later upon installation
sudo echo '#!/bin/sh' | sudo tee "${thepwd}/mountpoint/workdir/rootfs/getperms.sh"
sudo echo 'cd /' | sudo tee -a "${thepwd}/mountpoint/workdir/rootfs/getperms.sh"
sudo echo 'getfacl -R . > /saved-permissions' | sudo tee -a "${thepwd}/mountpoint/workdir/rootfs/getperms.sh"
sudo chmod +x "${thepwd}/mountpoint/workdir/rootfs/getperms.sh"
sudo chroot "${thepwd}/mountpoint/workdir/rootfs" ./getperms.sh

sudo rm "${thepwd}/mountpoint/workdir/rootfs/getperms.sh"

#clean up any scripts inside the inner rootfs
sudo rm -rf "${thepwd}/mountpoint/workdir/rootfs/workdir"

#stage 4 - run from the extracted iso
cd "${thepwd}"
sudo cp stage4.sh "${thepwd}/mountpoint/workdir/"
sudo cp initOverlay.sh "${thepwd}/mountpoint/workdir/"
sudo cp installToHDD.sh "${thepwd}/mountpoint/workdir/"
sudo chmod +x "${thepwd}/mountpoint/workdir/stage4.sh"

sudo chroot "${thepwd}/mountpoint" /workdir/stage4.sh "${THEARCH}"