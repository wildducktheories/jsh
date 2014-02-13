_runtime()
{
	_top()
	{
		echo "${JSH_RUNTIME}"
		test -n "${JSH_RUNTIME}"
	}
	jsh invoke "$@"
}
