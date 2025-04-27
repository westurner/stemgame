#!/bin/sh

## container entrypoint script
# This script is executed when the container starts
# if ENTRYPOINT specifies a path to this script in the Dockerfile.
# It sets up the environment and executes the provided command and arguments.

set -x
entrypoint_sh_args="${@}"
source /.env >&2
(set +x; echo "+### exec'ing args ..." >&2)
exec "${@}"