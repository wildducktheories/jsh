_installation()
{
        _link()
        {
                _bin()
                {
                        local bin=$(_installation get bin)
                        test -n "$bin" || jsh die "cannot link until the bin directory has been set. use 'jsh installation set bin'"
                        test -d "$bin" || jsh die "'$bin' must refer to a directory."
                        local rc=0
                        for p in $(_installation list resolved-packages)
                        do
                                if ! (! test -e $bin/$p || test -L $bin/$p && ln -sf ${_jsh_installation}/mnt/jsh/resolved-packages/jsh/bin/j.sh $bin/$p)
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
                        (cd ${_jsh_installation}/var/jsh/resolved-packages; find . -maxdepth 2 -type l) | sed "s|^./||"
                }

                jsh invoke "$@"
        }

	_init()
	{
	      local dir=$1
	      test -n "$dir" || jsh die "usage: init {bindir}"
	      test -d "$dir" || jsh die "'${dir}' is not a directory"
	      test -w "$dir" || jsh die "'${dir}' is not writeable"

	      _installation set bin "$dir" &&
	      _installation link bin "$dir"
	}

        _set()
        {
                _bin()
                {
                        local dir=$1

                        test -n "$dir" || jsh die "jsh installation set bin {dir}"

                        if ( ! test -L "${_jsh_installation}/bin" ) && test -e "${_jsh_installation}/bin" && test "$dir" != "${_jsh_installation}/bin"
                        then
                                jsh die "'${_jsh_installation}/bin' already exists and is not a link"
                        fi

                        if test "$dir" = "${_jsh_installation}/bin"
                        then
                                test -d "${_jsh_installation}/bin" && ! test -L "${_jsh_installation}/bin" && return 0
                                if test -L "${_jsh_installation}/bin"
                                then
                                        rm "${_jsh_installation}/bin" || jsh die "failed to remove existing link"
                                elif test -e "${_jsh_installation}/bin"
                                then
                                        jsh die "'${_jsh_installation}/bin' exists and is not a directory."
                                fi
                                mkdir "${_jsh_installation}/bin" || jsh die "failed to create ${_jsh_installation}/bin"
                        elif test -L "${_jsh_installation}/bin" || ! test -e "${_jsh_installation}/bin"
                        then
                                test -d "$dir" || jsh die "'$dir' is not a valid directory"
                                test -L "${_jsh_installation}/bin" && ( rm "${_jsh_installation}/bin" || jsh die "failed to remove existing link '${_jsh_installation}/bin'" )
                                ln -sf "$dir" "${_jsh_installation}/bin" || jsh die "failed to create link"
                        else
                                jsh die "'${_jsh_installation}/bin' already exists and is not a directory or a link."
                        fi
                }
                jsh invoke "$@"
        }

        _get()
        {
                _bin()
                {
                        if test -L "${_jsh_installation}/bin"
                        then
                                ls -ld ${_jsh_installation}/bin | sed "s/.*-> //"
                        elif test -d "${_jsh_installation}/bin"
                        then
                                echo "${_jsh_installation}/bin"
                        else
                                return 1
                        fi
                }
                jsh invoke "$@"
        }

        _top()
        {
                test -n "${_jsh_installation}" && echo "${_jsh_installation}"
        }

        jsh invoke "$@"
}
