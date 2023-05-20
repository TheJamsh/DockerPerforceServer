#!/bin/bash
set -e

# Set global vars
export P4D_CASE_SENSITIVE="${P4D_CASE_SENSITIVE:-true}"
export P4D_SECURITY="${P4D_SECURITY:-2}"
export P4D_NO_DEFAULT_DEPOT="${P4D_NODEPOT:-true}"

# link p4dctl service configuration file into /etc/perforce/
CONFDIR="${DATADIR}/config"

if [[ ! -d "${CONFDIR}"/etc ]]; then
	echo "Initializing configuration files in /etc/perforce/"
	mkdir -p "${CONFDIR}"/etc
	cp -rf /etc/perforce/* "${CONFDIR}"/etc
	export FRESHINSTALL=1
fi

# setup hard link in docker volume directory to default perforce config location
mv /etc/perforce /etc/perforce.orig
ln -s "${CONFDIR}"/etc /etc/perforce

# Run all subscripts (in subshell to prevent environment variable changes)
(
	for f in /docker-startup.d/*.sh; do
		bash "${f}" || exit 1
	done
)

sleep 2

exec /usr/bin/tail --pid=$(cat /var/run/p4d.$P4SVCNAME.pid) -F "${DATADIR}/${P4SVCNAME}/logs/log"
