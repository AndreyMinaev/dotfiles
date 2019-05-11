#!/usr/bin/env bash

if [ ! -d "/sys/firmware/efi/efivars" ]; then
  echo "UEFI mode is disabled"
  exit 1;
fi

if ! ping -c 1 archlinux.org &> /dev/null ; then
  echo "There is no internet connection"
  exit 1;
fi

timedatectl set-ntp true

if [ ! `sfdisk -l | grep "Disk /dev/sd" | wc -l` -eq 1 ]; then
  echo "More or less than one disk"
  exit 1;
fi

ram=`cat /proc/meminfo | awk /MemTotal/'{ print $2 }'`
swap=$((2 * ram))

sfdisk /dev/sda <<EOF
,550MiB
,20GiB
,${swap}kB
;
EOF

mkfs.fat -F32   /dev/sda1
mkfs.ext4       /dev/sda2
mkswap          /dev/sda3
swapon          /dev/sda3
mkfs.ext4       /dev/sda4

mount /dev/sda2 /mnt
mkdir /mnt/efi
mount /dev/sda1 /mnt/efi
mkdir /mnt/home
mount /dev/sda4 /mnt/home

pacman -Sy
pacstrap /mnt base base-devel

genfstab -U /mnt >> /mnt/etc/fstab

curl https://raw.githubusercontent.com/AndreyMinaev/dotfiles/master/.scripts/arch-install/chroot.sh -O
chmod u+x chroot.sh
mv chroot.sh /mnt/root
arch-chroot /mnt /root/chroot.sh
rm /mnt/root/chroot.sh

echo Finish

