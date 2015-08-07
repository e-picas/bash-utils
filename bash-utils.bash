#!/usr/bin/env bash
#
# bash-util.bash
# by Pierre Cassat (me at e-piwi dot fr) & contributors
# <http://gitlab.com/piwi/bash-utils.git>
# file licensed under CC BY 4.0 <http://creativecommons.org/licenses/by/4.0/legalcode>
# (you MUST keep this license block when using this model)
#
# Utilities library for bash scripting
#

##################
## Bash options ##
##################
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

##################
## command info ##
##################
# Available options:
#     -v|--verbose    increase script's verbosity
#     -q|--quiet      decrease script's verbosity
#     -f|--force      do not prompt for choices if a default choice exists
#     -x|--debug      see some debugging information
#     --dry-run       process a dry-run
#
# Use arguments 'usage', 'about' or 'version' for application information.
declare -x CMD_SYNOPSIS="$0 [-f|-q|-v|-x] [--debug|--dry-run|--force|--quiet|--verbose] <arguments> --"
declare -x CMD_NAME='overwrite the CMD_NAME variable to customize this information'
declare -x CMD_VERSION='overwrite the CMD_VERSION variable to customize this information'
declare -x CMD_COPYRIGHT='overwrite the CMD_COPYRIGHT variable to customize this information'
declare -x CMD_LICENSE='overwrite the CMD_LICENSE variable to customize this information'
declare -x CMD_SOURCES='overwrite the CMD_SOURCES variable to customize this information'
declare -x CMD_DESCRIPTION='overwrite the CMD_DESCRIPTION variable to customize this information'
declare -x CMD_HELP='overwrite the CMD_HELP variable to customize this information'
declare -x CMD_OPTS_SHORT='fqvx'
declare -x CMD_OPTS_LONG='debug,dry-run,force,quiet,verbose'
declare -x CMD_LOGFILE='/var/log/bash-utils.log'
declare -xa TO_DEBUG=(
    CMD_PROG CMD_ROOT CMD_HOST CMD_USER CMD_CWD CMD_PID CMD_OS
    CMD_CALL VERBOSE QUIET DEBUG FORCE DRY_RUN
)

# script flags used as booleans
declare -x VERBOSE=false        # write in verbose mode:    $VERBOSE && echo '...';
declare -x QUIET=false          # write in not quiet mode:  $QUIET || echo '...';
declare -x DEBUG=false          # write in debug mode:      $DEBUG && echo '...';
declare -x FORCE=false          # write in force mode:      $FORCE && echo '...';
declare -x DRY_RUN=false        # exec in not dry-run mode: $DRY_RUN || ...;

####################
## common library ##
####################

# about string on STDOUT & exit
# usage: `about_info`
about_info()
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
# usage: `real_path_dirname <path>`
real_path_dirname()
{
    [ $# -lt 1 ] && die 'usage: `real_path_dirname <path>`';
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
    [ -n "$1" ] && echo "# $*" >&1
}

# treat common arguments
# usage: `common_arguments "$@"`
common_arguments()
{
    for arg in "$@"; do
        case "$arg" in
            'about')    about_info   && exit 0;;
            'debug')    debug        && exit 0;;
            'help')     help_info    && exit 0;;
            'usage')    usage_info   && exit 0;;
            'version')  version_info && exit 0;;
        esac
    done
}

# treat common options
# this will throw an error for unknown option if the `$CMD_OPTS_SHORT` is not prefixed by a colon `:`
# usage: `common_options "$@"`
common_options()
{
    while [ $# -gt 0 ]; do
        case "$1" in
            -f | --force )  FORCE=true;;
            -q | --quiet )  QUIET=true; VERBOSE=false;;
            -v | --verbose ) VERBOSE=true; QUIET=false;;
            -x | --debug )  DEBUG=true;;
            --dry-run )     DRY_RUN=true;;
            -- )            shift; break;;
            * )             if [ "${CMD_OPTS_SHORT:0:1}" != ":" ]; then error "unknown option '$1'"; fi;;
        esac
        shift
    done
}

# debug environment variables from the `$TO_DEBUG` array
# usage: `debug`
debug()
{
    echo '---- DEBUG ----'
    local length=0
    for i in "${TO_DEBUG[@]}"; do
        [ "${#i}" -gt "$length" ] && length="${#i}";
    done
    for i in "${TO_DEBUG[@]}"; do
        printf "%$((length+1))s : %s\n" "$i" "${!i}"
    done
    echo '---------------'
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
            stack_trace
            echo '----'
        } >&2
    fi
    exit "${err:-1}"
}

# write colorized texts
# inspired by <http://natelandau.com/bash-scripting-utilities/>
# usage: `e_*** <strings>`
e_header()
{
    printf "\n${bold}${purple}==========  %s  ==========${reset}\n" "$@"
}
e_arrow()
{
    printf "➜ %s\n" "$@"
}
e_success()
{
    printf "${green}✔ %s${reset}\n" "$@"
}
e_error()
{
    printf "${red}✖ %s${reset}\n" "$@"
}
e_warning()
{
    printf "${tan}➜ %s${reset}\n" "$@"
}
e_underline()
{
    printf "${underline}${bold}%s${reset}\n" "$@"
}
e_bold()
{
    printf "${bold}%s${reset}\n" "$@"
}
e_note()
{
    printf "${underline}${bold}${blue}Note:${reset}  ${blue}%s${reset}\n" "$@"
}

