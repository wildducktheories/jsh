_tests()
{
	_all()
	{
		jsh with shunit2 run-suite $(jsh installation resolved-packages)/$(jsh module-dir-stack)
	}
	local cmd=${1:-all}
	shift 1
	jsh invoke $cmd "$@"
}
