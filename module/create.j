_create()
{
	local package=$1
	local path=${package}
	local args="$*"

	shift 1
	while test $# -gt 1
	do
		path=${path}/$1
		shift		
	done

	local module=$1
	local file=${_jsh_resolved_packages}/$path/${module}.j

	test -n "$(jsh module filename $package 2>/dev/null)" || die "'$package' is not a valid package"
	mkdir -p "${_jsh_resolved_packages}/$path"

	if ! test -f "$file"
	then
		cat > "$file" <<EOF
_$module()
{

#
#	implement your module here...
#	
	:

#
#       if you define nested modules within this module, then uncomment the following line
#	jsh invoke "\$@"

}
EOF
		jsh module edit $args
	else
		jsh die "module file '$file' already exists"
	fi
}