_jsh()
{	
	_die()
	{
		echo "$*" 2>&1
		exit 1
	}

	_debug()
	{
		if test -n "$JSH_DEBUG"
		then
			echo "$*" >&2
		fi
	}

	_invoke()
	{
		_debug "_invoke|$*|${JSH_MODULE_STACK}"

		module=$1
		shift 1
		test -n "${module}" || _die "usage: jsh invoke {module} {module...} {args...}"

		local save=${JSH_MODULE_STACK}

		# check for a sub-package
		local module_file=${JSH_RESOLVED_PACKAGES}/${JSH_MODULE_STACK}/${module}/${module}.j
		if ! test -f "$module_file"
		then
			# assume a sub-module instead
			module_file=${JSH_RESOLVED_PACKAGES}/${JSH_MODULE_STACK}/${module}.j
		fi

		# push the sub-package onto the module stack
		JSH_MODULE_STACK=${JSH_MODULE_STACK}${JSH_MODULE_STACK:+/}${module}

		# check that the file exists
		if test -f "$module_file" 
		then
			# load the file
			. "$module_file" || _die "A problem was encounted while loading '$module_file'"
		fi

		# assert that the module function exists
		test "$(type -t "_${module}")" = "function" || _die "'$JSH_MODULE_STACK' does not correspond to an active jsh module"

		# call the module
		_${module} "$@"

		JSH_MODULE_STACK=${save}
	}		

	jsh()
	{
		case "$1" in
		     invoke|die|debug)
			_jsh "$@"
		     ;;
		     *)
			$(which jsh) "$@"
		     ;;
		esac
	}

	if test "$1" = "invoke"
	then
		# we are here, just do it
		shift 1
		local arg=${1:-usage}
		shift 1
		_invoke "$arg" "$@"
	else
		_invoke "$@"
	fi
}