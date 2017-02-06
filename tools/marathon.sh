#!/bin/bash
#set -o errexit -o pipefail

ENV_SETUP=".env"
source "$ENV_SETUP"

#////////////////////////////////
dcos package install --options=./apps/marathon-lb-internal.json marathon-lb --yes
dcos package install --options=./apps/marathon-lb-external.json marathon-lb --yes