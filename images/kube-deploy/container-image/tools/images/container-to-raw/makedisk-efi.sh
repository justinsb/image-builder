#!/bin/bash

set -ex
set -o pipefail

# Create a (sparse) 8 gig image
dd if=/dev/null bs=1M seek=8192 of=${DISK}

#Create partitions
# Tip: sfdisk -l -d ${DISK} can print the instructions for an existing disk
sfdisk "$DISK" << EOF
label: gpt
unit: sectors

# EFI system
p15 : start=2048, size=260096, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B
# Linux
p1 : start=262144, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4
EOF


LOOPBACK_DEVICE=`losetup --show -f -P ${DISK}`
echo "LOOPBACK_DEVICE=${LOOPBACK_DEVICE}"

function cleanup_mounts {
  umount ${MNT}/boot/efi || true
  umount ${MNT}/dev/pts || true
  umount ${MNT}/proc || true
  umount ${MNT}/sys || true
  umount ${MNT}/dev || true
  umount ${MNT} || true

  umount ${LOOPBACK_DEVICE}p1 || true
  umount ${LOOPBACK_DEVICE}p15 || true
  losetup -l
  losetup -d ${LOOPBACK_DEVICE} || true
}
trap cleanup_mounts EXIT

losetup -l


ROOT_DEVICE=${LOOPBACK_DEVICE}p1
EFI_DEVICE=${LOOPBACK_DEVICE}p15

mkfs.ext4 -i 4096 -L ROOT ${ROOT_DEVICE}

# Don’t force a fsck check based on dates
tune2fs -c 0 -i 0 ${ROOT_DEVICE}

fdisk -l

MNT=/mnt
mkdir -p ${MNT}
mount -t ext4 ${ROOT_DEVICE} ${MNT}

# Expand the tar file
tar -x -C ${MNT} -f ${SRC}

# Inject the correct UUID for the root device, replacing the UUID_ROOT placeholder
UUID_ROOT=`blkid -s UUID -o value ${ROOT_DEVICE}`
sed -i -e "s@{{UUID_ROOT}}@${UUID_ROOT}@g" ${MNT}/etc/fstab

mkfs.vfat -F 32 -n ESP ${EFI_DEVICE}
UUID_EFI=`blkid -s UUID -o value ${EFI_DEVICE}`
echo >> /mnt/etc/fstab << EOF
UUID=${UUID_EFI} /boot/efi vfat defaults 0 0
EOF
mkdir -p /mnt/boot/efi
mount -t vfat ${EFI_DEVICE} ${MNT}/boot/efi

# Fix things that can't be done from docker (todo: move to yaml?)
echo "debian" > ${MNT}/etc/hostname
chroot ${MNT} ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

cat <<EOF | tee ${MNT}/etc/hosts
127.0.0.1       localhost
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

mount --bind /dev ${MNT}/dev
mount --types proc none ${MNT}/proc
mount --types sysfs none ${MNT}/sys
mount --types devpts none ${MNT}/dev/pts

chroot ${MNT} grub-mkconfig -o /boot/grub/grub.cfg
#chroot ${MNT}  grub-install --target=arm64-efi --efi-directory=/boot/efi --bootloader-id=debian --recheck --no-nvram --removable ${LOOPBACK_DEVICE}
chroot ${MNT}  grub-install --target=arm64-efi --force-extra-removable --no-nvram --no-floppy --modules="part_msdos part_gpt" --grub-mkdevicemap=/boot/grub/device.map ${LOOPBACK_DEVICE}
#chroot ${MNT} update-grub

# TODO: We detect some OSes on sda1 in cloudbuild.
# Maybe remove /etc/grub.d/30_os-prober ?
cat ${MNT}/boot/grub/grub.cfg


echo "Created disk image - OK"
