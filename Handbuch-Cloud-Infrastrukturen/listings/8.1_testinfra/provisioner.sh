#!/bin/sh

apt-get update
apt-get install -y nginx
echo '<html><body><p>Provisioned!</p></body></p>'> /var/www/html/index.nginx-debian.html

mkfs.ext4 -m 0 /dev/sdc
mkdir /mnt2
mount /dev/sdc /mnt2
chown myuser.myuser /mnt2
uuid=$(lsblk -o +UUID | awk '/sdc/{print $(8)}')
echo "UUID=$uuid /mnt2 ext4 defaults 0 2" >> /etc/fstab

mkfs.ext4 -m 0 /dev/sdd
mkdir /mnt3
mount /dev/sdd /mnt3
chown myuser.myuser /mnt3
uuid=$(lsblk -o +UUID | awk '/sdd/{print $(8)}')
echo "UUID=$uuid /mnt2 ext4 defaults 0 2" >> /etc/fstab
