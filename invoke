#!/bin/sh
# This wants to be an handy script to wrap the usage of invoke while I prepare
# a proper introduction of the tool to the team.

set -e

die() {
  echo -e "$2" >&2
  exit $1
}

if [ -f ./openrc.sh ] ; then
  . ./openrc.sh
else
  die 1 "Cannot find openrc.sh\n\tPlease, download an \`Openstack RC File' from the \`API Access' web interface or write one"
fi

echo

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

if [ -f "./py3/bin/activate" ] ; then
  . ./py3/bin/activate
else
  die 4 "Cannot find ./py3/bin/activate\n\tvirtualenv is broken, you can remove the direcotry and run this script again"
fi

pip install --requirement requirements.txt

echo

echo -e "${PWD}\n"

invoke --echo "${@}"
