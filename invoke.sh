#!/bin/bash
# This wants to be an handy script to wrap the usage of invoke.
# This tool is supposed to work only from the base project directory.

set -e

die() {
  echo -e "$2" >&2
  exit $1
}

declare -A COLLECTION
COLLECTION[image]="packer"
COLLECTION[role]="molecule"
COLLECTION[deployment]="terraform"

TYPE="${1}"
shift

case "${TYPE}" in
  --help)
    cat <<HELP
SYNOPSIS

  ${0} --help
  ${0} image|role NAME/VERSION [invoke_options] [ [task_name] [task_options] ... ]
  ${0} deployment NAME/OWNER [invoke_options] [ [task_name] [task_options] ... ]

DESCRIPTION
  Runs automation tasks on a specific types of objects within the
  infrastructure. The task names depend on the type of the object.

  --help                          Prints this help message. Any other argument
                                  will be discarded.
EXAMPLES

  $ bash invoke.sh deployment consul/defalut up
  $ bash invoke.sh deployment spark-cluster/vvi plan --to update
  $ bash invoke.sh role hail-base/HEAD test
  $ bash invoke.sh image base/0.1.0 build
HELP
    exit 0
  ;;
  image|role)
    IFS="/" read INVOKE_ROLE_NAME INVOKE_ROLE_VERSION <<<"${1}"
    export INVOKE_ROLE_NAME INVOKE_ROLE_VERSION
  ;;
  deployment)
    IFS="/" read INVOKE_DEPLOYMENT_NAME INVOKE_DEPLOYMENT_OWNER <<<"${1}"
    export INVOKE_DEPLOYMENT_NAME INVOKE_DEPLOYMENT_OWNER
  ;;
  *)
    die 1 "Sorry, cannot automate \`${TYPE}'"
  ;;
esac

shift

# Creates python3's virtualenv
if [ ! -d "${PWD}/py3" ] ; then
  PYTHON=$(which python3)
  if [ -x "${PYTHON}" ] ; then
    "${PYTHON}" -m venv "${PWD}/py3"
  else
    die 3 "Cannot find python3 in PATH, or \`${PYTHON}' is not executable"
  fi
fi

# Activates python3's virtualenv
if [ -z "${VIRTUAL_ENV}" ] ; then
  if [ -f "${PWD}/py3/bin/activate" ] ; then
    source ./py3/bin/activate
  else
    die 4 "Cannot find ${PWD}/py3/bin/activate\n\tvirtualenv is broken, you can remove the direcotry and run ${0} again"
  fi
fi

# Install all python modules
pip install --requirement requirements.txt

# User needs to source the right openrc.sh file.
if [ -z "${OS_PROJECT_NAME}" ] ; then
  die 1 "OS_PROJECT_NAME is empty: you need to source the right openrc.sh file"
fi

source "os_projects/${OS_PROJECT_NAME}.rc"

# These variables will describe the exact cloud / project in which to operate, in invoke
export INVOKE_META_PROGRAMME="${META_PROGRAMME:-hgi}"
export INVOKE_META_ENV="${META_ENV:-dev}"
export INVOKE_META_PROVIDER="${META_PROVIDER:-openstack}"
export INVOKE_META_DATACENTER="${META_DATACENTER:-eta}"

# Runs the actual invoke command
invoke --collection "tasks/${COLLECTION[${TYPE}]}" "${@}"
