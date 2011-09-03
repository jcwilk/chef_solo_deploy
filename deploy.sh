#!/bin/bash

# Usage: ./deploy.sh
#
# It infers the target for the deploy by the files under deploy_target_dir (see below).
# For each host you want to deploy to, put a file in there. Eg, for deploting to "alpha", put alpha.json in.
#
# ls ./deploy_targets
# => alpha.json
# ./deploy.sh
# => (deploys to alpha using alpha.json)

deploy_target_dir="./deploy_targets"
# ls $deploy_target_Dir

json_grepper='\.json$'

for file in `'ls' -1 $deploy_target_dir | 'grep' -E $json_grepper`
do
  path_to_json="$deploy_target_dir/$file"
  host=`echo $file | 'grep' -E $json_grepper | sed 's/.json$//'`

  # The host key might change when we instantiate a new VM, so
  # we remove (-R) the old host key from known_hosts
  ssh-keygen -R "${host#*@}" 2> /dev/null

  tar cj . | ssh -o 'StrictHostKeyChecking no' "$host" '
  sudo rm -rf ~/chef &&
  mkdir ~/chef &&
  cd ~/chef &&
  tar xj &&
  sudo bash install.sh '$path_to_json
done