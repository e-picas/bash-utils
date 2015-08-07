Utilities for Bash scripting
============================

The `bash-utils.bash` file is a short and simple utilities library for [Bash][1] scripts.
You can use it as a base to quickly build robust shell scripts for UNIX systems with options, arguments, error handling
and common usage and help strings.
The library is licensed under a [Creative Commons Attribution][2] license.
A short lexicon is available at the bottom of this file with specific terms used in this documentation and 
the library itself.


How-to
------

### Basic template

To use the library, just *source* it at the top of your script:

    #!/usr/bin/env bash
    source ~/bin/bash-utils.bash
    
    # write your scripts logic here
    # ...
    
    # a script should always return a status
    exit 0

### Library model

The library embeds a model you can use "as-is":

    # 1_ go to the library directory
    cd path/to/bash-utils-clone

    # 2_ copy the model as your target script
    cp shell-model.bash ~/bin/name-of-your-script

    # 3_ render it executable
    chmod a+x ~/bin/name-of-your-script

    # 4_ edit it
    vi ~/bin/name-of-your-script

    # 5_ and use it
    ~/bin/name-of-your-script

The target script in this example is named `name-of-your-script` and stored in user's `bin/` directory. None of these
are mandatory ; you can name your script following your preferences and place it where you want as long as you can
access it easily. The file extension has no incidence upon the script's type (`bash` in our case) as the interpreter
is designed by the [*shebang* directive][5] ; you could name your script with an `.sh`, a `.bash` and even a `.py` 
extension (which would have no real sense here) or let it without extension at all with no difference.

### Installation & access

To make the library accessible for all users, the best practice is to install it in a global path like `/usr/bin/`.
This way, any user can use in its scripts:

    source /usr/bin/bash-utils.bash

To enable "per-user" binaries (let the system look in any `$HOME/bin/` directory when searching scripts), be
sure to add that directory to the `$PATH` environment variable (in your `$HOME/.bashrc` for instance):

    # user binaries path
    [ -d "${HOME}/bin" ] && export PATH="${PATH}:${HOME}/bin";


Library's usage
---------------

### Customize your script

To use this model to build your own command, you must first override informational variables:

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


### Library's methods

The library embeds a short set of methods to facilitate your scripts:

-   the `die()` method will exit with an error message and a back trace, all to STDERR
-   the `error()` method will exit with an error message to STDERR (user friendly)
-   the `warning()` method will write an error message to STDERR (without exiting the script)
-   the `try()` method will emulate a *try/catch* process by calling a sub-command catching its result

Errors are handled by the `die()` method (using the [`trap` built-in command][3]).

Exits are handled by the `cleanup()` method (using again the [`trap` built-in command][3]). You can add in this method 
any cleanup you want to be done when the script exits.

You can use pre-defined colors for your output using the `e_***` methods.

A special *options* and *arguments* handling is designed to rebuild the input command and follow special treatments
for default options and arguments. To use this, add in your script:

    rearrange_options "$@"
    [ -n "$CMD_REQ" ] && eval set -- "$CMD_REQ";
    common_options "$@"
    common_arguments "$*";

You can **overwrite any method** by re-defining it after having sourced the library:

    source .../bash-utils.bash
    
    error() {
        # your custom error handler
    }

The best practice is to create user methods instead of overwrite native ones and call them:

    source .../bash-utils.bash
    
    user_error() {
        # your custom error handler
    }
    
    [ -f filename ] || user_error 'file not found';


### Script's options

Default options handled by the library are:

-   `-q` | `--quiet`: enables the `$QUIET` environment variables ; this should decrease script's output (only errors or
    required output should be returned) ; this options disables the `$VERBOSE` environment variable
-   `-v` | `--verbose`: enables the `$VERBOSE` environment variable ; this should increase script's verbosity (inform
    user about what is happening) ; this options disables the `$QUIET` environment variable
-   `-f` | `--force`: enables the `$FORCE` environment variable ; this should let the user to choose all default behaviors
    in case a choice is required (no prompt running the script)
-   `-x` | `--debug`: enables the `$DEBUG` environment variable ; this should drastically increase script's verbosity
    (verbosity should be one level more than in `$VERBOSE` mode)
-   `--dry-run`: enables the `$DRY_RUN` environment variable ; this should not de sensible stuff but inform user about
    what should be done

These options are handled by the [`getopt` program][4]. You can add your own options by overriding the following variables:

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

Due to known limitations of the [getopt][4] program, you should always use an equal sign between 
an option (short or long) and its argument: `-o=arg` or `--option=arg`.


### Script's arguments

The library handles by default the following arguments:

-   `version` to get the name and version number of the script
-   `about` to get a long information string about the script (license, sources ...)
-   `help` to get the full help information of script's usage
-   `usage` to get the short help information of script's usage (its *synopsis*).

You can define your own arguments by overriding the `common_arguments()` method or build a new loop
over script's arguments:

    case "$1" in
        arg) ... ;;
    esac


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


Useful links
------------

-   the *Advanced Bash-Scripting Guide*: <http://www.tldp.org/LDP/abs/html/> (recommended) 
-   the *Bash Reference Manual* at gnu.org: <http://www.gnu.org/software/bash/manual/html_node/index.html>
-   the list of builtin Bash variables: <http://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html>
-   the Bash Hackers wiki: <http://wiki.bash-hackers.org/>
-   an online Bash validator: <http://www.shellcheck.net/>
-   a test suite for Bash scripts: <http://github.com/sstephenson/bats>


Lexicon
-------

arguments
:   settings passed to the script when calling it ; the arguments are not the same as the options as they are not named
but identified by their position ; i.e. `./script --option argument1 argument2`

built-in
:   internal *Bash* functions to use in scripts ; i.e. `set`, `exec` etc. 

command
:   the text entered by the user on *terminal* when calling a script ; i.e. `./script -o arg`

options
:   various settings passed to the script when calling it ; each option is prefixed by one or more dash `-` and can have
an argument ; by convention, a *short* option is composed by one single letter prefixed by one dash, i.e. `-o`, and a
*long* option is composed by a word prefixed by two dashes, i.e. `--option` ; when an option accepts an argument, it
must be separated from the option name by an equal sign, i.e. `--option=argument` and `-o=argument` ; 
i.e. `./script -o --option-with-no-arg --option-with-arg=argument_value`

program
:   external commands present in the system and used in shell scripts ; i.e. `sed`, `tar`, `grep` etc.

script
:   name of the script you are running ; i.e. `my-script.sh`

stderr
:   *error output* of the command-line ; it is hosted by file descriptor 2

stdin
:   *user input* of the command-line ; it is hosted by file descriptor 0

stdout
:   *standard output* of the command-line ; it is hosted by file descriptor 1

terminal
:   text tool to call scripts and commands to the system and visualize the result


[1]: https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29
[2]: http://creativecommons.org/licenses/by/4.0/legalcode
[3]: http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_12_02.html
[4]: http://man7.org/linux/man-pages/man1/getopt.1.html
[5]: https://en.wikipedia.org/wiki/Shebang_%28Unix%29
