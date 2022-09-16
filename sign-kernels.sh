#!/bin/bash
conf="/etc/secureboot.conf"
[ -f $conf ] && source $conf || echo "conf not found at $conf"; exit 1;

for kernel in $(ls /boot | grep "vmlinuz"); do
	sbsign --key $mok_key --cert $mok_crt --output /boot/$kernel /boot/$kernel
done
