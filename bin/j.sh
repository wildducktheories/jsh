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
    _jsh_runtime=$(ls -ld "${BASH_SOURCE}"); 
    _jsh_runtime=${_jsh_runtime#*-> }; 
    _jsh_runtime=${_jsh_runtime%/mnt/jsh/resolved-packages/jsh/bin/j.sh}; 
    export _jsh_package=$(basename "$BASH_SOURCE")
else
    _jsh_runtime=$(cd "$(dirname "${BASH_SOURCE}")"; pwd); 
    _jsh_runtime=${_jsh_runtime%/mnt/jsh/resolved-packages/jsh/bin}; 
    export _jsh_package=$1
    test -n "$_jsh_package" || die "usage: j.sh {package} {module...} {arg...}"
    shift 1
fi
export _jsh_runtime
export _jsh_resolved_packages=${_jsh_runtime}/mnt/jsh/resolved-packages
export _jsh_jsh_package_dir=${_jsh_resolved_packages}/jsh
export _jsh_jsh_module_file=${_jsh_jsh_package_dir}/jsh.j
export _jsh_module_stack=
test -f "${_jsh_jsh_module_file}" &&
. "$_jsh_jsh_module_file" || {
   cat >&2 <<EOF
BASH_SOURCE=${BASH_SOURCE}
_jsh_package=${_jsh_package}
_jsh_runtime=${_jsh_runtime}
_jsh_resolved_packages=${_jsh_resolved_packages}
_jsh_jsh_package_dir=${_jsh_jsh_package_dir}
_jsh_jsh_module_file=${_jsh_jsh_module_file}
EOF
   die "Unable to locate jsh runtime. Please check that '${BASH_SOURCE}' can see '../mnt/jsh/resolved-packages/jsh/bin/j.sh'"
}
_jsh invoke "${_jsh_package}" "$@" 
