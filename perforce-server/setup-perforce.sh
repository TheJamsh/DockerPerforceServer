#!/bin/bash
set -e

# Set global vars
export P4D_CASE_SENSITIVE="${P4D_CASE_SENSITIVE:-true}"

# link p4dctl service configuration file into DATA/config/etc/perforce/
if [[ ! -d "${DATAVOLUME}"/config/etc ]]; then
	echo "Initializing configuration files in /etc/perforce/"
	mkdir -p "${DATAVOLUME}"/config/etc
	cp -rf /etc/perforce/* "${DATAVOLUME}"/config/etc
	export FRESHINSTALL=1
fi

# setup hard link in docker volume directory to default perforce config location
mv /etc/perforce /etc/perforce.orig
ln -s "${DATAVOLUME}"/config/etc /etc/perforce

# Run all subscripts (in subshell to prevent environment variable changes)
# This also allows these scripts to "exit" without breaking the flow
(
	for f in /docker-startup.d/*.sh; do
		bash "${f}" || exit 1
	done
)

# Brief pause
sleep 1

echo "Stopping Server prior to docker startup..."
gosu perforce p4dctl stop "${P4SVCNAME}" &>dev/null

# Return to next dockerfile command
exec "$@"

# p4 info

# Tail the log and output it
# Note, this only works on the FIRST run of the container, for some reason
# exec /usr/bin/tail --pid=$(cat /var/run/p4d.$P4SVCNAME.pid) -F "${DATAVOLUME}/${P4SVCNAME}/logs/log"