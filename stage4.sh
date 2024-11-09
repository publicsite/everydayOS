#!/bin/sh
#stage4.sh :- start of bootable cd code

#we mount the stuff for apt
mount none -t proc /proc
mount none -t sysfs /sys
mkdir -p /dev/pts
mount none -t devpts /dev/pts

THELABEL="EVERYDAYOS"

#enter directory containing this script
cd $(dirname $(realpath $0))

##apt-get install isolinux syslinux-common syslinux-efi xorriso

#copy the installer
cp installToHDD.sh rootfs/sbin/
sed -i "s/THEARCHTOREPLACE/${THEARCH}/g" "rootfs/sbin/installToHDD.sh"
chmod +x rootfs/sbin/installToHDD.sh

cp initOverlay.sh rootfs/sbin/initOverlay.sh
chmod +x rootfs/sbin/initOverlay.sh

#these dirs are required for initOverlay.sh script
mkdir rootfs/overlay
mkdir rootfs/overlay/tmpfs
mkdir rootfs/overlay/mountpoint

mkdir tempmount

###EFI

##rm efiboot-new.img
##mknod /dev/loop0 b 7 0
##dd if=/dev/zero bs=1MB count=256 of=efiboot-new.img

##/sbin/mkfs.vfat -n "BOOT_EFI" efiboot-new.img
##mount -t vfat -o loop efiboot-new.img tempmount

##cp "$(find rootfs/boot/vmlinuz-*)" tempmount/vmlinuz
##cp "$(find rootfs/boot/initrd.img*)" tempmount/initrd.img

##mkdir -p tempmount/EFI/BOOT/

##cp extractdest/efilinux-1.1/efilinux.efi tempmount/EFI/BOOT/BOOTIA32.EFI
##cp extractdest/efilinux-1.1/efilinux.efi tempmount/EFI/BOOT/BOOTX64.EFI

###console=ttyS0
##printf "%s 0:%svmlinuz initrd=0:\\initrd.img root=LABEL=%s init=/sbin/initOverlay.sh\n" "-f" "\\" "${THELABEL}" > tempmount/EFI/BOOT/efilinux.cfg

##umount tempmount

#MBR

#mkdir -p rootfs/isolinux
#cp -a /usr/lib/ISOLINUX/isolinux.bin rootfs/isolinux/
#cp -a /usr/lib/syslinux/modules/bios/ldlinux.c32 rootfs/isolinux/
##cp -a efiboot-new.img rootfs/isolinux/efiboot.img
#mkdir rootfs/kernel
#cp -a /usr/lib/syslinux/memdisk rootfs/kernel #copy bios/memdisk/memdisk

#although u-boot doesn't work for the cdrom, we use it in the installer
##cp -a extractdest/u-boot-*/u-boot-payload.efi rootfs/isolinux/

##this config is for ISOLINUX
#echo "MENU TITLE Boot Menu" > rootfs/isolinux/syslinux.cfg
#echo "PROMPT 1" >> rootfs/isolinux/syslinux.cfg
#echo "DEFAULT 1" >> rootfs/isolinux/syslinux.cfg
#echo "" >> rootfs/isolinux/syslinux.cfg
#echo "label 1" >> rootfs/isolinux/syslinux.cfg
#echo "    MENU LABEL Devuan testing" >> rootfs/isolinux/syslinux.cfg
##setting the path to the symlink /vmlinux doesn't work
#echo "    KERNEL /boot/$(basename "$(find rootfs/boot/vmlinuz-*)")" >> rootfs/isolinux/syslinux.cfg
#echo "    APPEND initrd=/boot/$(basename "$(find rootfs/boot/initrd.img*)") root=LABEL=${THELABEL} init=/sbin/initOverlay.sh" >> rootfs/isolinux/syslinux.cfg
#echo "    TIMEOUT 1" >> rootfs/isolinux/syslinux.cfg

if [ -d "$PWD/topack" ]; then
	rm -rf "$PWD/topack"
fi

cp -a "rootfs" topack
mv "topack" rootfs/
##sudo rm -f "rootfs/topack/qemu-ppc-static"

#this config is for GRUB2
echo 'menuentry "Beam me up, scotty!" {' > "grub.cfg"
echo 'search --no-floppy --set=root --label '${THELABEL} >> "grub.cfg"
echo '	linux /vmlinuz root=LABEL='${THELABEL}' console=tty0 init=/sbin/initOverlay.sh modprobe.blacklist=bochs_drm' >> "grub.cfg"
echo '	initrd /initrd.img' >> "grub.cfg"
echo '}' >> "grub.cfg"
mkdir -p "rootfs/topack/boot/grub"
mv "grub.cfg" "rootfs/topack/boot/grub/grub.cfg"

#WRITE ISO

chroot "rootfs" /usr/bin/grub-mkrescue -o everydayOS-${1}.iso /topack --iso-level 3 -V $THELABEL

mv "rootfs/everydayOS-${1}.iso" ./

rm -rf "rootfs/topack"

##xorriso -as mkisofs \
##  -o devuan-custom-${1}.iso \
##  -V "${THELABEL}" \
##  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
##  -c isolinux/boot.cat \
##  -b isolinux/isolinux.bin \
##  -no-emul-boot \
##  -boot-load-size 4 \
##  -boot-info-table \
##  -eltorito-alt-boot \
##  -no-emul-boot \
##  -isohybrid-gpt-basdat \
##  -e isolinux/efiboot.img rootfs

#unmount stuff
umount /proc
umount /sys
umount /dev/pts
