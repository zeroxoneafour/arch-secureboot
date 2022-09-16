#!/bin/bash
conf="/etc/secureboot.conf"
if [ -f $conf ]; then 
	source $conf
else
	echo "conf not found at $conf"
	exit 1
fi

for kernel in $(ls /boot | grep "vmlinuz"); do
	sbsign --key $mok_key --cert $mok_crt --output /boot/$kernel /boot/$kernel
done
