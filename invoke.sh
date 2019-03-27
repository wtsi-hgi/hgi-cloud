#!/bin/sh
# This wants to be an handy script to wrap the usage of invoke while I prepare
# a proper introduction of the tool to the team.

set -e

die() {
  echo -e "$2" >&2
  exit $1
}

if [ "${1}" = "--help" ] ; then
  cat <<EOF

  ${0} [collection_name] [invoke_options] [ [task_name] [task_options] ... ]

EOF
  exit 0
fi

# Reads openrc.sh
# It is boring to input your Openstack password over and over...
if [ -z "${OS_PASSWORD}" ] ; then
  if [ -f ./openrc.sh ] ; then
    echo
    echo "If you are going to run ${0} multiple times, you may want to source openrc.sh first."
    . ./openrc.sh
  else
    die 1 "Cannot find openrc.sh\n\tPlease, download an \`Openstack RC File' from the \`API Access' web interface or write one"
  fi
fi

echo

# Creates python3's virtualenv
if [ ! -d py3 ] ; then
  PYTHON=$(which python3)
  if [ -x "${PYTHON}" ] ; then
    VIRTUALENV=$(which virtualenv)
    if [ -x "${VIRTUALENV}" ] ; then
      ${VIRTUALENV} --python "${PYTHON}" py3
    else
      die 2 "Cannot find virtualenv in PATH, or \`${VIRTUALENV}' is not executable"
    fi
  else
    die 3 "Cannot find python3 in PATH, or \`${PYTHON}' is not executable"
  fi
fi

# Activates python3's virtualenv
if [ -f "./py3/bin/activate" ] ; then
  . ./py3/bin/activate
else
  die 4 "Cannot find ./py3/bin/activate\n\tvirtualenv is broken, you can remove the direcotry and run this script again"
fi

# Install all modules
pip install --requirement requirements.txt

echo

echo -e "${PWD}\n"

# Runs the actual invoke command
COLLECTION_NAME="${1}"
shift
invoke --collection "invoke/${COLLECTION_NAME}_collection" "${@}"
