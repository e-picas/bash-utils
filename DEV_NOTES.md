

As a reminder, a common shell script's usage is:

    path/to/script [-o | --options (=argument)] [--] [<parameter> ...]

Usage
-----

To use the library, you just have to load its environment by *sourcing* it:

    #!/usr/bin/env bash
    source ~/bin/bash-utils.bash
    
    # write your script here

You can also use it as your script's *interpreter* defining it in your [*hash bang* (*shebang*)](https://en.wikipedia.org/wiki/Shebang_(Unix)):

    #!/usr/bin/env bash-utils

    # write your script here

Common options
--------------

Following the GNU coding standards, common options proposed by *Bash Utils* are:

-v | --verbose
-q | --quiet
-V | --version
-h | --help
-f | --force
-x | --debug
--dry-run

Only two of them are "informational" and exit the process:

-   'help' will show the help string of the command
-   'version' will show its version number and copyright information ; use the 'quiet' option to have version number only

Create a *Bash-Utils*' module
-----------------------------

A module is a "classic" *Bash* script loaded in *Bash-Utils* environment. The best practice is to use the following
[*hash bang* (*shebang*)](https://en.wikipedia.org/wiki/Shebang_(Unix)):

    #!/usr/bin/env bash-utils

This way, the library will load its environment all alone before you script's execution.

Useful links
------------

-   the *Bash Guide for Beginners*: <http://tldp.org/LDP/Bash-Beginners-Guide/html/index.html> (recommended) 
-   the *Advanced Bash-Scripting Guide*: <http://tldp.org/LDP/abs/html/index.html> (recommended) 
-   the *Bash Reference Manual*: <http://www.gnu.org/software/bash/manual/html_node/index.html>
-   the *GNU Coding Standards*: <http://www.gnu.org/prep/standards/standards.html>
-   *BATS*, a test suite for Bash scripts: <http://github.com/sstephenson/bats>
-   *ShellCheck*, an online Bash validator: <http://www.shellcheck.net/>
