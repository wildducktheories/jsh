#!/usr/bin/env bash
#
# j.sh
#
# This script is used to load the jsh package, then use that to invoke the top-level module of a package.
#
die()
{
    echo "$*" 1>&2
    exit 1;
}
export JSH_PACKAGE=$(basename "$BASH_SOURCE")
export JSH_RUNTIME=$(cd "$(dirname "$BASH_SOURCE")"; cd ..; pwd)
export JSH_RESOLVED_PACKAGES=${JSH_RUNTIME}/mnt/jsh/resolved-packages
export JSH_JSH_PACKAGE_DIR=${JSH_RESOLVED_PACKAGES}/jsh
export JSH_JSH_MODULE_FILE=${JSH_JSH_PACKAGE_DIR}/jsh.j
export JSH_MODULE_STACK=${JSH_PACKAGE}
test -f "${JSH_JSH_MODULE_FILE}" &&
. "$JSH_JSH_MODULE_FILE" || {
   cat >&2 <<EOF
JSH_PACKAGE=${JSH_PACKAGE}
JSH_RUNTIME=${JSH_RUNTIME}
JSH_RESOLVED_PACKAGES=${JSH_RESOLVED_PACKAGES}
JSH_JSH_PACKAGE_DIR=${JSH_JSH_PACKAGE_DIR}
JSH_JSH_MODULE_FILE=${JSH_JSH_MODULE_FILE}
EOF
   die "Unable to locate jsh runtime. Please check that '${BASH_SOURCE}' can see '../mnt/jsh/resolved-packages/jsh/bin/j.sh'"
}
_jsh invoke "${JSH_PACKAGE}" "$@" 
