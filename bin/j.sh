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
if test -L "${BASH_SOURCE}"
then
    JSH_RUNTIME=$(ls -ld "${BASH_SOURCE}"); 
    JSH_RUNTIME=${JSH_RUNTIME#*-> }; 
    JSH_RUNTIME=${JSH_RUNTIME%/mnt/jsh/resolved-packages/jsh/bin/j.sh}; 
    export JSH_PACKAGE=$(basename "$BASH_SOURCE")
else
    JSH_RUNTIME=$(cd "$(dirname "${BASH_SOURCE}")"; pwd); 
    JSH_RUNTIME=${JSH_RUNTIME%/mnt/jsh/resolved-packages/jsh/bin}; 
    export JSH_PACKAGE=$1
    test -n "$JSH_PACKAGE" || die "usage: j.sh {package} {module...} {arg...}"
    shift 1
fi
export JSH_RUNTIME
export JSH_RESOLVED_PACKAGES=${JSH_RUNTIME}/mnt/jsh/resolved-packages
export JSH_JSH_PACKAGE_DIR=${JSH_RESOLVED_PACKAGES}/jsh
export JSH_JSH_MODULE_FILE=${JSH_JSH_PACKAGE_DIR}/jsh.j
export JSH_MODULE_STACK=${JSH_PACKAGE}
test -f "${JSH_JSH_MODULE_FILE}" &&
. "$JSH_JSH_MODULE_FILE" || {
   cat >&2 <<EOF
BASH_SOURCE=${BASH_SOURCE}
JSH_PACKAGE=${JSH_PACKAGE}
JSH_RUNTIME=${JSH_RUNTIME}
JSH_RESOLVED_PACKAGES=${JSH_RESOLVED_PACKAGES}
JSH_JSH_PACKAGE_DIR=${JSH_JSH_PACKAGE_DIR}
JSH_JSH_MODULE_FILE=${JSH_JSH_MODULE_FILE}
EOF
   die "Unable to locate jsh runtime. Please check that '${BASH_SOURCE}' can see '../mnt/jsh/resolved-packages/jsh/bin/j.sh'"
}
_jsh invoke "${JSH_PACKAGE}" "$@" 
