#!/bin/bash
set -e

# Configure service if it hasn't been done already
if ! perforce p4dctl list 2>/dev/null | grep -q "${P4SVCNAME}"; then

	# Assemble the command string to configure perforce in non-interactive mode
	echo "Configuring P4..."
	CONFIGURE_P4D_CMD=("/opt/perforce/sbin/configure-helix-p4d.sh")
	CONFIGURE_P4D_CMD+=("${P4SVCNAME}")
	CONFIGURE_P4D_CMD+=("-n")
	CONFIGURE_P4D_CMD+=("-p" "${P4PORT}")
	CONFIGURE_P4D_CMD+=("-r" "${P4ROOT}")
	CONFIGURE_P4D_CMD+=("-u" "${P4USER}")
	CONFIGURE_P4D_CMD+=("-P" "${P4PASSWD}")
	
	if [[ "${P4D_CASE_SENSITIVE}" == "true" ]]; then
		CONFIGURE_P4D_CMD+=("--case" "0")
	else
		CONFIGURE_P4D_CMD+=("--case" "1")
	fi

	"${CONFIGURE_P4D_CMD[@]}" 1>/dev/null
fi

# Delete default depot if required
if [[ "${P4D_NO_DEPOT}" == "true" ]]; then
    echo "Deleting default depot..."
    p4 depot -d "depot" 1>/dev/null
fi

# Start the Service
p4dctl start -t p4d "${P4SVCNAME}"

# Automatically trust self if using ssl
if echo "${P4PORT}" | grep -q '^ssl:'; then
	p4 trust -y
fi

# write details to p4 config
cat > ~perforce/.p4config <<EOF
P4USER=${P4USER}
P4PORT=${P4PORT}
P4PASSWD=${P4PASSWD}
EOF

# Take ownership of p4config
chmod 0600 ~perforce/.p4config
chown perforce:perforce ~perforce/.p4config

# Login to Server
p4 login <<EOF
${P4PASSWD}
EOF

# Setup Defaults
if [ "${FRESHINSTALL}" = "1" ]; then
    # Load up the default tables
    echo >&2 "First time installation.. setting security configuration"
	
	p4 configure set security="${P4D_SECURITY}" 1>/dev/null		# Security Level
	p4 configure set lbr.proxy.case=1							# disable automatic user account creation
	p4 configure set run.users.authorize=1						# disable unauthorised viewing of user list
	p4 configure set dm.keys.hide=2								# disable unauthorised viewing of config settings
fi

# Output Properties
echo "   P4USER=${P4USER} (the admin user)"

if [ "${P4PASSWD}" == "pass12349ers!" ]; then
    echo -e "\n***** WARNING: USING DEFAULT PASSWORD ******\n"
    echo "Please change as soon as possible:"
    echo "   P4PASSWD=$P4PASSWD"
    echo -e "\n***** WARNING: USING DEFAULT PASSWORD ******\n"
fi