#!/bin/bash
set -e

mkdir -p ${P4ROOT}
chown -R perforce:perforce ${P4ROOT}

/opt/perforce/sbin/configure-helix-p4d.sh ${NAME} -n -p ${P4PORT} -r ${P4ROOT} -u ${P4USER} -P ${P4PASSWD}

#CONFIGURE_P4D_CMD=("/opt/perforce/sbin/configure-helix-p4d.sh")
#CONFIGURE_P4D_CMD+=("-h")

#"$CONFIGURE_P4D_CMD"

#sleep 2

#exec /usr/bin/tail --pid=$(cat /var/run/p4d.$NAME.pid) -F "$DATAVOLUME/$NAME/logs/log"