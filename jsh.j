_jsh()
{	
	_die()
	{
		echo "$*" 1>&2
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
		_debug "_invoke|$*|${_jsh_module_stack}"

		# handle -- as first argument
		local first_arg=$1
		shift 1
		if test "$first_arg" = "--"
		then
			set -- $_jsh_double_dash_handler "$@"
		else
			set -- $first_arg "$@"
		fi

		module=$1
		shift 1
		test -n "${module}" || _die "usage: jsh invoke {module} {module...} {args...}"

		local save=${_jsh_module_stack}

		# check for a sub-package
		local module_file=${_jsh_resolved_packages}/${_jsh_module_stack}/${module}/${module}.j
		if ! test -f "$module_file"
		then
			# assume a sub-module instead
			module_file=${_jsh_resolved_packages}/${_jsh_module_stack}/${module}.j
		fi

		# push the sub-package onto the module stack
		_jsh_module_stack=${_jsh_module_stack}${_jsh_module_stack:+/}${module}

		# check that the file exists
		if test -f "$module_file" 
		then
			# load the file
			. "$module_file" || _die "A problem was encounted while loading '$module_file'"
		fi

		# assert that the module function exists
		test "$(type -t "_${module}")" = "function" || _die "'$_jsh_module_stack' does not address a valid jsh module"

		# call the module
		_${module} "$@"

		_jsh_module_stack=${save}
	}		

	_with()
	{
		(
			_jsh_save_module_stack=$_jsh_module_stack
			_jsh_module_stack=
			_jsh_double_dash_handler="jsh end-with"
			jsh invoke "$@"
		) || exit $?
	}

	_end-with()
	{
		_jsh_module_stack=${_jsh_save_module_stack}
		_jsh_double_dash_handler=
		_invoke "$@"
	}

	jsh()
	{
		case "$1" in
		     invoke|die|debug|with)
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
	elif test "$1" = "with"
	then
		shift 1
		_with "$@"
	else
		_invoke "$@"
	fi
}