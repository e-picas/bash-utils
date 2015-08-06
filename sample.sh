#!/usr/bin/env bash
#
# shell-model.sh
# by Pierre Cassat (me at e-piwi dot fr) & contributors
# <http://gitlab.com/piwi/shell-model.git>
# file licensed under CC BY 4.0 <http://creativecommons.org/licenses/by/4.0/legalcode>
# (you MUST keep this license block when using this model)
#
# Base model for a bash script
# Default options are: -f | -q | -v | -x | --dry-run
#

## Bash options ##
# exit if a command has a non-zero status
set -e
# trap on ERR are inherited by shell functions
set -E
# do not mask pipeline's errors
set -o pipefail
# throw error on unset variable usage
set -u
# trap on DEBUG and RETURN are inherited by shell functions
set -T
# for dev usage: debug commands before to execute them
#set -x
# for dev usage: print shell input lines as they are read
#set -v

## command info ##
declare -xr CMD_NAME='script-model-sample'
declare -xr CMD_VERSION='0.0.0'
declare -xr CMD_COPYRIGHT='(CC-BY) 2015 Pierre Cassat & contributors'
declare -xr CMD_LICENSE='Creative Commons 4.0 BY license <http://creativecommons.org/licenses/by/4.0/legalcode>'
declare -xr CMD_SOURCES='Sources & updates: <http://gitlab.com/piwi/script-model.git>'
declare -xr CMD_DESCRIPTION="A sample script from *bash* scripts' model."
declare -xr CMD_SYNOPSIS="$0 [-f|-q|-v|-x] [--debug|--dry-run|--force|--quiet|--verbose]
        [-a:|-b::] [--test1:|--test2::] <arguments> --";
declare -xr CMD_HELP="
Example of usage:
    ./sample.sh usage
    ./sample.sh help
    ./sample.sh version
    ./sample.sh version --quiet
    ./sample.sh about
    ./sample.sh -v -a arg1 -b=arg2 args --force argument2
    ./sample.sh --test1=...* globb # argument must be a globbing pattern
    ./sample.sh --test1 ...* globb # this one will fail as globbing pattern is substituted from terminal
    ./sample.sh error
    ./sample.sh try
    ./sample.sh -v warning
    ./sample.sh -v warning 2>/dev/null

Test options are:
    -a|--test1=ARG      option with required argument
    -b|--test2[=ARG]    option with optional argument

Available options:
    -v|--verbose    increase script's verbosity
    -q|--quiet      decrease script's verbosity
    -f|--force      do not prompt for choices if a default choice exists
    -x|--debug      see some debugging information
    --dry-run       process a dry-run

Use arguments 'usage', 'about' or 'version' for application information.";
declare -xr CMD_OPTS_SHORT='fqvxa:b::'
declare -xr CMD_OPTS_LONG='debug,dry-run,force,quiet,verbose,test1:,test2::'

## common library ##

# about string on STDOUT & exit
# usage: `about`
about()
{
    cat <<MSG
$CMD_NAME $CMD_VERSION
$CMD_COPYRIGHT
$CMD_LICENSE
$CMD_SOURCES
MSG
    exit 0
}

# get absolute path of a dir
# inspired by <https://github.com/sstephenson/bats>
# usage: `abs_dirname <path>`
abs_dirname()
{
    [ $# -lt 1 ] && die 'usage: `abs_dirname <path>`';
    local cwd="$(pwd)"
    local path="$1"
    while [ -n "$path" ]; do
        cd "${path%/*}" 2>/dev/null
        local name="${path##*/}"
        path="$(resolve_link "$name" || true)"
    done
    pwd
    cd "$cwd"
}

# cleanup after the script exits
# this one should never be called directly as it is trapped on EXIT
# usage: `cleanup`
cleanup()
{
    : # draw your own cleanup stuff here
}

# write a comment string on STDOUT
# usage: `comment <string>`
comment()
{
    [ -n "$1" ] && echo "# $@" >&1
}

# common options treatment
# usage: `common_options`
common_options()
{
    for arg in $*; do
        case "$arg" in
            'about')    about;;
            'debug')    debug && exit 0;;
            'help')     help;;
            'usage')    usage && exit 0;;
            'version')  version && exit 0;;
        esac
    done
}

