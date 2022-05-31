#!/bin/sh
# /etc/keepalived/check_vpnserver.sh
errorExit() {
    echo "*** $*" 1>&2
    exit 1
}
if netstat -nlp | grep -q 52345; then
    echo "OK"
    return 0
else
    echo "Error server down"
    return 1
fi