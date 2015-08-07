#!/usr/bin/env bash
#
# Sample usage of the 'bash-utils.bash' library
#
set -eETu
set -o pipefail
source bash-utils.bash || { echo "> bash-utils not found!" >&2; exit 1; };
CMD_NAME='script-model-sample'
CMD_VERSION='0.0.0'
CMD_COPYRIGHT='(CC-BY) 2015 Pierre Cassat & contributors'
CMD_LICENSE='Creative Commons 4.0 BY license <http://creativecommons.org/licenses/by/4.0/legalcode>'
CMD_SOURCES='Sources & updates: <http://gitlab.com/piwi/bash-utils.git>'
CMD_DESCRIPTION="A sample script from *bash* scripts' model."
CMD_SYNOPSIS="$0 [-f|-q|-v|-x] [--debug|--dry-run|--force|--quiet|--verbose]
        [-a:|-b::] [--test1:|--test2::] <arguments> --";
CMD_HELP="Example of usage:
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

Available options:
    -a|--test1=ARG      option with required argument
    -b|--test2[=ARG]    option with optional argument
    -v|--verbose        increase script's verbosity
    -q|--quiet          decrease script's verbosity
    -f|--force          do not prompt for choices if a default choice exists
    -x|--debug          see some debugging information
    --dry-run           process a dry-run

Use arguments 'usage', 'about' or 'version' for application information.";
CMD_OPTS_SHORT=':fqvxa:b::'
CMD_OPTS_LONG='debug,dry-run,force,quiet,verbose,test1:,test2::'
TO_DEBUG=(
    CMD_PROG CMD_ROOT CMD_HOST CMD_USER CMD_CWD CMD_PID CMD_OS
    CMD_CALL VERBOSE QUIET DEBUG FORCE DRY_RUN TEST1 TEST2
)
declare -x TEST1
declare -x TEST2

[ $# -eq 0 ] && usage_info && exit 1;
rearrange_options "$@"
[ -n "$CMD_REQ" ] && eval set -- "$CMD_REQ";
common_options "$@"
while [ $# -gt 0 ]; do
    case "$1" in
        -f | -q | -v | -x | --force | --quiet | --verbose | --debug | --dry-run ) true;;
        -a | --test1 ) OPTARG="$(echo "$2" | cut -d'=' -f2)"; TEST1="${OPTARG}"; shift;;
        -b | --test2 ) OPTARG="$(echo "$2" | cut -d'=' -f2)"; TEST2="${OPTARG:-default}"; shift;;
        -- ) shift; break;;
        * )  error "unknown option '$1'";;
    esac
    shift
done
[ $# -gt 0 ] && common_arguments "$*";
$DEBUG && debug;

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
        echo 'test'
        try "ls *.bash"
        try "echo test"
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

    # test colors
    colors)
        e_header "I am a sample script"
        e_success "I am a success message"
        e_error "I am an error message"
        e_warning "I am a warning message"
        e_underline "I am underlined text"
        e_bold "I am bold text"
        e_note "I am a note"
        ;;

    *) error "unknown action '$1'";
esac

exit 0
