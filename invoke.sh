#!/bin/bash
# This wants to be an handy script to wrap the usage of invoke.
# This tool is supposed to work only from the base project directory.

set -ex

die() {
  echo -e "$2" >&2
  exit $1
}

# User needs to source the right openrc.sh file.
if [ -z "${OS_PROJECT_NAME}" ] ; then
  die 1 "OS_PROJECT_NAME is empty: you need to source the right openrc.sh file"
fi

source "metadata/${OS_PROJECT_NAME}.rc"

COLLECTION="${1}"

case "${COLLECTION}" in
  --help)
    cat <<HELP
SYNOPSIS

  ${0} --help
  ${0} [image|role|deployment|user|hail] [invoke_options] [ [task_name] [task_options] ... ]

DESCRIPTION
  Runs automation tasks on a specific types of objects within the
  infrastructure. The task names depend on the type of the object.

  --help                          Prints this help message. Any other argument
                                  will be discarded.
EXAMPLES

  # Low level automations
  $ bash invoke.sh deployment create --owner hermes --name networking
  $ bash invoke.sh deployment destroy --owner vvi --name hail

  $ bash invoke.sh image build --role-name base --role-version 0.1.0
  $ bash invoke.sh image promote --role-name hail-base --role-version 0.3.0 --to hgi-dev
  $ bash invoke.sh image share --role-name spark-base --role-version 1.2.0 --with f1c35e83bca7412f847211257c73b5f4
  $ bash invoke.sh image accept --image-name random-image-from-somebody

  # High level automation. They need to be run by the actual user
  $ bash invoke.sh user create --public-key=~/.ssh/id_rsa_dev.pub
  $ bash invoke.sh user delete --yes-also-the-bucket

  # High level automations. It can be run for other users
  $ bash invoke.sh hail init --owner vvi
  $ bash invoke.sh hail create --full
  $ bash invoke.sh hail destroy --owner ch12 --yes-also-hail-volume

  $ bash invoke.sh spark_distribution create
HELP
    exit 0
  ;;
  user|deployment|hail|image|role|spark)
    shift
  ;;
  *)
    die 1 "Sorry, cannot automate \`${1}'"
  ;;
esac

# # Creates python3's virtualenv
# if [ ! -d "${PWD}/py3" ] ; then
#   PYTHON=$(which python3)
#   if [ -x "${PYTHON}" ] ; then
#     VIRTUALENV=$(which virtualenv)
#     if [ -x "${VIRTUALENV}" ] ; then
#       ${VIRTUALENV} --python "${PYTHON}" "${PWD}/py3"
#     else
#       die 2 "Cannot find virtualenv in PATH, or \`${VIRTUALENV}' is not executable"
#     fi
#   else
#     die 3 "Cannot find python3 in PATH, or \`${PYTHON}' is not executable"
#   fi
# fi
#
# # Activates python3's virtualenv
# if [ -z "${VIRTUAL_ENV}" ] ; then
#   if [ -f "${PWD}/py3/bin/activate" ] ; then
#     source ./py3/bin/activate
#   else
#     die 4 "Cannot find ${PWD}/py3/bin/activate\n\tvirtualenv is broken, you can remove the direcotry and run ${0} again"
#   fi
# fi
#
# # Install all python modules
# pip --no-cache-dir show invoke >/dev/null || pip --no-cache-dir install --requirement requirements.txt

# These variables will describe the exact cloud / project in which to operate, in invoke
export INVOKE_META_PROGRAMME="${META_PROGRAMME:?"META_PROGRAMME is null or unset"}"
export INVOKE_META_ENV="${META_ENV:?"META_ENV is null or unset"}"
export INVOKE_META_PROVIDER="${META_PROVIDER:?"META_PROVIDER is null or unset"}"
export INVOKE_META_DATACENTER="${META_DATACENTER:?"META_DATACENTER is null or unset"}"

# Runs the actual invoke command
invoke --collection "tasks/${COLLECTION}" "${@}"