# debug environment
# usage: `debug`
debug()
{
    echo '----'
    for i in "${TO_DEBUG[@]}"; do
        echo "$i:  ${!i}"
    done
    echo '----'
}

# write an internal error on STDERR & exit with status 1
# usage: `die [string='unknown error']`
die()
{
    local err=$?
    [ "$err" -eq 0 ] && err=1;
    if $QUIET; then
        echo "${1:-unknown error}" >&2
    else
        {   echo '----'
            echo "**** ${1:-unknown error} ****"
            echo "# exiting with status ${err}"
            echo "# in ${BASH_SOURCE[1]##*/} at line ${BASH_LINENO[0]}"
            echo "# running ${CMD_PID}:${CMD_CALL}"
            echo "# stack trace:"
            stacktrace
            echo '----'
        } >&2
    fi
    exit "${err:-1}"
}

# write a full error on STDERR & show usage string & exit
# usage: `error [string='unknown error'] [status=1]`
error()
{
    {   echo "error: ${1:-unknown error}"
        $VERBOSE && echo "# in ${BASH_SOURCE[1]##*/} at line ${BASH_LINENO[0]}";
        echo '---'
        usage
    } >&2
    exit "${2:-1}"
}

# test if a function exists - returns a boolean
# usage: `func_exists <func_name>`
func_exists()
{
    [ $# -eq 0 ] && return 1;
    [ "$(type -t "$1")" == 'function' ]
}

# write help string to STDERR & exit
# usage: `help`
help()
{
    {   version
        echo
        echo "$CMD_DESCRIPTION"
        echo
        usage
        echo "$CMD_HELP"
    } >&2
    exit 0
}

# resolve symbolic link
# inspired by <https://github.com/sstephenson/bats>
# usage: `resolve_link <path>`
resolve_link()
{
    [ $# -lt 1 ] && die 'usage: `resolve_link <path>`';
    $(type -p greadlink readlink | head -1) "$1"
}

# get script stack trace
# usage: `stacktrace`
stacktrace()
{
    set +o xtrace
    local args
    if [ ${#FUNCNAME[@]} -gt 2 ]; then
        for ((i=1;i<${#FUNCNAME[@]};i++)); do
            echo "  $i: ${BASH_SOURCE[$i+1]:-}:${BASH_LINENO[$i]} ${FUNCNAME[$i]}(...)"
        done
    fi
}

# try a command and catch errors throwing them to the 'die' function
# from: <http://askubuntu.com/a/53759>
# usage: `try "command"`
try()
{
    local error retval e
    [[ ! "$-" =~ e ]] || e=1
    # Run the command and store error messages (output to the standard error
    # stream in $error, but send regular output to file descriptor 3 which
    # redirects to standard output
    set +e
    error="$("$@" 2>&1 >&3)"
    retval=$?
    [ -z "$e" ] || set -e
    # if the command failed (returned a non-zero exit code)
    if [ $retval -gt 0 ]; then
        retstr="command '$*' failed: ${error:-} ($retval)"
        die "$retstr" "$retval"
    fi
}

# echo usage string
# usage: `usage`
usage()
{
    echo "usage: $CMD_SYNOPSIS"
}

# version string
# usage: `version`
version()
{
    if $QUIET; then
        echo "$CMD_VERSION"
    else
        echo "$CMD_NAME $CMD_VERSION"
    fi
}

# write an error string on STDERR without exiting
# usage: `warning <string>`
warning()
{
    [ -n "$1" ] && echo "> $@" >&2
}

## common setup ##

# trap errors to 'die'
trap 'die ${BASH_SOURCE} ${FUNCNAME:-} ${BASH_LINENO:-}' 1 2 3 15 ERR
# trap exit to 'cleanup'
trap 'cleanup' EXIT
# test of old Bash versions
[[ "$BASH_VERSION" =~ "4."* ]] || warning "you are running an old version of Bash ($BASH_VERSION) - some errors are expected.";

# command variables
declare -xr CMD_PROG="$(basename "$0")"
declare -xr CMD_ROOT="$(abs_dirname "$0")"
declare -xr CMD_HOST="$(hostname -f)"
declare -xr CMD_USER="$(id -un)"
declare -xr CMD_CWD="$(pwd)"
declare -xr CMD_PID="$$"
declare -xr CMD_CALL_ORIGINAL="$0 $@"
declare -x CMD_CALL

# script flags used as booleans
declare -x VERBOSE=false        # write in verbose mode:    $VERBOSE && echo '...';
declare -x QUIET=false          # write in not quiet mode:  $QUIET || echo '...';
declare -x DEBUG=false          # write in debug mode:      $DEBUG && echo '...';
declare -x FORCE=false          # write in force mode:      $FORCE && echo '...';
declare -x DRY_RUN=false        # exec in not dry-run mode: $DRY_RUN || ...;
declare -xa TO_DEBUG=(
    CMD_PROG CMD_ROOT CMD_HOST CMD_USER CMD_CWD CMD_PID
    CMD_CALL VERBOSE QUIET DEBUG FORCE DRY_RUN TEST1 TEST2
)

# user vars
declare -x TEST1
declare -x TEST2

## options & arguments ##
set +E
getoptvers="$(getopt --test > /dev/null; echo $?)"
if [ $getoptvers -eq 4 ]; then
    # GNU enhanced getopt is available
    CMD_REQ="$(getopt --shell 'bash' --options "${CMD_OPTS_SHORT}-:" --longoptions "$CMD_OPTS_LONG" --name "$CMD_PROG" -- "$@")"
else
    # original getopt is available
    CMD_REQ="$(getopt "$CMD_OPTS_SHORT" "$@")"
fi
set -E
eval set -- "$CMD_REQ"
CMD_CALL="$0 $CMD_REQ"
while [ $# -gt 0 ]; do
    case "$1" in
        # default options
        -f | --force )  FORCE=true;;
        -q | --quiet )  QUIET=true; VERBOSE=false;;
        -v | --verbose ) VERBOSE=true; QUIET=false;;
        -x | --debug )  DEBUG=true;;
        --dry-run )     DRY_RUN=true;;

        # user options
        # to add your own options, use:
        #
        # declare -xr CMD_OPTS_SHORT='fqvxa:b::'
        # declare -xr CMD_OPTS_LONG='force,quiet,verbose,debug,dry-run,test1:,test2::'
        #
        # -a | --test1 ) OPTARG="$(echo "$2" | cut -d'=' -f2)"; TEST1="${OPTARG}"; shift;;
        # -b | --test2 ) OPTARG="$(echo "$2" | cut -d'=' -f2)"; TEST2="${OPTARG:-default}"; shift;;
        #
        -a | --test1 ) OPTARG="$(echo "$2" | cut -d'=' -f2)"; TEST1="${OPTARG}"; shift;;
        -b | --test2 ) OPTARG="$(echo "$2" | cut -d'=' -f2)"; TEST2="${OPTARG:-default}"; shift;;

        # end of options & errors
        -- )    shift; break;;
        * )     if [ "${OPTIONS_ALLOWED:0:1}" != ":" ]; then error "unknown option '$1'"; fi;;
    esac
    shift
done

# argument required
[ $# -eq 0 ] && usage && exit 1;

# common arguments
[ $# -gt 0 ] && common_options "$*";

# debug env
$DEBUG && debug;

# logic ...

comment "original request was rebuilt as: $CMD_CALL"
$VERBOSE && comment "verbose mode is enabled";
$QUIET && comment "quiet mode is enabled";
$DEBUG && comment "debug mode is enabled";
$FORCE && comment "force mode is enabled";
$DRY_RUN && comment "dry-run mode is enabled";

# test cases
case "$1" in

    # debug arguments
    args)
        debug
        ;;

    # test an error
    error )
        f() { abqsdffhjfqskdlfjqfhs; }
        f 1 2
        ;;

    # test a try/catch statement
    try)
        try "grep some-string /non/existent/file | sort"
        ;;

    # test a globbing pattern as argument (for option a)
    globb)
        for f in $TEST1; do
            echo "f: $f"
        done
        ;;

    # test warning
    warning)
        warning 'my warning message'
        echo 'classic message'
        ;;

esac

exit 0
# Endfile
# vim: autoindent tabstop=4 shiftwidth=4 expandtab softtabstop=4 filetype=sh                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         