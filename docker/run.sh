#!/bin/bash

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
  echo "persistent_location=\"$persistent_location\"" > settings.sh
fi

# build image everytime, fast if no update needed
docker build -t nemdev .

# run container
# 7890: nis
# 7891: mitmweb
# 7892: mitmproxy console

if docker ps --format '{{.Names}}' | grep nemdev>/dev/null ; then
  # container is running, do an exec
  # bash -i to get an interactive shell, and aliases loaded
  docker exec -it nemdev bash -i -c "${@:-bash}"
else
  docker run -it --rm -v $persistent_location:/var/lib/nem -p 8081:8081 -p 7890:7890 -p 7891:7891 -p 7892:7892 --name nemdev nemdev bash -c "[[ $with_nis -eq 1 ]] && supervisorctl start nis ; ${@:-bash}"
fi
