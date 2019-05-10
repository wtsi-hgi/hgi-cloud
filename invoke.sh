#!/bin/bash
# This wants to be an handy script to wrap the usage of invoke.
# This tool is supposed to work only from the base project directory.

set -e

test -f .invokerc && source .invokerc

# These variables will describe the exact cloud / project in which to operate
export INVOKE_META_RELEASE="${META_RELEASE:-eta}"
export INVOKE_META_PROGRAMME="${META_PROGRAMME:-hgi}"
export INVOKE_META_ENV="${META_ENV:-dev}"

die() {
  echo -e "$2" >&2
  exit $1
}

declare -A COLLECTION
COLLECTION[image]="packer"
COLLECTION[role]="molecule"
COLLECTION[deployment]="terraform"

OPENRC="${PWD}/${META_ENV}-openrc.sh"

case "${1}" in
  --help)
    cat <<HELP
SYNOPSIS

  ${0} --help
  ${0} [image|role|deployment] NAME/VERSION [invoke_options] [ [task_name] [task_options] ... ]

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
  image|role|deployment)
    TYPE="${1}"
    IFS="/" read INVOKE_OBJECT_NAME INVOKE_OBJECT_VERSION <<<"${2}"
    export INVOKE_OBJECT_NAME INVOKE_OBJECT_VERSION
  ;;
  *)
    die 1 "Sorry, cannot automate \`${1}'"
  ;;
esac

shift 2

# Reads openrc.sh
# It is boring to input your Openstack password over and over...
if [ -f "${OPENRC}" ] ; then
  . "${OPENRC}"
else
  die 1 "Cannot find ${OPENRC}\n\tPlease, download an \`Openstack RC File' from the \`API Access' web interface, write one or manually export the shell environment variables"
fi

echo

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
    . ./py3/bin/activate
  else
    die 4 "Cannot find ${PWD}/py3/bin/activate\n\tvirtualenv is broken, you can remove the direcotry and run ${0} again"
  fi
fi

# Install all python modules
pip install --requirement requirements.txt

echo

# FIXME: find a way to move these variables into the terraform tasks
export TF_VAR_os_release="${INVOKE_META_RELEASE}"
export TF_VAR_programme="${INVOKE_META_PROGRAMME}"
export TF_VAR_env="${INVOKE_META_ENV}"
export TF_VAR_deployment_name="${INVOKE_OBJECT_NAME}"
export TF_VAR_deployment_version="${INVOKE_OBJECT_VERSION}"

# Runs the actual invoke command
invoke --collection "tasks/${COLLECTION[${TYPE}]}" "${@}"
