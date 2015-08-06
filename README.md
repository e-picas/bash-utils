Shell Script Model
==================

The `shell-model.bash` file is a "model" for [Bash][1] scripts.
You can use it as a base to build quickly robust shell scripts for UNIX systems with options and arguments.
The model is licensed under a [Creative Commons Attribution][2] license.


How-to
------

To use the model, just follow these steps:

    # 1_ go to the model directory
    cd path/to/shell-model-clone

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


Customize the model
-------------------

To use this model to build your own command, you must first override informational variables:

    declare -xr CMD_NAME=...
    declare -xr CMD_VERSION=...
    declare -xr CMD_COPYRIGHT=...
    declare -xr CMD_LICENSE=...
    declare -xr CMD_SOURCES=...
    declare -xr CMD_DESCRIPTION=...
    declare -xr CMD_SYNOPSIS=...
    declare -xr CMD_HELP=...

Then you can customize script's options (see below) to fit your needs and write your script's logic in the last
part of the model.


Script's library
----------------

The model embeds a short library of methods to facilitate your scripts:

-   the `die()` method will exit with an error message and a back trace, all to STDERR
-   the `error()` method will exit with an error message to STDERR (user friendly)
-   the `warning()` method will write an error message to STDERR (without exiting the script)
-   the `try()` method will emulate a *try/catch* process by calling a sub-command catching its result

Errors are handled by the `die()` method (using the [`trap` built-in command][3]).

Exits are handled by the `cleanup()` method (using again the [`trap` built-in command][3]). You can add in this method 
any cleanup you want to be done when the script exits.


Script's options
----------------

Default options handled by the model are:

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

    declare -xr CMD_OPTS_SHORT='fqvx'
    declare -xr CMD_OPTS_LONG='debug,dry-run,force,quiet,verbose'

For each option added, you MUST define a treatment for it on the parsing block:

    while [ $# -gt 0 ]; do
        case "$1" in
            ...
            -o | --my-option )  ... ;;
            ...
        esac
        shift
    done

In your script, you can use a flag like:

    $FLAG && ...; # do something when FLAG is ENABLED
    $FLAG || ...; # do something when FLAG is DISABLED

Due to known limitations of the [getopt][4] program, you should always use an equal sign between 
an option (short or long) and its argument: `-o=arg` or `--option=arg`.


Script's arguments
------------------

The model handles by default the following arguments:

-   `version` to get the name and version number of the script
-   `about` to get a long information string about the script (license, sources ...)
-   `help` to get the full help information of script's usage
-   `usage` to get the short help information of script's usage (its *synopsis*).

You can define your own arguments by overriding the `common_options()` method or build a new loop
over script's arguments:

    case "$1" in
        arg) ... ;;
    esac


Technical points
----------------

The model uses the following *Bash* options by default:

-   `-e`: exit if a command has a non-zero status
-   `-E`: trap on ERR are inherited by shell functions
-   `-o pipefail`: do not mask pipeline's errors
-   `-u`: throw error on unset variable usage
-   `-T`: trap on DEBUG and RETURN are inherited by shell functions

To make robust scripts, here are some reminders:

-   to use a variable eventually unset: `echo ${VARIABLE:-default}`
-   to make a silent sub-command call: `val=$(sub-command 2>/dev/null)`

To enable "per-user" binaries (let the system look in any `$HOME/bin/` directory when searching scripts), be
sure to add that directory to the `$PATH` environment variable (in your `$HOME/.bashrc` for instance):

    # user binaries path
    [ -d "${HOME}/bin" ] && export PATH="${PATH}:${HOME}/bin";


Useful links
------------

-   the *Advanced Bash-Scripting Guide*: <http://www.tldp.org/LDP/abs/html/> (recommended) 
-   the *Bash Reference Manual* at gnu.org: <http://www.gnu.org/software/bash/manual/html_node/index.html>
-   the list of builtin Bash variables: <http://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html>
-   the Bash Hackers wiki: <http://wiki.bash-hackers.org/>
-   an online Bash validator: <http://www.shellcheck.net/>
-   a test suite for Bash scripts: <http://github.com/sstephenson/bats>

[1]: https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29
[2]: http://creativecommons.org/licenses/by/4.0/legalcode
[3]: http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_12_02.html
[4]: http://man7.org/linux/man-pages/man1/getopt.1.html
[5]: https://en.wikipedia.org/wiki/Shebang_%28Unix%29
