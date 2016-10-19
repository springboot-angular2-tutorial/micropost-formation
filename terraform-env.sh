#!/usr/bin/env bash

set -o pipefail
set -u

function help {
    echo "usage: ${0} <environment> <action> [<args>]"
    exit 1
}

function contains_element () {
    local i
    for i in "${@:2}"; do
        [[ "$i" == "$1" ]] && return 0
    done
    return 1
}

function files_exist(){
  ls ${1} 1> /dev/null 2>&1
}

#All of the args are mandatory.
if [ $# -lt 1 ]; then
    help
fi


# Let's set up our environment
export ENVIRONMENT=$1
export ACTION=$2
ADDTL_PARAMS=${*:3}

CONFIG_FILE=./terraform.cfg

# Let's check the existence of the config file
if [ ! -f $CONFIG_FILE ]; then
    echo "Error: $CONFIG_FILE does not exist. You'll need to create a config file so we know where to set up the remote config."
    exit 1
fi

source ${CONFIG_FILE}

# Let's set up our variables
ALLOWS_VARFILE=(apply plan push refresh destroy)
ENV_FILE=.terraform/environment
ENV_DIR=env/$ENVIRONMENT
VARS_FILE=${ENV_DIR}/vars
VARS_FILE_FLAG=
BUCKET_KEY=$bucket_prefix/state/$ENVIRONMENT
PREVIOUS_ENVIRONMENT=$([ -f $ENV_FILE ] && echo "$(<$ENV_FILE)" || echo "previous")
EXTRA_ARGS=${extra_args:-''}
PRE_CMD=${pre_command:-''}
POST_CMD=${post_command:-''}

# Let's check to see if a vars file exists for the requested environment before proceeding
if [ ! -f $VARS_FILE ]; then
    echo "Error: $VARS_FILE does not exist. You'll need to create a vars file for the requested environment before continuing."
    exit 1
fi

# Checks if current action allows a varfile to be passed
contains_element "$ACTION" "${ALLOWS_VARFILE[@]}"
if [ $? -eq 0 ]; then
    VARS_FILE_FLAG="-var-file=$VARS_FILE"
fi

# Let's check if the requested environment is different from the previous environment
if [ $PREVIOUS_ENVIRONMENT != $ENVIRONMENT ] || [ ! -f '.terraform/terraform.tfstate' ]
then

    # Move current state out of the way to make room for the new state
    mv -f .terraform/terraform.tfstate .terraform/terraform.tfstate.$PREVIOUS_ENVIRONMENT > /dev/null 2>&1
    mv -f .terraform/terraform.tfstate.backup .terraform/terraform.tfstate.backup.$PREVIOUS_ENVIRONMENT > /dev/null 2>&1

    # Let's log the new environment for later
    echo $ENVIRONMENT > $ENV_FILE

    # Set up remote configuration and pull latest version
    terraform remote config -backend S3 -backend-config="bucket=$bucket" -backend-config="key=$BUCKET_KEY" -backend-config="region=$region"

fi

# Let's run the PRE_CMD hook if it's defined
. ${PRE_CMD}

# let's copy environment specific configuration to the root of the directory
if files_exist ${ENV_DIR}/*.tf; then
  cd env/${ENVIRONMENT}
    pax -wrs'/\.tf$/\.env\.tf/' *.tf ../../
  cd ../../
fi

# Let's do work!
terraform $ACTION $VARS_FILE_FLAG $ADDTL_PARAMS ${EXTRA_ARGS}

# Let's remove those environment-specific configuration files we copied earlier
if files_exist *.env.tf; then
  rm *.env.tf
fi

# Let's run the POST_CMD hook if it's defined
eval ${POST_CMD}
