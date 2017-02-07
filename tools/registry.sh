#!/bin/bash
#set -o errexit -o pipefail

ENV_SETUP=".env"
source "$ENV_SETUP"

tput setaf 1; echo 'This will enable the Docker daemons in the cluster to connect to registry.marathon.mesos:5000'

# Distribute the addInsecureRegistry.sh script to all nodes in the cluster.
FILE1=agentlist
hosts1=`cat $FILE1`

for line in $hosts1;
do
  /usr/bin/scp addInsecureRegistry.sh $line:~
done

pdsh -R ssh -l $CLUSTER_USERNAME -w  ^agentlist  "sudo addInsecureRegistry.sh"