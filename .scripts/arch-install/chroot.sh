#!/usr/bin/env bash

set-password() {
  local user=${1:-root}
  echo "Set password for user $user"
  while true; do
    passwd $user
    [ $? -eq 0 ] && break
  done
  return 0
}

ln -sf /usr/share/zoneinfo/Asia/Novokuznetsk /etc/localtime
hwclock --systohc

sed -i 's/^#\(ru_RU.UTF-8 UTF-8\|en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

echo "andrey"			>> /etc/hostname
echo "127.0.0.1 localhost"	>> /etc/hosts
echo "::1	localhost"	>> /etc/hosts

pacman -Sy
pacman -S intel-ucode grub efibootmgr --noconfirm
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable dhcpcd

set-password

groupadd sudo
sed -i 's/^# \(%sudo\)/\1/' /etc/sudoers

useradd -m andrey -g users -G sudo
set-password andrey

curl -s https://raw.githubusercontent.com/AndreyMinaev/dotfiles/master/.scripts/arch-install/packages | pacman -S --noconfirm -

su andrey -c 'git clone --bare https://github.com/AndreyMinaev/dotfiles.git $HOME/.dotfiles.git'
su andrey -c 'git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME config --local status.showUntrackedFiles no'
su andrey -c 'rm $HOME/.bash*'
su andrey -c 'git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME checkout'

exit