# write a full error on STDERR & show usage string & exit
# usage: `error [string='unknown error'] [status=1]`
error()
{
    {   echo "error: ${1:-unknown error}"
        $VERBOSE && echo "# in ${BASH_SOURCE[1]##*/} at line ${BASH_LINENO[0]}";
        echo '---'
        usage_info
    } >&2
    exit "${2:-1}"
}

# test if a function exists - returns a boolean
# usage: `function_exists <func_name>`
function_exists()
{
    [ $# -eq 0 ] && return 1;
    [ "$(type -t "$1")" == 'function' ]
}

# write help string to STDERR & exit
# usage: `help_info`
help_info()
{
    {   version_info
        echo
        echo "$CMD_DESCRIPTION"
        echo
        usage_info
        echo
        echo "$CMD_HELP"
    } >&2
    exit 0
}

# add an entry in `$CMD_LOGFILE`
# usage: `log <message>`
log()
{
    [ $# -eq 0 ] && return 0;
    echo "$(date +'%x %R') ${CMD_USER}@${CMD_HOST} [$$]: $*" >> "$CMD_LOGFILE";
}

# rearrange options & arguments and load them in `$CMD_REQ`
# howto:
#    rearrange_options "$@"
#    [ -n "$CMD_REQ" ] && eval set -- "$CMD_REQ";
# usage: `rearrange_options "$@"`
rearrange_options()
{
    set +E
    getoptvers="$(getopt --test > /dev/null; echo $?)"
    if [[ "$getoptvers" -eq 4 ]]; then
        # GNU enhanced getopt is available
        CMD_REQ="$(getopt --shell 'bash' --options "${CMD_OPTS_SHORT}-:" --longoptions "$CMD_OPTS_LONG" --name "$CMD_PROG" -- "$@")"
    else
        # original getopt is available
        CMD_REQ="$(getopt "$CMD_OPTS_SHORT" "$@")"
    fi
    set -E
    CMD_CALL="$0 $CMD_REQ"
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
# usage: `stack_trace`
stack_trace()
{
    set +o xtrace
    if [ ${#FUNCNAME[@]} -gt 2 ]; then
        for ((i=1;i<${#FUNCNAME[@]};i++)); do
            echo "  $i: ${BASH_SOURCE[$i+1]:-}:${BASH_LINENO[$i]} ${FUNCNAME[$i]}(...)"
        done
    fi
}

# transform a string in upper case
# usage: `string_to_upper <string>`
string_to_upper()
{
    [ $# -lt 1 ] && die 'usage: `string_to_upper <string>`';
    echo "$@" | tr '[:lower:]' '[:upper:]';
}

# transform a string in lower case
# usage: `string_to_lower <string>`
string_to_lower()
{
    [ $# -lt 1 ] && die 'usage: `string_to_lower <string>`';
    echo "$@" | tr '[:upper:]' '[:lower:]';
}

# delete eventual trailing slash
# usage: `strip_trailing_slash <path>`
strip_trailing_slash()
{
    [ $# -lt 1 ] && die 'usage: `strip_trailing_slash <path>`';
    local path="$1"
    echo "${1%/}"
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
    exec 3>&1
    set +e
    error="$($@ 2>&1 >&3)"
    retval=$?
    [ -z "$e" ] || set -e
    # if the command failed (returned a non-zero exit code)
    if [ $retval -gt 0 ]; then
        retstr="command '$*' failed: ${error:-} ($retval)"
        die "$retstr" "$retval"
    fi
}

# echo usage string
# usage: `usage_info`
usage_info()
{
    echo "usage: $CMD_SYNOPSIS"
}

# version string
# usage: `version_info`
version_info()
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
    [ -n "$1" ] && echo "> $*" >&2
}

##################
## common setup ##
##################
# trap errors to 'die'
trap 'die ${BASH_SOURCE} ${FUNCNAME:-} ${BASH_LINENO:-}' 1 2 3 15 ERR
# trap exit to 'cleanup'
trap 'cleanup' EXIT

#######################
## command variables ##
#######################
declare -xr CMD_MIN_BASH_VERSION=3
declare -xr CMD_PROG="$(basename "$0")"
declare -xr CMD_ROOT="$(real_path_dirname "$0")"
declare -xr CMD_OS="$(uname)"
declare -xr CMD_HOST="$(hostname -f)"
declare -xr CMD_USER="$(id -un)"
declare -xr CMD_CWD="$(pwd)"
declare -xr CMD_PID="$$"
declare -xr CMD_CALL_ORIGINAL="$0 $*"
declare -x CMD_CALL
# colorized output
declare -xr bold=$(tput bold)
declare -xr underline=$(tput sgr 0 1)
declare -xr reset=$(tput sgr0)
declare -xr purple=$(tput setaf 171)
declare -xr red=$(tput setaf 1)
declare -xr green=$(tput setaf 76)
declare -xr tan=$(tput setaf 3)
declare -xr blue=$(tput setaf 38)

# test of old Bash versions
[[ ${BASH_VERSION:0:1} -lt $CMD_MIN_BASH_VERSION ]] && \
    warning "you are running an old version of Bash ($BASH_VERSION) - some errors are expected.";

# the lib returns a no-error status
return 0
# Endfile
# vim: autoindent tabstop=4 shiftwidth=4 expandtab softtabstop=4 filetype=sh
