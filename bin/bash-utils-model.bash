#!/usr/bin/env bash
#
# Demonstration usage of the 'bash-utils.bash' library
# Sources & updates at <http://gitlab.com/piwi/bash-utils.git>
# Default options are: -f | -q | -v | -x | --dry-run
#

#######################
## Bash options
set -e      # exit if a command has a non-zero status
set -E      # trap on ERR are inherited by shell functions
set -T      # trap on DEBUG and RETURN are inherited by shell functions
set -o pipefail # do not mask pipeline's errors
set -u      # throw error on unset variable usage
#set -x      # for dev usage: debug commands before to execute them
#set -v      # for dev usage: print shell input lines as they are read

#######################
## include utilities
source bash-utils.bash || { echo "> bash-utils not found!" >&2; exit 1; };

#######################
## command info
CMD_NAME='bash-utils-model'
CMD_VERSION='0.0.0'
CMD_COPYRIGHT='My command copyright'
CMD_LICENSE='My command license'
CMD_SOURCES='My command sources'
CMD_DESCRIPTION='A model for *bash* scripts using the *bash-utils* library.'
CMD_SYNOPSIS="$0 [-fqvx] [--debug|--dry-run|--force|--quiet|--verbose] <arguments> --"
CMD_HELP="
My command help string ...

Available options:
    -v|--verbose    increase script's verbosity
    -q|--quiet      decrease script's verbosity
    -f|--force      do not prompt for choices if a default choice exists
    -x|--debug      see some debugging information
    --dry-run       process a dry-run

Use arguments 'usage', 'about' or 'version' for application information.";
CMD_OPTS_SHORT='fqvx'
CMD_OPTS_LONG='debug,dry-run,force,quiet,verbose'

#######################
## command options & arguments

# re-arrangement of options and arguments
rearrange_options "$@"
[ -n "$CMD_REQ" ] && eval set -- "$CMD_REQ";

# common options treatment
common_options "$@"

# custom options eventually
while [ $# -gt 0 ]; do
    case "$1" in
        # do not throw error for common options
        -f | -q | -v | -x | --force | --quiet | --verbose | --debug | --dry-run ) true;;

        # user options
        # to add your own options, use:
        #
        # declare -xr CMD_OPTS_SHORT='fqvxa:b::'
        # declare -xr CMD_OPTS_LONG='force,quiet,verbose,debug,dry-run,test1:,test2::'
        #
        # -a | --test1 ) OPTARG="$(echo "$2" | cut -d'=' -f2)"; TEST1="${OPTARG}"; shift;;
        # -b | --test2 ) OPTARG="$(echo "$2" | cut -d'=' -f2)"; TEST2="${OPTARG:-default}"; shift;;
        #
        
        # end of options
        -- ) shift; break;;
        # unknown option
        * )  error "unknown option '$1'";;
    esac
    shift
done

# usage info if no argument
[ $# -eq 0 ] && usage_info && exit 1;

# common arguments treatment (help, usage, version, about)
[ $# -gt 0 ] && common_arguments "$*";

# debug environment in debug mode
$DEBUG && debug;

#######################
## script's logic ...

# to throw an error for 'non-dev' users
# error 'my error string'

# to throw an error for 'dev' users
# die 'my error string'

# to write colorized content
# e_color 'my string with <red>styles</red> <bold>tags</bold>'

# to write a string in verbose mode only
# $VERBOSE && echo 'my string';

# to write a string in not quiet mode
# $QUIET || echo 'my string';

# to not execute a command in dry-run mode
# if $DRY_RUN; then echo 'rm -f filename.txt'; else rm -f filename.txt; fi

# see the 'bash-utils.bash' sources themselves for complete documentation

# ...




#######################
## exit
# a bash script should always exit with a status (0 for no error)
exit 0

## vim default shell setup (must be the very last line):
# vim: autoindent tabstop=4 shiftwidth=4 expandtab softtabstop=4 filetype=sh
