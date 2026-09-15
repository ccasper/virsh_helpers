#!/bin/bash

sudo virt-install \
  --name ${1?} \
  --ram 6144 \
  --vcpus 1 \
  --disk size=60,format=qcow2,bus=virtio \
  --os-variant debian13 \
  --network bridge=br0,model=virtio \
  --location ./debian-13.6.0-amd64-netinst.iso \
  --initrd-inject=.//debian-preseed.cfg \
  --extra-args "auto=true priority=critical preseed/file=/debian-preseed.cfg console=ttyS0,115200n8 serial" \
  --graphics none


virsh autostart ${1?}

#sudo virt-install \
#  --name ${1?} \
#  --ram 6144 \
#  --vcpus 1 \
#/  --disk size=100,format=qcow2,bus=virtio \
#  --os-variant debian12 \
#  --network bridge=br0,model=virtio \
#  --location /opt/virtual/images/debian-13.6.0-amd64-netinst.iso \
#  --graphics none \
#  --extra-args 'console=ttyS0,115200n8 serial'
