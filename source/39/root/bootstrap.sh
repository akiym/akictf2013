#!/bin/sh

chmod o-rw /tmp
chmod o-rw /var/tmp
chmod o-rw /dev/shm
chmod o-r /proc
mount -o remount,hidepid=2 /proc

apt-get update -y
apt-get install -y daemontools daemontools-run

cp /root/flag /flag
chmod 644 /flag

cp /root/giveme_shellcode /giveme_shellcode

mkdir /etc/service/giveme_shellcode
cp /root/service/run /etc/service/giveme_shellcode/
svc -u /etc/service/giveme_shellcode

echo 'root:ko4eh3&.wd*2Rlk>Cw^,vhQ<5j&P,nbJ' | chpasswd
