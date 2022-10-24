#!/bin/bash
conf="/etc/secureboot.conf"
if [ -f $conf ]; then 
	source $conf
else
	echo "conf not found at $conf"
	exit 1
fi

# copied from Ubuntu
CD_MODULES="
	all_video
	boot
	btrfs
	cat
	chain
	configfile
	echo
	efifwsetup
	efinet
	ext2
	fat
	font
	gettext
	gfxmenu
	gfxterm
	gfxterm_background
	gzio
	halt
	help
	hfsplus
	iso9660
	jpeg
	keystatus
	loadenv
	loopback
	linux
	ls
	lsefi
	lsefimmap
	lsefisystab
	lssal
	memdisk
	minicmd
	normal
	ntfs
	part_apple
	part_msdos
	part_gpt
	password_pbkdf2
	png
	probe
	reboot
	regexp
	search
	search_fs_uuid
	search_fs_file
	search_label
	sleep
	smbios
	squash4
	test
	true
	video
	xfs
	zfs
	zfscrypt
	zfsinfo
	"

GRUB_MODULES="$CD_MODULES
	cryptodisk
	gcry_arcfour
	gcry_blowfish
	gcry_camellia
	gcry_cast5
	gcry_crc
	gcry_des
	gcry_dsa
	gcry_idea
	gcry_md4
	gcry_md5
	gcry_rfc2268
	gcry_rijndael
	gcry_rmd160
	gcry_rsa
	gcry_seed
	gcry_serpent
	gcry_sha1
	gcry_sha256
	gcry_sha512
	gcry_tiger
	gcry_twofish
	gcry_whirlpool
	luks
	lvm
	mdraid09
	mdraid1x
	raid5rec
	raid6rec
	"
efi_path=${esp}/EFI/${bootloader_id}/
echo "about to install grub with bootloader-id $bootloader_id, esp $esp, and path $efi_path"
echo "installing in 5 seconds... ctrl-c to cancel"
sleep 5s
echo "installing grub..."
grub-install --target=x86_64-efi --efi-directory=$esp --modules="${GRUB_MODULES}" --sbat=/usr/share/grub/sbat.csv --bootloader-id="${bootloader_id}"
# install shim and cert
echo "copying shim and certificate..."
cp -t ${efi_path} /usr/share/shim-signed/{shim,mm}x64.efi
cp $mok_cer ${efi_path}
echo "signing grub..."
sbsign --key $mok_key --cert $mok_crt --output ${efi_path}grubx64.efi ${efi_path}grubx64.efi
# update boot to use shim
echo "adding secure boot entry..."
efibootmgr --create --disk $(findmnt ${esp} -o SOURCE | grep "/dev") --loader /EFI/${bootloader_id}/shimx64.efi --label "$bootloader_id (Secure Boot)"
echo "signing kernels..."
sign-kernels
echo "done!"
