#!/bin/sh
if [ "$1" = "nocd" ]; then
qemu-system-i386 -m 4G -hda thehdd.qcow -enable-kvm -boot d
else
qemu-system-i386 -m 4G -hda thehdd.qcow -enable-kvm -cdrom mountpoint/workdir/devuan-custom-*.iso -boot d
fi
