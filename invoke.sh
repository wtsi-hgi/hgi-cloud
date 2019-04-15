#!/bin/bash
# This wants to be an handy script to wrap the usage of invoke.
# This tool is supposed to work only from the base project directory.

set -e

# These variables will describe the exact cloud / project in which to operate
export INVOKE_META_ENV="${META_ENV:-dev}"
export INVOKE_META_RELEASE="${META_RELEASE:-eta}"
export INVOKE_META_PROGRAMME="${META_PROGRAMME:-hgi}"

die() {
  echo -e "$2" >&2
  exit $1
}

case "${1}" in
  --help)
    cat <<HELP
SYNOPSIS

  ${0} --help
  ${0} --list
  ${0} [image|deployment|env|environment] NAME:VERSION [invoke_options] [ [task_name] [task_options] ... ]

DESCRIPTION
  Runs automation tasks on a specific types of objects within the
  infrastructure. The task names depend on the type of the object.

  --help                          Prints this help message. Any other argument
                                  will be discarded.
  --list                          Prints the list of available tasks
                                  collection. Any other argument will be
                                  discarded.
  [image|deployment|environment]  Tells invoke the kind of object to automate.
  NAME                            Tells invoke which object to automate.
  VERSION                         Tells invoke which version of the object to
                                  automate.

EXAMPLES

  $ bash invoke.sh env spark-1.0.0 up
  $ bash invoke.sh environment build-1.2.3 plan --to destroy
  $ bash invoke.sh image base-0.1.0 build
  $ bash invoke.sh deployment spark-1.1.0-ld14-test1 down
HELP
    exit 0
  ;;
  --list)
    ls -1 tasks/*.py | sed "s#tasks/\\(.*\\).py#\\1#"
    exit 0
  ;;
  image|role|deployment|env|environment)
    if [ "${1}" == "env" ] ; then
      INVOKE_OBJECT_TYPE="environment"
    else
      INVOKE_OBJECT_TYPE="${1}"
    fi
    IFS=":" read INVOKE_OBJECT_NAME INVOKE_OBJECT_VERSION <<<"${2}"
    export INVOKE_OBJECT_TYPE INVOKE_OBJECT_NAME INVOKE_OBJECT_VERSION
  ;;
  *)
    die 1 "Sorry, cannot automate \`${1}'"
  ;;
esac

shift 2

case "${INVOKE_OBJECT_TYPE}" in
  image)
    COLLECTION=packer
  ;;
  role)
    COLLECTION=molecule
  ;;
  *)
    COLLECTION=terraform
  ;;
esac

# Reads openrc.sh
# It is boring to input your Openstack password over and over...
if [ -z "${OS_PASSWORD}" ] ; then
  if [ -f "${PWD}/openrc.sh" ] ; then
    echo
    echo "If you are going to run ${0} multiple times, you may want to source openrc.sh first."
    . "${PWD}/openrc.sh"
  else
    die 1 "Cannot find openrc.sh\n\tPlease, download an \`Openstack RC File' from the \`API Access' web interface, write one or manually export the shell environment variables"
  fi
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

# Install all modules
pip install --requirement requirements.txt

echo

# Runs the actual invoke command
invoke --collection "tasks/${COLLECTION}" "${@}"
