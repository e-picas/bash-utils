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

# write colorized texts
# inspired by <http://natelandau.com/bash-scripting-utilities/>
# usage: `e_*** <strings>`
e_header()
{
    e_color "\n<bold><lightmagenta>==========  $@  ==========</bold></lightmagenta>"
}
e_arrow()
{
    e_color "➜ $@"
}
e_success()
{
    e_color "<lightgreen>✔ $@</lightgreen>"
}
e_error()
{
    e_color "<red>✖ $@</red>"
}
e_warning()
{
    e_color "<yellow>➜ $@</yellow>"
}
e_underline()
{
    e_color "<underline><bold>$@</bold></underline>"
}
e_bold()
{
    e_color "<bold>$@</bold>"
}
e_note()
{
    e_color "<underline><bold><cyan>Note:</underline></bold></cyan>  <cyan>$@</cyan>"
}


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


        padder="$(printf '%0.1s' "-"{1..120})"
        loremipsum='lorem ipsum sit amet'

        title="TEXTOPTIONS"
        printf "%*.*s | %s %*.*s\n" 0 16 "$padder" "$title" 0 $((80 - ${#title})) "$padder"
        for i in "${TEXTOPTIONS[@]}"; do
            [ "$i" = 'normal' ] && continue;
            text="<${i}>${loremipsum}</${i}>"
            printf "%16s | %20s | %s\n" "$i" "$(e_color "$text")" "$text"
        done

        title="TEXTCOLORS (foregrounds)"
        printf "%*.*s | %s %*.*s\n" 0 16 "$padder" "$title" 0 $((80 - ${#title})) "$padder"
        for i in "${TEXTCOLORS[@]}"; do
            [ "$i" = 'normal' ] && continue;
            text="<${i}>${loremipsum}</${i}>"
            printf "%16s | %20s | %s\n" "$i" "$(e_color "$text")" "$text"
        done

        title="TEXTCOLORS (backgrounds)"
        printf "%*.*s | %s %*.*s\n" 0 16 "$padder" "$title" 0 $((80 - ${#title})) "$padder"
        for i in "${TEXTCOLORS[@]}"; do
            [ "$i" = 'normal' ] && continue;
            text="<${i}_bg>${loremipsum}</${i}_bg>"
            printf "%16s | %20s | %s\n" "${i}_bg" "$(e_color "$text")" "$text"
        done

        printf "%*.*s | %*.*s\n" 0 16 "$padder" 0 80 "$padder"

        echo "## raw examples:"
        e_color "$(cat <<MSG
<bold>mlkj</bold>
<magenta>qsdfqsf qsdfqsdfc </magenta>
<magenta_bg>qsdfqsf qsdfqsdfc </magenta_bg>
Lorem ipsum <bold>dolor</bold> sit amet <cyan>Lorem ipsum dolor sit amet</cyan> Lorem <underline>ipsum</underline> <red_bg>dolor</red_bg> sit amet .
Lorem ipsum <bold>dolor</bold> sit amet <cyan>Lorem ipsum <bold>dolor</bold> sit amet</cyan> Lorem ipsum <red_bg>dolor</red_bg> sit amet .
a string with <bold>tags</bold> to <red>set</red> <red_bg>styles</red_bg>
<unknown>mlkj</unknown>
MSG
)";

        e_color '<bold>yo</bold> test'

        ;;

    arrays)

        echo
        echo '###########################'
        echo 'print_table'
        echo

        # declare the table array
        declare -a TABLE_ITEMS=()

        # declare the table padders (characters used to fill balcnk spaces)
        # item [0] is padder for separation lines cells
        # item [1] is padder for contents lines cells
        declare -a TABLE_PADDERS=()
        TABLE_PADDERS[0]="$(printf '%0.1s' "-"{1..120})"
        TABLE_PADDERS[1]="$(printf '%0.1s' " "{1..120})"

        # declare the table paddings (number of space(s) from line to cell's contents)
        # item [0] is padding for separation lines cells
        # item [1] is padding for contents lines cells
        declare -a TABLE_PADDINGS=()
        TABLE_PADDINGS[0]=0
        TABLE_PADDINGS[1]=1

        # declare the table separators (characters used to separate cells)
        # item [0] is the separator for separation lines
        # item [1] is the separator for contents lines
        declare -a TABLE_SEPARATORS=()
        TABLE_SEPARATORS[0]='+'
        TABLE_SEPARATORS[1]='|'

        # first item are headers
        declare -a TABLE_HEADERS=( "name" "value" "comment" )
        #TABLE_ITEMS[0]=TABLE_HEADERS[@]

        # add one line as array, declared itself as another array
        declare -a SUB_0=("my name1" "my value1" "my comment1")
        TABLE_ITEMS[${#TABLE_ITEMS[@]}]=SUB_0[@]

        # add one line as array, declared itself as another array
        declare -a SUB_1=("my name2" "lorem ipsum dolor sit amet")
        TABLE_ITEMS[${#TABLE_ITEMS[@]}]=SUB_1[@]

        print_table TABLE_ITEMS[@] TABLE_HEADERS[@] TABLE_PADDINGS[@] TABLE_PADDERS[@] TABLE_SEPARATORS[@]

        echo
        echo '###########################'
        echo 'print_list'
        echo

        # declare the list arrays
        declare -a LIST_HEADERS=('name' 'value')
        declare -a LIST_NAMES=()
        declare -a LIST_VALUES=()

        # add name/value items
        LIST_NAMES[${#LIST_NAMES[@]}]='my name 1'
        LIST_VALUES[${#LIST_VALUES[@]}]='my value 1'

        LIST_NAMES[${#LIST_NAMES[@]}]='my longer name 2'
        LIST_VALUES[${#LIST_VALUES[@]}]='my value 2: lorem ipsum dolor site amet'

        # declare the table padders (characters used to fill balcnk spaces)
        # item [0] is padder for separation lines cells
        # item [1] is padder for contents lines cells
        declare -a LIST_PADDERS=()
        LIST_PADDERS[0]="$(printf '%0.1s' "-"{1..120})"
        LIST_PADDERS[1]="$(printf '%0.1s' " "{1..120})"

        # declare the table paddings (number of space(s) from line to cell's contents)
        # item [0] is padding for separation lines cells
        # item [1] is padding for contents lines cells
        declare -a LIST_PADDINGS=()
        LIST_PADDINGS[0]=0
        LIST_PADDINGS[1]=1

        # declare the table separators (characters used to separate cells)
        # item [0] is the separator for separation lines
        # item [1] is the separator for contents lines
        declare -a LIST_SEPARATORS=()
        LIST_SEPARATORS[0]='+'
        LIST_SEPARATORS[1]='|'

        print_list LIST_NAMES[@] LIST_VALUES[@] LIST_HEADERS[@] LIST_PADDINGS[@] LIST_PADDERS[@] LIST_SEPARATORS[@]
        ;;

    test)


        ;;

    *) error "unknown action '$1'";
esac

exit 0
