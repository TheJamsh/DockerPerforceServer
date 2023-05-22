#!/bin/bash
set -e

# Set global vars
export P4D_CASE_SENSITIVE="${P4D_CASE_SENSITIVE:-true}"
export P4D_SECURITY="${P4D_SECURITY:-2}"
export P4D_NO_DEFAULT_DEPOT="${P4D_NODEPOT:-true}"

# link p4dctl service configuration file into /etc/perforce/
if [[ ! -d "${DATA_PATH}"/etc ]]; then
	echo "Initializing configuration files in /etc/perforce/"
	mkdir -p "${DATA_PATH}"/etc
	cp -rf /etc/perforce/* "${DATA_PATH}"/etc
	export FRESHINSTALL=1
fi

# setup hard link in docker volume directory to default perforce config location
mv /etc/perforce /etc/perforce.orig
ln -s "${DATA_PATH}"/etc /etc/perforce

# Run all subscripts (in subshell to prevent environment variable changes)
# This also allows these scripts to "exit" without breaking the flow
(
	for f in /docker-startup.d/*.sh; do
		bash "${f}" || exit 1
	done
)

# Not sure...
sleep 2

# Tail the log and output it
exec /usr/bin/tail --pid=$(cat /var/run/p4d.$P4SVCNAME.pid) -F "${DATA_PATH}/${P4SVCNAME}/logs/log"

exit 0
