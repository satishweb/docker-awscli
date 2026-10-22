#!/bin/bash
# Author: Satish Gaikwad <satish@satishweb.com>
#
# The entrypoint starts the shell of the user when the first argument is the
# shell, and it runs the command of aws with the arguments otherwise.
set -e

if [[ "${1:-}" == "/bin/bash" ]]; then
    exec /bin/bash
fi

exec /usr/local/bin/aws "$@"
