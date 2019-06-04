#!/bin/bash
# This wants to be an handy script to wrap the usage of invoke.
# This tool is supposed to work only from the base project directory.

set -e

die() {
  echo -e "$2" >&2
  exit $1
}

# User needs to source the right openrc.sh file.
if [ -z "${OS_PROJECT_NAME}" ] ; then
  die 1 "OS_PROJECT_NAME is empty: you need to source the right openrc.sh file"
fi

source "os_projects/${OS_PROJECT_NAME}.rc"

case "${1}" in
  --help)
    cat <<HELP
SYNOPSIS

  ${0} --help
  ${0} [image | role] NAME/VERSION [invoke_options] [ [task_name] [task_options] ... ]
  ${0} deployment [NAME | NAME/OWNER] invoke_options] [ [task_name] [task_options] ... ]

DESCRIPTION
  Runs automation tasks on a specific types of objects within the
  infrastructure. The task names depend on the type of the object.
  If OWNER is not specified, the value of OS_USERNAME will be used.

  --help                          Prints this help message. Any other argument
                                  will be discarded.
EXAMPLES

  $ bash invoke.sh deployment consul up
  $ bash invoke.sh deployment spark-cluster/vvi plan --to update
  $ bash invoke.sh role hail-base:HEAD test
  $ bash invoke.sh image base:0.1.0 build
HELP
    exit 0
  ;;
  image|role)
    IFS="/" read INVOKE_ROLE_NAME INVOKE_ROLE_VERSION <<<"${2}"
    export INVOKE_ROLE_NAME INVOKE_ROLE_VERSION
  ;;
  deployment)
    IFS="/" read INVOKE_DEPLOYMENT_NAME DEPLOYMENT_OWNER <<<"${2}"
    export INVOKE_DEPLOYMENT_NAME
    export INVOKE_DEPLOYMENT_OWNER="${DEPLOYMENT_OWNER:-"${OS_USERNAME}"}"
  ;;
  *)
    die 1 "Sorry, cannot automate \`${$1}'"
  ;;
esac

COLLECTION="${1}"
shift 2

# Creates python3's virtualenv
if [ ! -d "${PWD}/py3" ] ; then
  PYTHON=$(which python3)
  if [ -x "${PYTHON}" ] ; then
    VIRTUALENV=$(which virtualenv)
    if [ -x "${VIRTUALENV}" ] ; then
      ${VIRTUALENV} --python "${PYTHON}" "${PWD}/py3"
    else
      die 2 "Cannot find virtualenv in PATH, or \`${VIRTUALENV}' is not executable"
    fi
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

# These variables will describe the exact cloud / project in which to operate, in invoke
export INVOKE_META_PROGRAMME="${META_PROGRAMME:?"META_PROGRAMME is null or unset"}"
export INVOKE_META_ENV="${META_ENV:?"META_ENV is null or unset"}"
export INVOKE_META_PROVIDER="${META_PROVIDER:?"META_PROVIDER is null or unset"}"
export INVOKE_META_DATACENTER="${META_DATACENTER:?"META_DATACENTER is null or unset"}"

# Runs the actual invoke command
invoke --collection "tasks/${COLLECTION}" "${@}"
