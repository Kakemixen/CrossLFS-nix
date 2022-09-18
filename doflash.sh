#! /bin/sh

set -eux

dev=$1
mnt=$2

parted --script ${dev} mklabel msdos
parted --script ${dev} mkpart primary fat32 1MiB 301MiB
parted --script ${dev} mkpart primary ext4 301MiB 100%

mkfs.vfat -F 32 -n boot ${dev}1
mkfs.ext4 -F ${dev}2

mkdir -p ${mnt}

mount ${dev}2 ${mnt}
mkdir -p ${mnt}/boot
mount ${dev}1 ${mnt}/boot

sudo cp -rL result/boot/* ${mnt}/boot/

umount ${mnt}/boot
umount ${mnt}
