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

if [[ $# -gt 0 ]] && [[ $1 == "--no-nis" ]]; then
  with_nis=0
  shift
fi

# set owner nem, in case it is mounted from the host
chown -R nem /var/lib/nem
cat <<EOF


###############################################################################
Welcome to the NEM developer's guide Docker container.
Here are custom commands that are recognised. You can start launch them with 
the run.sh helper, with docker run, or from the shell in the container.

- repl.js : open the node repl with nem-sdk loaded under the nem object.

You can also pass options to the docker entrypoint:

--no-nis : do not start nis

###############################################################################

EOF

if [[ $# -eq 0 ]] ; then
	[[ $with_nis -eq 1 ]] && exec /usr/bin/supervisord -c /etc/supervisord.conf -n
else
	[[ $with_nis -eq 1 ]] && /usr/bin/supervisord -c /etc/supervisord.conf
	exec "$@"
fi

