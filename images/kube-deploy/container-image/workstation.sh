#!/bin/bash

set -e
set -x

rm -f workspace/test.img
qemu-img create -f qcow2 -o backing_file=workstation.raw workspace/test.img 40000M

qemu-system-x86_64 \
  -netdev user,id=net0,net=192.168.76.0/24,dhcpstart=192.168.76.9 \
  -net nic,model=virtio,netdev=net0 \
  -display gtk,zoom-to-fit=off,grab-on-hover=on \
  -drive file=workspace/test.img,if=virtio \
  -vga none -device virtio-gpu,xres=1920,yres=1080 \
  -machine accel=kvm -m 32768 -smp 10 \
  -fsdev local,id=share_dev,path=$HOME/.share/,security_model=none \
  -device virtio-9p-pci,fsdev=share_dev,mount_tag=share_dev
