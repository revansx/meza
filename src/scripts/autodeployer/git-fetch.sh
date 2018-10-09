#!/bin/sh
#
# Use Ansible's Git module plus jq to easily set repository versions

# Get directory to return to at end
CWD=$(pwd)

# change to directory holding appropriate ansible.cfg file for this operation
cd /opt/meza/config/core/adhoc

REPO="$1"
DEST="$2"
VERSION="$3"

ansible localhost -m git -a "repo=$REPO dest=$DEST version=$VERSION"

cd "$CWD"
