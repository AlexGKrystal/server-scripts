#!/bin/bash

# Stephen Williams
# System Administrator
# Krystal Hosting
# 03/04/24

#########################
set -euo pipefail       #
IFS=$'\n\t'             # http://redsymbol.net/articles/unofficial-bash-strict-mode/
#########################


logger () {
  echo "$(date "+%a %d %b - %T") | ${1} | Message: ${2}" >> "$working_dir/log_file.txt"
}


network_reload="false"
working_dir="/root/mac_switch"

[ -d "$working_dir" ] || mkdir "$working_dir"
[ -d "${working_dir}/backups" ] || mkdir "${working_dir}/backups"
[ -e "${working_dir}/mac.modified" ] && logger "INFO" "mac.modified file detected, exiting." && exit 1 # Quit if the mac has already been modified.

sleep $(( 1 + RANDOM % 10 )) # Random delay to try and avoid cron conflicts on boot.

for conf_file in /etc/sysconfig/network-scripts/ifcfg-bond0_slave_{1,2}; do
	logger "INFO" "Checking Mac Address consistency in ${conf_file}"
	curr_mac=$(awk -F "=" '/HWADDR/ {print $2}' "$conf_file" | tr '[:upper:]' '[:lower:]')
	device=$(grep "DEVICE=" "$conf_file" | cut -d"=" -f 2)
	# Sometimes an interface will have a hardware-set mac adddress "permaddr", if this is detected, that address is used, rather than the generic one provided by "ip a s"
	new_mac=$(ip a s | grep -A 1 "$device" | tail -n 1 | awk '{if ($0 ~ /permaddr/) {start = index($0, "permaddr") + length("permaddr "); print substr($0, start)} else {print $2}}' | tr '[:upper:]' '[:lower:]')

	if [[ ! "$curr_mac" =~ ..:..:..:..:..:.. || ! "$new_mac" =~ ..:..:..:..:..:.. ]]; then # Verify contents at least resemble a mac address
		logger "CRIT" "Script unable to obtain one or more mac addresses, variables logged below..."
		logger "INFO" "curr_mac variable set: ${curr_mac}, new_mac variable set: ${new_mac}. Please review."
		exit 1
	fi

	if [ "$curr_mac" != "$new_mac" ]; then
		logger "WARN" "Discrepency detected in ${conf_file##*/} for ${device}. A backup can be found here: ${working_dir}/backups/"
		cp -p "$conf_file" "$working_dir/backups/"
		logger "INFO" "Updating Mac Address in ${conf_file##*/}. Old Address: ${curr_mac} New Address: ${new_mac}"
		sed -i -r 's/..:..:..:..:..:../'"${new_mac}"'/' "$conf_file"
		network_reload="true"
	else
		logger "INFO" "Mac Address in config file and interface ${device} match. Will check again in 5 minutes."
	fi

done

if [ "$network_reload" == "true" ]; then
	logger "WARN" "Pending network config changes detected, restarting network."
	systemctl restart network
	touch "${working_dir}/mac.modified" && logger "INFO" "mac.modfied file created. This script will not run again."
	if [ "$(systemctl is-active network)" == "active" ]; then
		logger "INFO" "Network restart complete"
	else
		logger "CRIT" "Network status unknown"
	fi
fi
