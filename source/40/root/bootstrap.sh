#!/bin/sh

chmod o-rw /tmp
chmod o-rw /var/tmp
chmod o-rw /dev/shm
chmod o-r /proc
mount -o remount,hidepid=2 /proc

apt-get update -y
apt-get install -y acct apache2 php5 libapache2-mod-php5

cp /root/000-default /etc/apache2/sites-enabled/

rm /var/www/index.html
cp /root/index.php /var/www/
cp /root/death-10a035bee652b3f10a4187a79e758378 /var/www/

useradd -m -d /home/death -s /bin/false death

cp /root/flag /home/death/
chown -R root:death /home/death
chmod 440 /home/death/flag
chown root:death /var/www/death-10a035bee652b3f10a4187a79e758378
chmod 2755 /var/www/death-10a035bee652b3f10a4187a79e758378

echo '# ulimit -t 5 -u 50 -m 102400'

echo 'root:ww0x]QkWCN}dox{.qz^95_jy0{Sz-Vu)' | chpasswd
