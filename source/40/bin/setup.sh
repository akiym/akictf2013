#!/bin/sh

NAME="ctfq40"
LXC_ROOT="/var/lib/lxc/$NAME"

if [ `id -u` != 0 ]; then
    echo 'permission defined' >&2
    exit
fi

echo "---> Creating container: $NAME"
lxc-create -t debian -n "$NAME" -- -a i386

echo "---> Copying files"
cp ./config "$LXC_ROOT"
cp -f ./interfaces "$LXC_ROOT/rootfs/etc/network/"
cp -Rf root/* "$LXC_ROOT/rootfs/root/"
