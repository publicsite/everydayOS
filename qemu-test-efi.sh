#!/bin/sh
if [ "$1" = "nocd" ]; then
qemu-system-i386 -bios bios.bin -m 4G -enable-kvm -hda thehdd.qcow -boot d
else
qemu-system-i386 -bios bios.bin -m 4G -enable-kvm -hda thehdd.qcow -cdrom mountpoint/workdir/everydayOS-*.iso -boot d
fi
