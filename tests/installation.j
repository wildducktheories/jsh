testInstallationTop()
{
	assertNotNull "$(jsh installation top)"
}

_installation()
{

	jsh with shunit2 run-suite "${BASH_SOURCE}"
}
