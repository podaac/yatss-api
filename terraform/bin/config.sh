#!/usr/bin/env bash
set -eo pipefail
while [[ $# -gt 0 ]]
do
VENUE="$1"

source "$(dirname $BASH_SOURCE)/../environments/$VENUE.env"

export TF_IN_AUTOMATION=true  # https://www.terraform.io/cli/config/environment-variables#tf_in_automation
export TF_INPUT=false  # https://www.terraform.io/cli/config/environment-variables#tf_input

export TF_VAR_region="$REGION"
export TF_VAR_stage="$VENUE"

terraform init -reconfigure -backend-config="bucket=$BUCKET" -backend-config="region=$REGION"
