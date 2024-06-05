#!/bin/sh
# 
# Almalinux9 Post Dedi deploy script
# 22/01/2023 - AlexG
# 
#
# Remove Mac addresses from the Bond config files
sed -i '/^HWADDR=/d' /etc/sysconfig/network-scripts/ifcfg-bond0_port_1
sed -i '/^HWADDR=/d' /etc/sysconfig/network-scripts/ifcfg-bond0_port_2
#
### Editing the VLAN configs ###
#
# Remove the PHYSDEV lines
sed -i '/^PHYSDEV=/d' /etc/sysconfig/network-scripts/ifcfg-VLAN_connection_1
sed -i '/^PHYSDEV=/d' /etc/sysconfig/network-scripts/ifcfg-VLAN_connection_2
#
# Add in Bond config
echo "DEVICE=bond0.2020" >> /etc/sysconfig/network-scripts/ifcfg-VLAN_connection_1
echo "DEVICE=bond0.333" >> /etc/sysconfig/network-scripts/ifcfg-VLAN_connection_2
#
# Restart network service
systemctl restart NetworkManager.service
# Done
