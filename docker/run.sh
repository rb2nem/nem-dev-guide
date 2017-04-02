#!/bin/bash

# script to run the dev guide's docker image.
# creates a settings.sh file where the path of directory holding the persistent data
# 

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"

# go to script directory to have Dockerfile available
cd $script_dir

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
docker run -it --rm -v $persistent_location:/var/lib/nem -p 7890:7890 nemdev bash
