Man:        Bash-Utils Documentation
Man-name:   bash-utils
Author:     Pierre Cassat
Section:    7
Date: 2015-08-14
Version: 0.0.1@dev


## USAGE

To create a script using the library, you can call the *model* argument of the library itself, which
will create a starter template script:

    bash-utils model /path/to/your/script.sh

Actually, the only requirement to use the library is to source it in your script:

    source bash-utils

You can also use it as your script's *interpreter* defining it in your 
[*hash bang* (*shebang*)](https://en.wikipedia.org/wiki/Shebang_%28Unix%29) line (this is the case
of the model):

    #!/usr/bin/env bash-utils

    # write your script here

### Notes about *bash* scripting and usage

To enable "per-user" binaries (let the system look in any `$HOME/bin/` directory when searching scripts), 
be sure to add that directory to the `$PATH` environment variable (in your `$HOME/.bashrc` for instance):

    # user binaries path
    [ -d "${HOME}/bin" ] && export PATH="${PATH}:${HOME}/bin";

You can name your scripts following your preferences and place it where you want as long as you can access it easily.
The file extension has no incidence upon the script's type (*bash* in our case) as the interpreter is designed by the 
[**shebang** directive](https://en.wikipedia.org/wiki/Shebang_%28Unix%29) ; you could name your script with an 
`.sh`, a `.bash` and even a `.py` extension (which would have no real sense here) or let it without extension 
at all with no difference.

A command-line program (such as a shell script) often accepts to set some options and arguments calling it in a terminal
or another script. A global synopsis of command line call can be:

    path/to/script [-o | --options (=argument)] [--] [<parameter> ...]
    # i.e.:
    program-to-run -o --option='my value' --option-2 'my value' argument1 argument2

The rules are the followings:

-   an *argument* is a setting passed to the script when calling it ; the arguments are not the same as the options as 
    they are not named but identified by their position ; i.e. `./script --option argument1 argument2`
-   *options* are various settings passed to the script when calling it ; each option is prefixed by one or more dash `-` 
    and can have an argument ; by convention, a short option is composed by one single letter prefixed by one dash, i.e. `-o`, 
    and a long option is composed by a word prefixed by two dashes, i.e. `--option` ; when an option accepts an argument, 
    it must be separated from the option name by an equal sign, i.e. `--option=argument` and `-o=argument` ; i.e. 
    `./script -o --option-with-no-arg --option-with-arg=argument_value`
-   a double dashes ` -- ` can be used to identify the end of options ; the rest of the call will be considered as arguments
    only


### Starter template

    #!/usr/bin/env bash-utils
    # reset bash options here if needed
    # set +E
    
    # write your scripts logic here
    # ...
    
    # a script should always return a status
    exit 0


### Customize your script

To build your own command, you may first override informational variables:

    CMD_NAME=...
    CMD_VERSION=...
    CMD_COPYRIGHT=...
    CMD_LICENSE=...
    CMD_SOURCES=...
    CMD_DESCRIPTION=...
    CMD_SYNOPSIS=...
    CMD_HELP=...
    CMD_OPTS_SHORT=...
    CMD_OPTS_LONG=...

Then you can customize script's options (see below) to fit your needs and write your script's logic in the last
part of the model.


## DOCUMENTATION

### Library's methods

The library embeds a short set of methods to facilitate your scripts:

-   the `die()` method will exit with an error message and a back trace, all to STDERR
-   the `error()` method will exit with an error message to STDERR (user friendly)
-   the `warning()` method will write an error message to STDERR (without exiting the script)
-   the `try()` method will emulate a *try/catch* process by calling a sub-command catching its result

Errors are handled by the `die()` method (using the *trap* built-in command).

Exits are handled by the `cleanup()` method (using again the *trap* built-in command). You can add in this method 
any cleanup you want to be done when the script exits.

A special *options* and *arguments* handling is designed to rebuild the input command and follow special treatments
for default options and arguments. To use this, add in your script:

    rearrange_options "$@"
    [ -n "$CMD_REQ" ] && eval set -- "$CMD_REQ";
    common_options "$@"
    common_arguments "$*";

You can **overwrite any method** by re-defining it after having sourced the library:

    source .../bash-utils
    
    error() {
        # your custom error handler
    }

The best practice is to create user methods instead of overwrite native ones and call them:

    source .../bash-utils
    
    user_error() {
        # your custom error handler
    }
    
    [ -f filename ] || user_error 'file not found';


### Colorized output

The library embeds a `e_color()` method you can use to output some colorized contents. It allows you
to construct you content with XML-like tags. For instance:

    CTT="this is a content with <bold>tags</bold> to <red>play with</red> <cyan_bg>output</cyan_bg>"

The lists of available text styles and colors are stored in the `TEXTOPTIONS` and `TEXTCOLORS` environment variables.


### Script's options

Default options handled by the library are:

-   **-q** | **--quiet**: enables the `$QUIET` environment variables ; this should decrease script's output (only errors or
    required output should be returned) ; this options disables the `$VERBOSE` environment variable
