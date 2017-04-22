#!/bin/bash

set -x
# script to run the dev guide's docker image.
# creates a settings.sh file where the path of directory holding the persistent data
# accepts --no-nis as first argument to not start nis in the container

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"

# go to script directory to have Dockerfile available
cd $script_dir

# check start flag
with_nis=1
if [[ $# -gt 0 ]] && [[ $1 == "--no-nis" ]]; then
  with_nis=0
  shift
fi

# we store the persistent data location for ease
if [[ -f $script_dir/settings.sh ]]; then 
  . $script_dir/settings.sh
else
  echo "It appears no saved settings have been detected. We will create one now, please answer the questions below"
  while [[ ! -d "$persistent_location" ]] ; do
    [[ -z $persistent_location ]] || echo "Directory not found: $persistent_location"
    echo "In which *existing* directory should the persistent data of the container be stored? (it should exist, no directory will be created)"
    read persistent_location
  done
  echo "#if you change this, change also mitp/.env!\nexport persistent_location=\"$persistent_location\"" > settings.sh
fi

containers=$(docker ps --format '{{.Names}}')
nis_container=$(echo "$containers" | grep nis)
mitm_container=$(echo "$containers" | grep mitm)

# start docker containers if needed, possibly with nis
if [[ -z "$nis_container" ]] ; then 
  docker-compose up -d
  [[ $with_nis -eq 1 ]] && docker exec -it docker_nemdevnis_1 supervisorctl start nis ;
fi

cat <<EOF


###############################################################################
Welcome to the NEM developer's guide Docker containers.
Two containers have been started, one running NIS ($nis_container), and the
other ($mitm_container) running mitmproxy.

Only the mitmproxy container has ports mapped to your host:
- 7890 : to contact the NIS instance running in the nis container through mitmproxy
- 7778 : to contact the NIS instance' websocket port through mitmproxy
- 8081 : to view requests to NIS intercepted by mitmproxy
- 8082 : to view websocket requests to NIS intercepted by mitmproxy

Here are custom commands that are recognised. You can start launch them with 
the run.sh helper, with docker run, or from the shell in the container.

- repl.js : open the node repl in the mitm container, with nem-sdk loaded under 
            the nem object.
- mitm    : execute mitmproxy. This lets you inspect requests you send to it in a 
            ncurse. interface.
            It listens on your hosts's localhost interface on port 7890 and 
            proxies your request to NIS

You can also pass options:

--no-nis : do not start nis


###############################################################################

EOF

if [[ -n "$@" ]]; then
  docker exec -it $mitm_container "$@"
fi
end
