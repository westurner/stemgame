#!/bin/sh
set -x
entrypoint_sh_args="${@}"
source /.env >&2
(set +x; echo "+### exec'ing args ..." >&2)
exec "${@}"