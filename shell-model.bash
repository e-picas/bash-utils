#!/usr/bin/env bash
#
# shell-model.bash
# Demonstration usage of the 'bash-utils.bash' library
# Default options are: -f | -q | -v | -x | --dry-run
#

## Bash options
set -e      # exit if a command has a non-zero status
set -E      # trap on ERR are inherited by shell functions
set -T      # trap on DEBUG and RETURN are inherited by shell functions
set -o pipefail # do not mask pipeline's errors
set -u      # throw error on unset variable usage
#set -x      # for dev usage: debug commands before to execute them
#set -v      # for dev usage: print shell input lines as they are read

## include utilities
source bash-utils.bash || { echo "> bash-utils not found!" >&2; exit 1; };

## command info
CMD_NAME='script-model'
CMD_VERSION='0.0.0'
CMD_COPYRIGHT='(CC-BY) 2015 Pierre Cassat & contributors'
CMD_LICENSE='Creative Commons 4.0 BY license <http://creativecommons.org/licenses/by/4.0/legalcode>'
CMD_SOURCES='Sources & updates: <http://gitlab.com/piwi/bash-utils.git>'
CMD_DESCRIPTION='A model for *bash* scripts.'
CMD_SYNOPSIS="$0 [-f|-q|-v|-x] [--debug|--dry-run|--force|--quiet|--verbose] <arguments> --"
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

## command options & arguments
rearrange_options "$@"
[ -n "$CMD_REQ" ] && eval set -- "$CMD_REQ";
common_options "$@"

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

# argument required
[ $# -eq 0 ] && usage_info && exit 1;

# common arguments
[ $# -gt 0 ] && common_arguments "$*";

# debug env
$DEBUG && debug;

## script's logic ...






# a bash script should always exit with a status (0 for no error)
exit 0
# Endfile
# vim: autoindent tabstop=4 shiftwidth=4 expandtab softtabstop=4 filetype=sh                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         