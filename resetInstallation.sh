#!/bin/sh

OLD_UMASK="$(umask)"
umask 0022

#SECTION: TIMEZONE ...

printRegions(){
	find "/usr/share/zoneinfo" -maxdepth 1 -mindepth 1 -type d | while read line; do
		line="$(basename "$line")"
		if [ "${line}" != "posix" ] && [ "${line}" != "right" ]; then
			echo "${line}"
		fi
	done
}

check_for_region(){
		printRegions | while read line; do
			if [ "$1" = "${line}" ]; then
				echo "found"
				break
			fi
		done
}


printZones(){
	find "/usr/share/zoneinfo/${1}" -maxdepth 1 -mindepth 1 -type f | while read line; do
		line="$(basename "$line")"
		if [ "${line}" != "posix" ] && [ "${line}" != "right" ]; then
			echo "${line}"
		fi
	done
}

check_for_zone(){
		printZones "${2}" | while read line; do
			if [ "$1" = "${line}" ]; then
				echo "found"
				break
			fi
		done
}
set_timezone(){
while true; do
		echo "Type \"L\" to see regions. Or type a region or, otherwise type \"C\" for cancel.\n"
		read option12
	if [ "${option12}" = "L" ] || [ "${option12}" = "l" ]; then
		printRegions "${1}" | less
	elif [ "${option12}" = "C" ] || [ "${option12}" = "c" ]; then
		echo ""
		echo "***Not setting timezone.***"
		echo ""
		break
	else
		if [ "$(check_for_region "${option12}")" = "found" ]; then
				while true; do
				echo "Type \"L\" to see zones. Or type a zone or, otherwise type \"C\" for cancel.\n"
					read option13
					if [ "${option13}" = "L" ] || [ "${option13}" = "l" ]; then
						printZones "${option12}" | less
					elif [ "${option13}" = "C" ] || [ "${option13}" = "c" ]; then
						echo ""
						echo "***Not setting timezone.***"
						echo ""
						break
					else
						if [ "$(check_for_zone "${option13}" "${option12}")" = "found" ]; then
							echo "Setting timezone to ${option12}/${option13} ..."
							ln -sf "/usr/share/zoneinfo/${option12}/${option13}" "${1}/etc/localtime"
							break
						fi
					fi
				done
			break
		fi
	fi
done
}

#SECTION: LOCALE ...

printListOfLocales(){
	off="true"
	OLD_IFS="$IFS"
	IFS='\n'
	cat "${1}/etc/locale.gen" | while read line; do
		if [ "$line" = "" ]; then
			off="false"
		else
			if [ "$off" = "false" ]; then
				echo "${line}" | cut -d " " -f 2
			fi
		fi

	done
	IFS="$OLD_IFS"
}

check_for_locale(){
		printListOfLocales "$1" | while read line; do
			if [ "$2" = "${line}" ]; then
				echo "found"
				break
			fi
		done
}

set_locale(){
while true; do
		echo "Type \"L\" to see locales. Or type a locale or, otherwise type \"C\" for cancel.\n"
		read option7
	if [ "${option7}" = "L" ] || [ "${option7}" = "l" ]; then
		printListOfLocales "${1}" | less
	elif [ "${option7}" = "C" ] || [ "${option7}" = "c" ]; then
		echo ""
		echo "***Not setting locale.***"
		echo ""
		break
	else
		if [ "$(check_for_locale "${1}" ${option7})" = "found" ]; then
			sed -i "s/^# ${option7} /${option7} /g" "${1}/etc/locale.gen"
			${thechroot} "${1}" /usr/sbin/locale-gen
			${thechroot} "${1}" /usr/sbin/update-locale LANG="${option7}"
			break
		fi
	fi
done
}

#SECTION: KEYBOARD LAYOUT
printListOfKeymaps(){
	find "${1}/usr/share/X11/xkb/symbols/" -maxdepth 1 -type f | sort | while read line4; do
		basename "${line4}"
	done
}

check_for_layout(){
		OLD_IFS="$IFS"
		IFS='\n'
		printListOfKeymaps "$1" "$3" | while read line3; do
			if [ "$2" = "$(echo ${line3} | cut -f 2)" ]; then
				echo "found"
				break
			fi
		done
		IFS="$OLD_IFS"
}


