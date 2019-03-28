#!/bin/sh
# This wants to be an handy script to wrap the usage of invoke.
# This tool is supposed to work only from the base project directory.

set -e

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
  ${0} COLLECTION_NAME [invoke_options] [ [task_name] [task_options] ... ]

DESCRIPTION

  --help          Prints this help message. Any other argument will be
                  discarded.
  --list          Prints the list of available tasks collection. Any other
                  argument will be discarded.
 COLLECTION_NAME  Runs invoke with the given collection of tasks. Any other
                  argument will be passed to invoke. 

HELP
    exit 0
  ;;
  --list)
    ls -1 ${PWD}/invoke/*_collection.py | sed "s#${PWD}/invoke/\\(.*\\)_collection.py#\\1#"
    exit 0
  ;;
  *)
    COLLECTION_NAME="${1}"
    shift
    break
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
if [ -f "${PWD}/py3/bin/activate" ] ; then
  . ./py3/bin/activate
else
  die 4 "Cannot find ${PWD}/py3/bin/activate\n\tvirtualenv is broken, you can remove the direcotry and run ${0} again"
fi

# Install all modules
pip install --requirement requirements.txt

echo

# Runs the actual invoke command
invoke --collection "invoke/${COLLECTION_NAME}_collection" "${@}"
