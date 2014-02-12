_edit()
{
	local file=$(jsh module filename "$@")
	if test -n "$file" 
	then
		${EDITOR:-emacs -nw} "$file"
	else
		jsh module create "$@"
	fi
}