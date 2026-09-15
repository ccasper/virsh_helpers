#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Run this script as root."
    exit 1
fi

apt install -y \
    qemu-system-x86 \
    libvirt-daemon-system \
    libvirt-clients \
    virtinst \
    bridge-utils


# Debug Details
virsh net-list --all
virsh list --all
for vm in $(virsh list --name); do
    echo "===== $vm ====="
    virsh domiflist "$vm"
done
ip -br link
bridge link


BRIDGE="br0"
BRIDGE_CONFIG="/etc/network/interfaces.d/${BRIDGE}.cfg"


for iface_path in /sys/class/net/*; do
    iface=$(basename "$iface_path")

    [[ "$iface" == "lo" ]] && continue
    [[ "$iface" == "br0" ]] && continue
    [[ -d "$iface_path/bridge" ]] && continue
    [[ ! -e "$iface_path/device" ]] && continue

    PHYIFACE="$iface"
done
MAC=$(cat "/sys/class/net/${PHYIFACE?}/address")

echo "Physical interface: ${PHYIFACE?} MAC: ${MAC?}"

cat > "$BRIDGE_CONFIG" <<EOF
auto $BRIDGE
iface $BRIDGE inet dhcp
    hwaddress ether $MAC
    bridge_ports $PHYIFACE
    bridge_stp off
    bridge_fd 0
    bridge_maxwait 0

auto $PHYIFACE
iface $PHYIFACE inet manual
EOF

# Filter out old rules related to the physical interface
sed -i "/^[[:space:]]*[^#].*${PHYIFACE}/ s/^/#/" /etc/network/interfaces


# Eliminate the virtual NAT which is problematic for circular storms
if virsh net-info default >/dev/null 2>&1; then
    virsh net-destroy default 2>/dev/null || true
    virsh net-autostart default --disable 2>/dev/null || true
    virsh net-undefine default 2>/dev/null || true
fi
