#!/bin/sh
if [ "$1" = "nocd" ]; then
qemu-system-x86_64 -bios bios.bin -m 4G -enable-kvm -hda thehdd.qcow -boot d
else
qemu-system-x86_64 -bios bios.bin -m 4G -enable-kvm -hda thehdd.qcow -cdrom mountpoint/workdir/everydayOS-*.iso -boot d
fi
