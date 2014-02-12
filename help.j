_help()
{
	${PAGER:-less} <<EOF
NAME
	jsh - jon's (s)hell - a package management system for bash

SYNOPSIS
	jsh module edit {package} {module...}
	    Edit the module file associated with the specified jsh module.
	
	jsh module filename {package} {module...}
	    Answer the name of the module file associated with the specified jsh module.

SEE ALSO
	https://github.com/jonseymour/jsh

COPYRIGHT
	(C) Jon Seymour 2014
EOF
}

