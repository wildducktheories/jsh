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
                                if ! (! test -e $bin/$p || test -L $bin/$p && ln -sf ${JSH_RUNTIME}/mnt/jsh/resolved-packages/jsh/bin/j.sh $bin/$p)
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
                        (cd ${JSH_RUNTIME}/var/jsh/resolved-packages; find . -maxdepth 2 -type l) | sed "s|^./||"
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

                        if ( ! test -L "${JSH_RUNTIME}/bin" ) && test -e "${JSH_RUNTIME}/bin" && test "$dir" != "${JSH_RUNTIME}/bin"
                        then
                                jsh die "'${JSH_RUNTIME}/bin' already exists and is not a link"
                        fi

                        if test "$dir" = "${JSH_RUNTIME}/bin"
                        then
                                test -d "${JSH_RUNTIME}/bin" && ! test -L "${JSH_RUNTIME}/bin" && return 0
                                if test -L "${JSH_RUNTIME}/bin"
                                then
                                        rm "${JSH_RUNTIME}/bin" || jsh die "failed to remove existing link"
                                elif test -e "${JSH_RUNTIME}/bin"
                                then
                                        jsh die "'${JSH_RUNTIME}/bin' exists and is not a directory."
                                fi
                                mkdir "${JSH_RUNTIME}/bin" || jsh die "failed to create ${JSH_RUNTIME}/bin"
                        elif test -L "${JSH_RUNTIME}/bin" || ! test -e "${JSH_RUNTIME}/bin"
                        then
                                test -d "$dir" || jsh die "'$dir' is not a valid directory"
                                test -L "${JSH_RUNTIME}/bin" && ( rm "${JSH_RUNTIME}/bin" || jsh die "failed to remove existing link '${JSH_RUNTIME}/bin'" )
                                ln -sf "$dir" "${JSH_RUNTIME}/bin" || jsh die "failed to create link"
                        else
                                jsh die "'${JSH_RUNTIME}/bin' already exists and is not a directory or a link."
                        fi
                }
                jsh invoke "$@"
        }

        _get()
        {
                _bin()
                {
                        if test -L "${JSH_RUNTIME}/bin"
                        then
                                ls -ld ${JSH_RUNTIME}/bin | sed "s/.*-> //"
                        elif test -d "${JSH_RUNTIME}/bin"
                        then
                                echo "${JSH_RUNTIME}/bin"
                        else
                                return 1
                        fi
                }
                jsh invoke "$@"
        }

        _top()
        {
                test -n "${JSH_RUNTIME}" && echo "${JSH_RUNTIME}"
        }

        jsh invoke "$@"
}
