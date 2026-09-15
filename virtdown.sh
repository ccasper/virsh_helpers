#!/bin/bash

#echo "$0 <name>"
#sudo virsh --connect qemu:///system destroy ${1?}
#sudo virsh --connect qemu:///system undefine ${1?} --remove-all-storage --snapshots-metadata --managed-save

if [ -z "$1" ]; then
    echo "Usage: $0 <name>"
    exit 1
fi

VM="${1?}"

read -rp "Permanently delete VM '$VM' and its storage? [y/N] " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Cancelled."
    exit 0
fi


# Check that the VM exists
if ! sudo virsh --connect qemu:///system dominfo "$VM" >/dev/null 2>&1; then
    echo "Error: VM '$VM' does not exist."
    exit 1
fi

# Destroy the VM if it is running
if sudo virsh --connect qemu:///system domstate "$VM" | grep -q "running"; then
    echo "Stopping $VM..."
    sudo virsh --connect qemu:///system destroy "$VM" || exit 1
else
    echo "$VM is already shut off."
fi

# Remove the VM definition, NVRAM, storage, snapshots metadata, and managed-save state
echo "Removing $VM..."
sudo virsh --connect qemu:///system undefine "$VM" \
    --nvram \
    --remove-all-storage \
    --snapshots-metadata \
    --managed-save

if [ $? -eq 0 ]; then
    echo "Successfully deleted $VM."
else
    echo "Error: Failed to delete $VM."
    exit 1
fi