-   **-v** | **--verbose**: enables the `$VERBOSE` environment variable ; this should increase script's verbosity (inform
    user about what is happening) ; this options disables the `$QUIET` environment variable
-   **-f** | **--force**: enables the `$FORCE` environment variable ; this should let the user to choose all default behaviors
    in case a choice is required (no prompt running the script)
-   **-x** | **--debug**: enables the `$DEBUG` environment variable ; this should drastically increase script's verbosity
    (verbosity should be one level more than in `$VERBOSE` mode)
-   **--dry-run**: enables the `$DRY_RUN` environment variable ; this should not de sensible stuff but inform user about
    what should be done

The library also handles those informational options:

-   **-V** | **--version** to get the name and version number of the script
-   **-h** | **--help** to get the full help information of script's usage

The output of the informational arguments listed above are constructed using the `CMD_...` environment
variables you may define for each script.

These options are handled by the *getopt* program. You can add your own options by overriding the following variables:

    CMD_OPTS_SHORT='fqvx'
    CMD_OPTS_LONG='debug,dry-run,force,quiet,verbose'

By default, the `common_options()` method will throw en error if an unknown option is met. You can avoid this behavior
by prefixing the `CMD_OPTS_SHORT` by a colon `:`.

For each option added, you MUST define your own treatment for it in a parsing loop:

    CMD_OPTS_SHORT=':fqvxo:'
    CMD_OPTS_LONG='debug,dry-run,force,quiet,verbose,my-option'
    while [ $# -gt 0 ]; do
        case "$1" in
            # do not throw error for common options
            -f | -q | -v | -x | --force | --quiet | --verbose | --debug | --dry-run ) true;;
            # user option
            -o | --my-option )
                OPTARG="$(echo "$2" | cut -d'=' -f2)"
                MYVAR="${OPTARG:-default}"
                shift
                ;;
        esac
        shift
    done

In your script, you can use a flag like:

    $FLAG && ...; # do something when FLAG is ENABLED
    $FLAG || ...; # do something when FLAG is DISABLED

Due to known limitations of the *getopt* program, you should always use an equal sign between 
an option (short or long) and its argument: `-o=arg` or `--option=arg`.


### Technical points

The library uses the following *Bash* options by default:

-   `-e`: exit if a command has a non-zero status
-   `-E`: trap on ERR are inherited by shell functions
-   `-o pipefail`: do not mask pipeline's errors
-   `-u`: throw error on unset variable usage
-   `-T`: trap on DEBUG and RETURN are inherited by shell functions

To make robust scripts, here are some reminders:

-   to use a variable eventually unset: `echo ${VARIABLE:-default}`
-   to make a silent sub-command call: `val=$(sub-command 2>/dev/null)`


## SEE ALSO

Online *bash* scripting guides and tools:

-   the *Bash Guide for Beginners*: <http://tldp.org/LDP/Bash-Beginners-Guide/html/index.html> (recommended) 
-   the *Advanced Bash-Scripting Guide*: <http://tldp.org/LDP/abs/html/index.html> (recommended) 
-   the *Bash Reference Manual*: <http://www.gnu.org/software/bash/manual/html_node/index.html>
-   the *GNU Coding Standards*: <http://www.gnu.org/prep/standards/standards.html>
-   *BATS*, a test suite for Bash scripts: <http://github.com/sstephenson/bats>
-   *ShellCheck*, a Bash validator: <http://www.shellcheck.net/>

bash(1), bash-utils(1), getopt(1)
