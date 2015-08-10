#!/usr/bin/env bash
#
# bash-util.bash - A short *bash* library for better scripting
#
# Copyright 2015 Pierre Cassat (me at e-piwi dot fr) & contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>.
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code or see <http://www.apache.org/licenses/LICENSE-2.0>.
#
# Sources & updates at <http://gitlab.com/piwi/bash-utils.git>.
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

######################
## environment vars ##
######################

# use this variable to pass empty an array reference `EMPTY_ARRAY[@]`
declare -arx EMPTY_ARRAY=()

# any piped input is loaded in that variable calling `read_from_pipe`
declare -x _PIPED_INPUT

# colors and styles lists
declare -rxa TEXTOPTIONS=(normal bold small underline blink reverse hidden)
declare -rxa TEXTCOLORS=(
    normal black red green yellow blue magenta cyan grey white
    lightred lightgreen lightyellow lightblue lightmagenta lightcyan lightgrey
);
declare -rxa TEXTOPTIONS_CODES=(0 1 2 4 5 7 8)
declare -rxa TEXTCOLORS_CODES_FOREGROUND=(39 30 31 32 33 34 35 36 90 97 91 92 93 94 95 96 37)
declare -rxa TEXTCOLORS_CODES_BACKGROUND=(49 40 41 42 43 44 45 46 100 107 101 102 103 104 105 106 47)

####################
## common library ##
####################
# functions are written in alphabetical order

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