choose_layout(){
while true; do
		printf "*** Type \"L\" to see keyboard layouts. ***\n"
		printf "*** Type a layout code to set a layout, ***\n"
		printf "*** Or otherwise type \"C\" to not bother setting a layout. ***\n"
		read option8
	if [ "${option8}" = "L" ] || [ "${option8}" = "l" ]; then
		printf "*** (Press q to exit list) ***\n%s" "$(printListOfKeymaps "${1}" "! layout")" | less
	elif [ "${option8}" = "C" ] || [ "${option8}" = "c" ]; then
		echo ""
		printf "***Not setting keyboard layout.***"
		echo ""
		break
	else
		if [ "$(check_for_layout "${1}" "${option8}" "! layout")" = "found" ]; then
			printf "Setting layout to %s.\n\n" "${option8}"
			sed -i "s/XKBLAYOUT=*/XKBLAYOUT=\"${option8}\"/g" "${1}/etc/default/keyboard"
			break
		fi
	fi
done
}


if [ "$1" = "" ]; then
	echo "Argv1: The partition to install EverdayOS into"
	exit
fi

mkdir /mnt/tempmount

mount "$1" /mnt/tempmount
if [ "$?" != "0" ]; then
	echo "MOUNT ERROR ... Argv1: The partition to install EverdayOS into"
	exit
fi

/sbin/swapout_rootfs.sh "/mnt/tempmount" "/"

sudo mount --bind "/proc" /mnt/tempmount/proc
sudo chroot "/mnt/tempmount" /usr/sbin/update-initramfs -u
sudo chroot "/mnt/tempmount" /usr/sbin/update-grub
sudo umount /mnt/tempmount/proc

thepwd="/mnt"

dest="${thepwd}/tempmount"

cd "${dest}"

#restore permissions
echo "Setting permissions ..."
setfacl --restore=saved-permissions 2>/dev/null
echo "Permissions all set."

if [ ! -d "/mnt/tempmount/home/user" ]; then
	sudo chroot /mnt/tempmount adduser "user"
fi

#FOR EFI
mkdir -p tempmount/boot/extlinux
echo "MENU TITLE Boot Menu" > tempmount/boot/extlinux/extlinux.conf
echo "PROMPT 1" >> tempmount/boot/extlinux/extlinux.conf
echo "DEFAULT 1" >> tempmount/boot/extlinux/extlinux.conf
echo "" >> tempmount/boot/extlinux/extlinux.conf
echo "label 1" >> tempmount/boot/extlinux/extlinux.conf
echo "    MENU LABEL Myixos" >> tempmount/boot/extlinux/extlinux.conf
echo "    KERNEL /vmlinuz" >> tempmount/boot/extlinux/extlinux.conf
echo "    APPEND initrd=/initrd.img root=LABEL=${THELABEL} init=/sbin/init" >> tempmount/boot/extlinux/extlinux.conf
echo "    TIMEOUT 1" >> tempmount/boot/extlinux/extlinux.conf

#FOR LEGACY BOOT
ln -s /boot/extlinux/extlinux.conf tempmount/boot/syslinux.cfg

while true; do
printf "Type the alphanumeric hostname you wish to use for this machine and press return\n(\"-\" characters are also allowed).\n"
	read hostname
	#check if alphanumeric
	if [ "$(echo "$hostname" | sed "s#[A-Z]\|[a-z]\|[0-9]\|\-##g" )" = "" ]; then
		printf "%s\n" "$hostname" > "${dest}/etc/hostname"
		chmod 644 "${dest}/etc/hostname"
		chown root:root "${dest}/etc/hostname"

		printf "127.0.0.1\tlocalhost\n" > "${dest}/etc/hosts"
		printf "127.0.1.1\t%s\n" "$hostname" >> "${dest}/etc/hosts"
		printf "::1\t\tlocalhost ip6-localhost ip6-loopback\n" >> "${dest}/etc/hosts"
		printf "ff02::1\t\tip6-allnodes\n" >> "${dest}/etc/hosts"
		printf "ff02::2\t\tip6-allrouters\n" >> "${dest}/etc/hosts"
		chmod 644 "${dest}/etc/hosts"
		chown root:root "${dest}/etc/hosts"

		break
	fi
done

choose_layout "${dest}"

#set_locale "${dest}"
set_timezone "${dest}"

sudo umount /mnt/tempmount

echo "All done!"

umask "${OLD_UMASK}"
