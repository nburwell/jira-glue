#!/bin/bash -i -l
# Use a login shell because it will load rbenv if you want to use that.
# Scripts can be easier to debug when they operate with the same semantics as your login shell

set -e

# Run jira-glue and redirect output to standard error.
# This is a shim to make running it from applications like Alfred easier.

echo "Debug - ${BASH_SOURCE[0]} starting" >&2

# Get the script directory so that we can operate from that directory
script_source=`readlink "$0" ||  echo "${BASH_SOURCE[0]}"`
current_directory=`dirname $script_source`

cd "${current_directory}/../" >&2

echo "Debug - shell script starting $(ruby --version) to get data from browser.rb" >&2

# Disable warnings because
ruby -W0 browser.rb >&2
