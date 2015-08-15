#!/usr/bin/env bash
#
# Sample usage of the 'bash-utils' library
#
set -eETu
set -o pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../bin/bash-utils" || { echo "> bash-utils not found!" >&2; exit 1; };

debug_env()
{
    local name="$1"
    declare -a table=("${!name}")
    echo "---- $name ----"
    length=0
    for i in "${table[@]}"; do
        echo "$i : ${!i:-NULL}"
    done
    echo '---------------'
}

declare -a BOURNERESERVED=(
    CDPATH HOME IFS MAIL MAILPATH OPTARG OPTIND PATH PS1 PS2
)
debug_env BOURNERESERVED[@]

declare -a BASHRESERVED=(
    auto_resume BASH BASH_ENV BASH_VERSION BASH_VERSINFO COLUMNS
    COMP_CWORD COMP_LINE COMP_POINT COMP_WORDS COMPREPLY
    DIRSTACK EUID FCEDIT FIGNORE FUNCNAME GLOBIGNORE GROUPS histchars
    HISTCMD HISTCONTROL HISTFILE HISTFILESIZE HISTIGNORE HISTSIZE HOSTFILE
    HOSTNAME HOSTTYPE IGNOREEOF INPUTRC
    LANG LC_ALL LC_COLLATE LC_CTYPE LC_MESSAGES LC_NUMERIC
    LINENO LINES MACHTYPE MAILCHECK OLDPWD OPTERR OSTYPE PIPESTATUS
    POSIXLY_CORRECT PPID PROMPT_COMMAND PS3 PS4 PWD RANDOM REPLY SECONDS SHELLOPTS SHLVL TIMEFORMAT TMOUT UID
)
debug_env BASHRESERVED[@]

declare -a BASHUTILSFLAGS=(
    CMD_PROG CMD_ROOT CMD_HOST CMD_USER CMD_CWD CMD_PID CMD_OS CMD_CALL
    VERBOSE QUIET DEBUG FORCE DRY_RUN
)
debug_env BASHUTILSFLAGS[@]

exit 0
