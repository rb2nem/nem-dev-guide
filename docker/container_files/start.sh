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
cat <<EOF


###############################################################################
Welcome to the NEM developer's guide Docker container.
Here are custom commands that are recognised. You can start launch them with 
the run.sh helper, with docker run, or from the shell in the container.

- repl.js : open the node repl with nem-sdk loaded under the nem object.
- mitm    : execute mitmproxy. This lets you inspect requests you send to it.
            It is available on port 7892

You can also pass options to the docker entrypoint:

--no-nis : do not start nis

The container also has a mitmweb interface available on port 8081.

Ports to which you can send your REST queries (on the host or in the container):

- 7890 : contact you local NIS directly
- 7891 : send the request to mitmweb, which will pass it to your local NIS.
         Inspect requests at http://localhost:8081
- 7892 : send the request to mitmproxy, which will pass it to you local NIS.
         You must first have started mitmproxy by accessing its terminal interface
         by running `run.sh mitm`

###############################################################################

EOF


if [[ $# -eq 0 ]] ; then
        exec /usr/bin/supervisord -c /etc/supervisord.conf -n
else
	[[ $with_nis -eq 1 ]] && /usr/bin/supervisord -c /etc/supervisord.conf
	exec "$@"
fi

