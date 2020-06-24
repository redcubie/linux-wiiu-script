#!/bin/bash

x=${1%%.*}
y=${x##*/}
z=$PWD

echo "Making file ${y}.img"
truncate -s 768M ${y}.img

echo "Attaching ${y}.img to /dev/loop0"
losetup /dev/loop0 ${y}.img

echo "Making partition table"
parted -s /dev/loop0 -- mklabel msdos \
mkpart primary ext4 4M -1s 2>&1 > /dev/null

echo "Making functioning ext4 partiton"
mkfs.ext4 /dev/loop0p1 > /dev/null 2>&1

echo "Making mountpoint at /mnt/${y}"
mkdir /mnt/${y}

echo "Mounting ext4 partition at /mnt/${y}"
mount /dev/loop0p1 /mnt/${y}

echo "Changing to /mnt/${y}"
cd /mnt/${y}

echo "Untarring rootfs $z/$1"
tar -xpvf $z/$1 > /dev/null

echo "Changing out of mountpoint"
cd /mnt

echo "Unmounting ext4 partition"
umount /dev/loop0p1

echo "Detaching loop device /dev/loop0"
losetup -d /dev/loop0

echo "Deleting mountpoint /mnt/${y}"
rm -rf /mnt/${y}
