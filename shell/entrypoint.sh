#!/bin/bash
# Author: Satish Gaikwad <satish@satishweb.com>
#
# The entrypoint runs the command that is given to the container.
set -e

exec "$@"