# get the index of a value in an array
# usage: `array_search <item> <$array[@]>`
array_search ()
{
    [ $# -lt 2 ] && die 'usage: `array_search <item> <$array[@]>`';
    local i=0 j
    local search="$1"
    shift
    declare -a args
    if [ $# -gt 1 ]; then
        args=("$@")
    else
        args=("${!1}")
    fi
    for ((j=0; j<"${#args[@]}"; j++)); do
        [ "$search" = "${args[$j]}" ] && i="$j";
    done
    [ "$i" != '0' ] && echo "$i" && return 0
    return 1
}

# cleanup after the script exits
# this one should never be called directly as it is trapped on EXIT
# usage: `cleanup`
cleanup()
{
    # draw your own cleanup stuff here
    return 0
}

# write a comment string on STDOUT
# usage: `comment <string>`
comment()
{
    [ -n "$1" ] && echo "# $*" >&1
    return 0
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
    return 0
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
    return 0
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
    return 0
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

# parse a string with style tags like `<TAGNAME>...</TAGNAME>` following the rules:
#   - tag from `TEXTOPTIONS` for emphasis
#   - tag from `TEXTCOLORS` for foreground color
#   - tag from `TEXTCOLORS` for background color, constructed like `TAG_bg`
# i.e.:
#   "a string with <bold>tags</bold> to <red>set</red> <red_bg>styles</red_bg>"
# usage: `e_color <string>`
e_color()
{
    [ $# -eq 0 ] && return 0;
    local tag_code tag_reset
    while read -r line; do
        for opt in $(echo "$line" | grep -o '<[^/>]*>' | sed "s|^.*<\([^\/>]*\)>.*\$|\1|g"); do
            if [ "${opt: -3}" = '_bg' ]; then
                tag_code="${TEXTCOLORS_CODES_BACKGROUND[$(array_search "${opt/_bg/}" "${TEXTCOLORS[@]}")]}"
                tag_reset="${TEXTCOLORS_CODES_BACKGROUND[0]}"
            else
                if in_array "$opt" "${TEXTCOLORS[@]}"; then
                    tag_code="${TEXTCOLORS_CODES_FOREGROUND[$(array_search "$opt" "${TEXTCOLORS[@]}")]}"
                    tag_reset="${TEXTCOLORS_CODES_FOREGROUND[0]}"
                elif in_array "$opt" "${TEXTOPTIONS[@]}"; then
                    tag_code="${TEXTOPTIONS_CODES[$(array_search "$opt" "${TEXTOPTIONS[@]}")]}"
                    tag_reset="${TEXTOPTIONS_CODES[0]}"
                fi
            fi
            if [ -n "$tag_code" ] && [ -n "$tag_reset" ]; then
                tag_code="$(printf '\%s' "\033[${tag_code}m")"
                tag_reset="$(printf '\%s' "\033[${tag_reset}m")"
                line=$(echo "$line" | sed "s|<${opt}>|${tag_code}|g;s|</${opt}>|${tag_reset}|g");
            fi
        done
#        $(which echo) -e "$line"
        $(which echo) -e "$line"
#        printf '%s\n' "$line"
    done <<< "$1"
    return 0
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

# get the number of the line matching a mask in a file (empty result if not found)
# usage: `get_line_number_matching <file_path> <mask>`
get_line_number_matching()
{
    [ $# -lt 1 ] && die 'usage: `get_line_number_matching <file_path> <mask>`';
    local path="$1"
    [ ! -e "$path" ] && die "file '${path}' not found";
    local match="$2"
    grep -n "$match" "$path" | cut -f1 -d:
    return 0
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

# test if a value is in an array ; returns 0 if it is found
# usage: `in_array <item> <$array[@]>`
in_array()
{
    [ $# -lt 2 ] && die 'usage: `in_array <item> <$array[@]>`';
    local needle="$1"
    shift
    declare -a args
    if [ $# -gt 1 ]; then
        args=("$@")
    else
        args=("${!1}")
    fi
    for item in "${args[@]}"; do
        [ "$needle" = "$item" ] && return 0
    done
    return 1
}

# add an entry in `$CMD_LOGFILE`
# usage: `log <message>`
log()
{
    [ $# -eq 0 ] && return 0;
    echo "$(date +'%x %R') ${CMD_USER}@${CMD_HOST} [$$]: $*" >> "$CMD_LOGFILE";
    return 0
}

# print a list with optional headers
#
# how to:
#
# - declare the list arrays for names and values
#       declare -a LIST_NAMES=()
#       declare -a LIST_VALUES=()
#
# - decalre list headers as an array (optional)
#       declare -a LIST_HEADERS=('name' 'value')
#
# - add some name/value items
#       LIST_NAMES[${#LIST_NAMES[@]}]='my name 1'
#       LIST_VALUES[${#LIST_VALUES[@]}]='my value 1'
#
# - declare the list padders (characters used to fill blank spaces)
#   - item [0] is padder for the separation line
#   - item [1] is padder for contents lines
#       declare -a LIST_PADDERS=()
#       LIST_PADDERS[0]="$(printf '%0.1s' "-"{1..120})"
#       LIST_PADDERS[1]="$(printf '%0.1s' " "{1..120})"
#
# - declare the list paddings (number of space(s) from line to central separator)
#   - item [0] is padding for the separation line
#   - item [1] is padding for contents lines
#       declare -a LIST_PADDINGS=(0 1)
#
# - declare the list separators (characters used to separate cells)
#   - item [0] is the separator for the separation line
#   - item [1] is the separator for contents lines
#       declare -a LIST_SEPARATORS=('+' '|')
#
# - call the `print_list` method with all variables:
#       print_list LIST_NAMES[@] LIST_VALUES LIST_HEADERS[@] LIST_PADDINGS[@] LIST_PADDERS[@] LIST_SEPARATORS[@]
#
# usage: `print_list <names[@]> <values[@]> <headers[@]> <paddings[@]> <padders[@]> <separators[@]>`
print_list()
{
    [ $# -lt 2 ] && return 0;
    declare -ax _LIST_NAMES _LIST_VALUES _LIST_HEADERS _LIST_PADDINGS _LIST_PADDERS _LIST_SEPARATORS _LIST_LENGTHS _ITEM_NAME _ITEM_VALUE
    _LIST_NAMES=("${!1}")
    _LIST_VALUES=("${!2}")
    [ $# -gt 2 ] && _LIST_HEADERS=("${!3}")    || _LIST_HEADERS=();
    [ $# -gt 3 ] && _LIST_PADDINGS=("${!4}")   || _LIST_PADDINGS=(0 1);
    [ $# -gt 4 ] && _LIST_PADDERS=("${!5}")    || _LIST_PADDERS=("$(printf '%0.1s' "-"{1..120})" "$(printf '%0.1s' " "{1..120})");
    [ $# -gt 5 ] && _LIST_SEPARATORS=("${!6}") || _LIST_SEPARATORS=('+' '|');
    # get lengths
    _LIST_LENGTHS=(0 0)
    for ((j=0; j<2; j++)); do
        if [ ${#_LIST_HEADERS[$j]} -gt "${_LIST_LENGTHS[0]}" ]; then
            _LIST_LENGTHS[0]=${#_LIST_HEADERS[$j]}
        fi
    done
    for ((j=0; j<"${#_LIST_NAMES[@]}"; j++)); do
        if [ ${#_LIST_NAMES[$j]} -gt "${_LIST_LENGTHS[0]}" ]; then
            _LIST_LENGTHS[0]=${#_LIST_NAMES[$j]}
        fi
    done
    for ((j=0; j<"${#_LIST_VALUES[@]}"; j++)); do
        if [ ${#_LIST_VALUES[$j]} -gt "${_LIST_LENGTHS[1]}" ]; then
            _LIST_LENGTHS[1]=${#_LIST_VALUES[$j]}
        fi
    done
    # print headers line if so
    if [ "${#_LIST_HEADERS[@]}" -gt 0 ]; then
        # print headers line
        print_list_line "${_LIST_HEADERS[0]}" "${_LIST_HEADERS[1]}"
        # print separator line
        print_list_separator_line
    fi
    # print each line
    for ((j=0; j<"${#_LIST_NAMES[@]}"; j++)); do
        print_list_line "${LIST_NAMES[$j]}" "${LIST_VALUES[$j]}"
    done
    return 0
}

# print one line of a list
# called by `print_list()`
# usage: `print_list_line <name> <value>`
print_list_line()
{
    [ $# -lt 2 ] && return 0;
    _ITEM_NAME="${1}"
    _ITEM_VALUE="${2}"
    line="$(printf "%*.*s%s%*.*s%s%*.*s%s%*.*s" \
        0 $((${_LIST_LENGTHS[0]} - ${#_ITEM_NAME})) "${_LIST_PADDERS[1]}" \
        "${_ITEM_NAME}" \
        0 "${_LIST_PADDINGS[1]}" "${_LIST_PADDERS[1]}" \
        "${_LIST_SEPARATORS[1]}" \
        0 "${_LIST_PADDINGS[1]}" "${_LIST_PADDERS[1]}" \
        "${_ITEM_VALUE}" \
        0 $((${_LIST_LENGTHS[1]} - ${#_ITEM_NAME})) "${_LIST_PADDERS[1]}" \
    )";
    echo "$line"
    return 0
}

# print a separation line of a list
# called by `print_list()`
# usage: `print_list_separator_line`
print_list_separator_line()
{
    local line
    line="$(printf "%*.*s%*.*s%s%*.*s%*.*s" \
        0 $((${_LIST_LENGTHS[0]} + ${_LIST_PADDINGS[1]} - ${_LIST_PADDINGS[0]})) "${_LIST_PADDERS[0]}" \
        0 "${_LIST_PADDINGS[0]}" "${_LIST_PADDERS[1]}" \
        "${_LIST_SEPARATORS[0]}" \
        0 "${_LIST_PADDINGS[0]}" "${_LIST_PADDERS[1]}" \
        0 $((${_LIST_LENGTHS[1]} + ${_LIST_PADDINGS[1]} - ${_LIST_PADDINGS[0]})) "${_LIST_PADDERS[0]}" \
    )";
    echo "$line"
    return 0
}

# print a table with optional headers
#
# how to:
#
# - declare the table array
#       declare -a TABLE_ITEMS=()
#
# - declare the table padders (characters used to fill blank spaces)
#   - item [0] is padder for separation lines cells
#   - item [1] is padder for contents lines cells
#       declare -a TABLE_PADDERS=()
#       TABLE_PADDERS[0]="$(printf '%0.1s' "-"{1..120})"
#       TABLE_PADDERS[1]="$(printf '%0.1s' " "{1..120})"
#
# - declare the table paddings (number of space(s) from line to cell's contents)
#   - item [0] is padding for separation lines cells
#   - item [1] is padding for contents lines cells
#       declare -a TABLE_PADDINGS=()
#       TABLE_PADDINGS[0]=0
#       TABLE_PADDINGS[1]=1
#
# - declare the table separators (characters used to separate cells)
#   - item [0] is the separator for separation lines
#   - item [1] is the separator for contents lines
#       declare -a TABLE_SEPARATORS=('+' '|')
#
# - declare the table headers as an array
#       declare -a TABLE_HEADERS=( "name" "value" "comment" )
#
# - add each line of the table as an array, declared itself as another array
#       declare -a ITEM_0=("my name1" "my value1" "my comment1")
#       TABLE_ITEMS[${#TABLE_ITEMS[@]}]=ITEM_0[@]
#
# - call the `print_table` method with all variables:
#       print_table TABLE_ITEMS[@] TABLE_HEADERS[@] TABLE_PADDINGS[@] TABLE_PADDERS[@] TABLE_SEPARATORS[@]
#
# usage: `print_table <items[@]> <headers[@]> <paddings[@]> <padders[@]> <separators[@]>`
print_table()
{
    [ $# -eq 0 ] && return 0;
    declare -xa _TABLE_ITEMS _TABLE_HEADERS _TABLE_PADDERS _TABLE_PADDINGS _TABLE_SEPARATORS _TABLE_ITEM _TABLE_LENGTHS
    _TABLE_ITEMS=("${!1}")
    [ $# -gt 1 ] && _TABLE_HEADERS=("${!2}")    || _TABLE_HEADERS=();
    [ $# -gt 2 ] && _TABLE_PADDINGS=("${!3}")   || _TABLE_PADDINGS=(0 1);
    [ $# -gt 3 ] && _TABLE_PADDERS=("${!4}")    || _TABLE_PADDERS=("$(printf '%0.1s' "-"{1..120})" "$(printf '%0.1s' " "{1..120})");
    [ $# -gt 4 ] && _TABLE_SEPARATORS=("${!5}") || _TABLE_SEPARATORS=('+' '|');
    # get length for each column
    local i j
    _TABLE_LENGTHS=()
    if [ "${#_TABLE_HEADERS[@]}" -gt 0 ]; then
        for ((j=0; j<"${#_TABLE_HEADERS[@]}"; j++)); do
            if [ ! "${_TABLE_LENGTHS[$j]+x}" ] || [ ${#_TABLE_HEADERS[$j]} -gt "${_TABLE_LENGTHS[$j]}" ]; then
                _TABLE_LENGTHS[$j]=${#_TABLE_HEADERS[$j]}
            fi
        done
    fi
    for ((i=0; i<"${#_TABLE_ITEMS[@]}"; i++)); do
        _TABLE_ITEM=("${!_TABLE_ITEMS[$i]}")
        for ((j=0; j<"${#_TABLE_ITEM[@]}"; j++)); do
            if [ ! "${_TABLE_LENGTHS[$j]+x}" ] || [ ${#_TABLE_ITEM[$j]} -gt "${_TABLE_LENGTHS[$j]}" ]; then
                _TABLE_LENGTHS[$j]=${#_TABLE_ITEM[$j]}
            fi
        done
    done
    # print headers line if so
    if [ "${#_TABLE_HEADERS[@]}" -gt 0 ]; then
        # print separator line
        print_table_separator_line
        # print headers line
        print_table_line _TABLE_HEADERS[@]
    fi
    # print first contents' separator line
    print_table_separator_line
    # print each contents line
    for ((i=0; i<"${#_TABLE_ITEMS[@]}"; i++)); do
        _TABLE_ITEM=("${!_TABLE_ITEMS[$i]}")
        print_table_line _TABLE_ITEM[@]
    done
    # print last contents' separator line
    print_table_separator_line
    return 0
}

# print one line of a table
# called by `print_table()`
# usage: `print_table_line <item[@]>`
print_table_line()
{
    [ $# -eq 0 ] && return 0;
    _TABLE_ITEM=("${!1}")
    local line value j
    line=''
    for ((j=0; j<"${#_TABLE_LENGTHS[@]}"; j++)); do
        value=''
        [ "${_TABLE_ITEM[$j]+x}" ] && value="${_TABLE_ITEM[$j]}";
        line+="$(printf '%*.*s%s%*.*s%s' \
            0 "${_TABLE_PADDINGS[1]}" "${_TABLE_PADDERS[1]}" \
            "$value" \
            0 $((${_TABLE_LENGTHS[$j]} + ${_TABLE_PADDINGS[1]} - ${#_TABLE_ITEM[$j]})) "${_TABLE_PADDERS[1]}" \
            "${_TABLE_SEPARATORS[1]}" \
        )";
    done
    echo "${_TABLE_SEPARATORS[1]}${line}"
    return 0
}

# print a separation line of a table
# called by `print_table()`
# usage: `print_table_separator_line`
print_table_separator_line()
{
    local line=''
    for ((j=0; j<"${#_TABLE_LENGTHS[@]}"; j++)); do
        line+="$(printf '%*.*s%*.*s%*.*s%s' \
            0 ${_TABLE_PADDINGS[0]} "${_TABLE_PADDERS[1]}" \
            0 $((${_TABLE_LENGTHS[$j]} + (2 * ${_TABLE_PADDINGS[1]}) - (2 * ${_TABLE_PADDINGS[0]}) )) "${_TABLE_PADDERS[0]}" \
            0 ${_TABLE_PADDINGS[0]} "${_TABLE_PADDERS[1]}" \
            "${_TABLE_SEPARATORS[0]}" \
        )";
    done
    echo "${_TABLE_SEPARATORS[0]}${line}"
    return 0
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
    return 0
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
    return 0
}

# read any piped content and load it in `_PIPED_INPUT`
# usage: `read_from_pipe [file=/dev/stdin]`
read_from_pipe()
{
    local fpipe fpipedir
    fpipe="${1:-/dev/stdin}"
    fpipedir="$(dirname "$fpipe")"
    if [ -e "$fpipe" ] && [ -p "$fpipe" ]; then
        _PIPED_INPUT="$(cat "$fpipe")"
    fi
    return 0
}

# resolve symbolic link
# inspired by <https://github.com/sstephenson/bats>
# usage: `resolve_link <path>`
resolve_link()
{
    [ $# -lt 1 ] && die 'usage: `resolve_link <path>`';
    $(type -p greadlink readlink | head -1) "$1"
    return 0
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
    return 0
}

# transform a string in upper case
# usage: `string_to_upper <string>`
string_to_upper()
{
    [ $# -lt 1 ] && die 'usage: `string_to_upper <string>`';
    echo "$@" | tr '[:lower:]' '[:upper:]';
    return 0
}

# transform a string in lower case
# usage: `string_to_lower <string>`
string_to_lower()
{
    [ $# -lt 1 ] && die 'usage: `string_to_lower <string>`';
    echo "$@" | tr '[:upper:]' '[:lower:]';
    return 0
}

# delete eventual trailing slash
# usage: `strip_trailing_slash <path>`
strip_trailing_slash()
{
    [ $# -lt 1 ] && die 'usage: `strip_trailing_slash <path>`';
    local path="$1"
    echo "${1%/}"
    return 0
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
    return "$retval"
}

# echo usage string
# usage: `usage_info`
usage_info()
{
    echo "usage: $CMD_SYNOPSIS"
    return 0
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
    return 0
}

# write an error string on STDERR without exiting
# usage: `warning <string>`
warning()
{
    [ -n "$1" ] && echo "> $*" >&2
    return 0
}

################
## bash utils ##
################
sourcename="$(basename "${BASH_SOURCE[0]}")"
declare -xr BASH_UTILS_KEY='bash-utils'
declare -xr BASH_UTILS="$(real_path_dirname "${BASH_SOURCE[0]}")/${sourcename}"
declare -xr BASH_UTILS_MODEL="$(real_path_dirname "${BASH_SOURCE[0]}")/${sourcename/.bash/-model.bash}"
declare -xr BASH_UTILS_VERSION='0.0.1@dev'

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

# test of old Bash versions
[[ ${BASH_VERSION:0:1} -lt $CMD_MIN_BASH_VERSION ]] && \
    warning "you are running an old version of Bash ($BASH_VERSION) - some errors are expected.";

# the lib returns a no-error status here if no direct call
if [ "$(basename "$0")" != "$(basename "${BASH_SOURCE[0]}")" ]; then return 0; fi

###########################
## bash utils as command ##
###########################
CMD_NAME="$BASH_UTILS_KEY"
CMD_VERSION="$BASH_UTILS_VERSION"
CMD_COPYRIGHT='Copyright (c) 2015 Pierre Cassat & contributors'
CMD_LICENSE='Apache License version 2.0 <http://www.apache.org/licenses/LICENSE-2.0>'
CMD_SOURCES='Sources & updates: <http://gitlab.com/piwi/bash-utils.git>'
CMD_DESCRIPTION='A short *bash* library for better scripting.'
CMD_SYNOPSIS="$0 [-fqvVx] [--debug|--dry-run|--force|--quiet|--verbose|--version] [-e|--exec[=<arg>]] <arguments> --"
CMD_HELP="arguments:
    about               get library information (license, version etc)
    help                see this help string
    model [file_path]   see the 'bash-utils-model.bash' model or copy it in 'file_path'
    usage               get the library synopsis
    version             get the library version (use option 'quiet' to get the version number only)

options:
    --dry-run           process a dry-run
    -e|--exec=<arg>     execute the argument in the library's environment:
                            # bash-utils --exec='e_color \"<bold>test</bold>\"'
    -e|--exec           without argument, any piped content will be evaluated:
                            # echo 'e_color \"<bold>test</bold>\"' | bash-utils --exec
    -f|--force          do not prompt for choices if a default choice exists
    -q|--quiet          decrease script's verbosity
    -v|--verbose        increase script's verbosity
    -x|--debug          see some debugging information
    -V|--version        alias for the 'version' argument above

paths:
    $BASH_UTILS
    $BASH_UTILS_MODEL
";
CMD_OPTS_SHORT=':e::fqvVx'
CMD_OPTS_LONG='exec::,debug,dry-run,force,quiet,verbose,version'
TO_DEBUG[${#TO_DEBUG[@]}]=BASH_UTILS_KEY
TO_DEBUG[${#TO_DEBUG[@]}]=BASH_UTILS
TO_DEBUG[${#TO_DEBUG[@]}]=BASH_UTILS_MODEL
TO_DEBUG[${#TO_DEBUG[@]}]=BASH_UTILS_VERSION
[ $# -eq 0 ] && usage_info && exit 1;
rearrange_options "$@"
[ -n "$CMD_REQ" ] && eval set -- "$CMD_REQ";
common_options "$@"
read_from_pipe
$DEBUG && debug;
while [ $# -gt 0 ]; do
    case "$1" in
        -f | -q | -v | -x | --force | --quiet | --verbose | --debug | --dry-run ) true;;
        -V | --version ) version_info && exit 0;;
        -e | --exec* )
            OPTARG="$(echo "$2" | cut -d'=' -f2)"
            arg="${OPTARG}"
            [ -z "$arg" ] && arg="$_PIPED_INPUT";
            eval "$arg"
            exit $?
            ;;
        -- ) shift; break;;
        * )  error "unknown option '$1'";;
    esac
    shift
done
[ $# -gt 0 ] && common_arguments "$*";
while [ $# -gt 0 ]; do
    case "$1" in
        model )
            shift
            arg="${1:-}"
            if [ -n "$arg" ]; then
                cp "$BASH_UTILS_MODEL" "$arg"
                chmod a+x "$arg"
                ! $QUIET && echo "$arg";
            else
                cat "$BASH_UTILS_MODEL"
            fi
            exit 0
            ;;
    esac
    shift
done
exit 0
# Endfile
# vim: autoindent tabstop=4 shiftwidth=4 expandtab softtabstop=4 filetype=sh
