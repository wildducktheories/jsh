_runtime()
{
        _link()
        {
                _bin()
                {
                        local bin=$(_runtime get bin)
                        test -n "$bin" || jsh die "cannot link until the bin directory has been set. use 'jsh runtime set bin'"
                        test -d "$bin" || jsh die "'$bin' must refer to a directory."
                        local rc=0
                        for p in $(_runtime list resolved-packages)
                        do
                                if ! (! test -e $bin/$p || test -L $bin/$p && ln -sf ${_jsh_runtime}/mnt/jsh/resolved-packages/jsh/bin/j.sh $bin/$p)
                                then
                                        echo "failed to link '$bin/$p'" 1>&2
                                        rc=1
                                fi
                        done
                        test $rc -eq 0 || jsh die "failed due to previous errors"
                }
                jsh invoke "$@"
        }

        _list()
        {
                _resolved-packages()
                {
                        (cd ${_jsh_runtime}/var/jsh/resolved-packages; find . -maxdepth 2 -type l) | sed "s|^./||"
                }

                jsh invoke "$@"
        }

	_init()
	{
	      local dir=$1
	      test -n "$dir" || jsh die "usage: init {bindir}"
	      test -d "$dir" || jsh die "'${dir}' is not a directory"
	      test -w "$dir" || jsh die "'${dir}' is not writeable"

	      _runtime set bin "$dir" &&
	      _runtime link bin "$dir"
	}

        _set()
        {
                _bin()
                {
                        local dir=$1

                        test -n "$dir" || jsh die "jsh runtime set bin {dir}"

                        if ( ! test -L "${_jsh_runtime}/bin" ) && test -e "${_jsh_runtime}/bin" && test "$dir" != "${_jsh_runtime}/bin"
                        then
                                jsh die "'${_jsh_runtime}/bin' already exists and is not a link"
                        fi

                        if test "$dir" = "${_jsh_runtime}/bin"
                        then
                                test -d "${_jsh_runtime}/bin" && ! test -L "${_jsh_runtime}/bin" && return 0
                                if test -L "${_jsh_runtime}/bin"
                                then
                                        rm "${_jsh_runtime}/bin" || jsh die "failed to remove existing link"
                                elif test -e "${_jsh_runtime}/bin"
                                then
                                        jsh die "'${_jsh_runtime}/bin' exists and is not a directory."
                                fi
                                mkdir "${_jsh_runtime}/bin" || jsh die "failed to create ${_jsh_runtime}/bin"
                        elif test -L "${_jsh_runtime}/bin" || ! test -e "${_jsh_runtime}/bin"
                        then
                                test -d "$dir" || jsh die "'$dir' is not a valid directory"
                                test -L "${_jsh_runtime}/bin" && ( rm "${_jsh_runtime}/bin" || jsh die "failed to remove existing link '${_jsh_runtime}/bin'" )
                                ln -sf "$dir" "${_jsh_runtime}/bin" || jsh die "failed to create link"
                        else
                                jsh die "'${_jsh_runtime}/bin' already exists and is not a directory or a link."
                        fi
                }
                jsh invoke "$@"
        }

        _get()
        {
                _bin()
                {
                        if test -L "${_jsh_runtime}/bin"
                        then
                                ls -ld ${_jsh_runtime}/bin | sed "s/.*-> //"
                        elif test -d "${_jsh_runtime}/bin"
                        then
                                echo "${_jsh_runtime}/bin"
                        else
                                return 1
                        fi
                }
                jsh invoke "$@"
        }

        _top()
        {
                test -n "${_jsh_runtime}" && echo "${_jsh_runtime}"
        }

        jsh invoke "$@"
}
