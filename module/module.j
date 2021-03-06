_module()
{
	_filename()
	{
		local path=${_jsh_resolved_packages}
		local file

		# check that first argument is an active package

		test -d "$path" || jsh die "illegal state: '${_jsh_resolved_packages}' does not exist"
		local package=$1
		local module=${package}
		test -n "$package" || jsh die "usage: jsh module filename {package} [ {module} ... ]"
		test -d "$path/$package" || jsh die "'$package' does not correspond to an active package"

		path=${path}/${package}
		file=${path}/${package}.j

		test -f "$file" || jsh die "'$package' is not a well-formed jsh package because it is missing a top-level module"
		shift 1

		# now, start matching modules

		for module in "$@";
		do
			if test -f "$path/$module/$module.j"
			then
				path=$path/$module
				file=$path/${module}.j
			elif test -f "$path/${module}.j"
			then
				file=$path/${module}.j
				echo $file
				return 0;
			elif grep "_$module *()" "$file" >/dev/null 
			then
				echo $file
				return 0
			fi
		done
		test -f "$file" && grep "_$module *()" "$file" >/dev/null && echo "$file"
	}

	_usage()
	{
cat <<EOF
jsh module {module} {args}...

where {module} {args}... is one of:
      create {package} {module}...
      edit {package} {module}...
      filename {package} {module}...
      
EOF
	}

	jsh invoke "$@"
}