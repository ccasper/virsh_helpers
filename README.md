# virsh_helpers
Virsh helpers for deploying virtual VMs on a debian/ubuntu server.

./virtinstall.sh will install the packages and bridge network (it also removes the NAT network which can cause network issues)

  - This is idempotent and can be run multiple times.


./virt<name> are helpful utilities for creating and viewing virtual machines.
