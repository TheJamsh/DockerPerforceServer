#!/bin/bash
set -e

# Configure permissions. 'perforce' user needs to own everything in the P4ROOT and P4SSL directories
echo "Setting P4 Root Permissions.."
for DIR in "${P4ROOT}"; do
	mkdir -p "${DIR}"
	chown -R perforce:perforce "${DIR}"
done

echo "Setting P4 SSL Permissions.."
mkdir -m 0700 -p "${P4SSLDIR}"
chown -R perforce:perforce "${P4SSLDIR}"
chmod 0600 "${P4SSLDIR}"/* &>/dev/null || true
