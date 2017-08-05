#!/bin/bash
set -eu

if [[ $# -eq 0 ]] ; then
        exec /usr/bin/supervisord -c /etc/supervisord.conf -n
else
	/usr/bin/supervisord -c /etc/supervisord.conf
	exec su -s /bin/bash -c "$@"
fi

