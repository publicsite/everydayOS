#!/bin/sh
if [ "$1" = "nocd" ]; then
qemu-system-x86_64 -m 4G -hda thehdd.qcow -enable-kvm -boot d
else
qemu-system-x86_64 -m 4G -hda thehdd.qcow -enable-kvm -cdrom mountpoint/workdir/everydayOS-*.iso -boot d
fi
