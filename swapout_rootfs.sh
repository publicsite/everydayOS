#!/bin/sh

if [ ! -d "$1" ]; then
echo "Argv1: rootfs to overwrite, eg. /"
exit
fi

if [ ! -d "$2" ]; then
echo "Argv1: rootfs to copy, eg. /home/user/somerootfs"
exit
fi

abusybox="$(which busybox)"

if [ ! -f "$abusybox" ]; then
	#try install busybox-static with apt if it's not installed
	sudo apt-get update
	sudo apt-get install -y busybox-static
	if [ "$?" != "0" ]; then
		echo "Error: busybox-static could not be installed and cannot be found, so not proceeding."
		exit
	fi
elif [ "$(file $abusybox | grep "statically")" = "" ]; then
	#try install busybox-static with apt if busybox exists, but is not statically compiled
	sudo apt-get update
	sudo apt-get install -y busybox-static
	if [ "$?" != "0" ]; then
		echo "Error: busybox-static could not be installed and cannot be found, so not proceeding."
		exit
	fi
fi

mkdir -p chrootdir/usr/bin

cp -a /usr/bin/busybox chrootdir/usr/bin

mkdir -p chrootdir/rootfstocopy

mkdir -p chrootdir/rootfsinto

mkdir -p chrootdir/configs

cp -a "${1}/etc/passwd" chrootdir/configs/
cp -a "${1}/etc/group" chrootdir/configs/
cp -a "${1}/etc/shadow" chrootdir/configs/

sudo mount --bind "$1" chrootdir/rootfsinto
#todo: replace with /
sudo mount --bind "$2" chrootdir/rootfstocopy

cat <<EOF > chrootdir/innerscript.sh
#!/usr/bin/busybox sh

find /rootfsinto -maxdepth 1 -mindepth 1 -type d | while read line; do
	if [ "\$line" != "" ] && [ "\$line" != "/rootfsinto/isolinux" ] && [ "\$line" != "/rootfsinto/swapfile" ] && [ "\$line" != "/rootfsinto/overlay" ] && [ "\$line" != "/rootfsinto/dev" ] && [ "\$line" != "/rootfsinto/proc" ] && [ "\$line" != "/rootfsinto/sys" ] && [ "\$line" != "/rootfsinto/tmp" ] && [ "\$line" != "/rootfsinto/run" ] && [ "\$line" != "/rootfsinto/mnt" ] && [ "\$line" != "/rootfsinto/media" ] && [ "\$line" != "/rootfsinto/home" ] && [ "\$line" != "/rootfsinto/root" ]; then
		echo "Deleting \$line ..."
		rm -rf "\$line"
	fi
done

find /rootfsinto -maxdepth 1 -mindepth 1 -type f | while read line; do
	if [ "\$line" != "" ]; then
		echo "Deleting \$line ..."
		rm -f "\$line"
	fi
done

find /rootfsinto -maxdepth 1 -mindepth 1 -type l | while read line; do
	if [ "\$line" != "" ]; then
		echo "Deleting \$line ..."
		rm -f "\$line"
	fi
done

find /rootfstocopy -maxdepth 1 -mindepth 1 -type d | while read line; do
	if [ "\$line" != "" ] && [ "\$line" != "/rootfstocopy/isolinux" ] && [ "\$line" != "/rootfstocopy/swapfile" ] && [ "\$line" != "/rootfstocopy/overlay" ] && [ "\$line" != "/rootfstocopy/dev" ] && [ "\$line" != "/rootfstocopy/proc" ] && [ "\$line" != "/rootfstocopy/sys" ] && [ "\$line" != "/rootfstocopy/tmp" ] && [ "\$line" != "/rootfstocopy/run" ] && [ "\$line" != "/rootfstocopy/mnt" ] && [ "\$line" != "/rootfstocopy/media" ] && [ "\$line" != "/rootfstocopy/home" ] && [ "\$line" != "/rootfstocopy/root" ]; then
		echo "Copying \$line ..."
		cp -a "\$line" "/rootfsinto/"
	fi
done

find /rootfstocopy -maxdepth 1 -mindepth 1 -type f | while read line; do
	if [ "\$line" != "" ]; then
		echo "Copying \$line ..."
		cp -a "\$line" "/rootfsinto/"
	fi
done


find /rootfstocopy -maxdepth 1 -mindepth 1 -type l | while read line; do
	if [ "\$line" != "" ]; then
		echo "Copying \$line ..."
		cp -a "\$line" "/rootfsinto/"
	fi
done

cp -a "/configs/passwd" "/rootfsinto/etc/passwd"
cp -a "/configs/group" "/rootfsinto/etc/group"
cp -a "/configs/shadow" "/rootfsinto/etc/shadow"

EOF

chmod +x chrootdir/innerscript.sh

sudo chroot chrootdir /innerscript.sh

sudo umount chrootdir/rootfsinto
sudo umount chrootdir/rootfstocopy

echo "Cleaning up ..."
rm -rf chrootdir