#!/bin/bash
set -eu

#start nis by default
with_nis=1

if [[ ! -f /opt/nem/package/nis/config-user.properties ]] ; then
	key=$(< /dev/urandom tr -dc a-f0-9 | head -c64)
	name=developer$(< /dev/urandom tr -dc a-f0-9 | head -c16)
	cat >/opt/nem/package/nis/config-user.properties <<-EOF
	nis.bootName = $name
	nis.bootKey = $key
	nem.network = testnet
	EOF
fi


# set owner nem, in case it is mounted from the host
chown -R nem /var/lib/nem
# cleanup old traces
rm -rf /var/lib/nem/traces
mkdir -p /var/lib/nem/traces



if [[ $# -eq 0 ]] ; then
        exec /usr/bin/supervisord -c /etc/supervisord.conf -n
else
	[[ $with_nis -eq 1 ]] && /usr/bin/supervisord -c /etc/supervisord.conf
	exec "$@"
fi

