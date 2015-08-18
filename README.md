Bash-Utils - Utilities for Bash scripting
=========================================

The `Bash-Utils` command is a small library of utilities to quickly build robust and complete
[Bash](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29) scripts.
It proposes a set of useful functions and environment variables in an enhanced environment with some system options enabled by default,
to let you build a script with user options and arguments, an automatic generation of some informational output about 
the script's usage (version, help etc), a special handling of errors, stack trace and debugging, and some more features.
The library also embeds and proposes a set of *modules* you can use as-is ; 
see the [`libexec/bash-utils-modules/`](libexec/bash-utils-modules/) directory.

The library is licensed under an [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0) and
is fully "unit-tested" using [BATS](http://github.com/sstephenson/bats) to keep it as robust as possible.


Key features
------------

-   handling of some common options with associated behaviors: *verbose*, *quiet*, *force*, *help*, *version* ...
-   handling of errors with information about what throws it or where it was thrown
-   some debugging information (enabled by default) with a *stack trace* in case of process or sub-processes errors
-   generation of an automatic *synopsis* of the script based on declared available options (shorts and longs, with or 
    without arguments)
-   generation of some help and version strings for the script based on declared variables
-   a set of commonly used functions about *booleans*, *integers*, *strings*, *arrays* and *file system*


Installation
------------

To make the library accessible for all users, the best practice is to install it in a global path like `/usr/local/bin/`:

    ./make.sh install /usr/local/bin

This way, any user can use it in its scripts by *sourcing* it:

    source bash-utils

For a full download and installation from the command line, run:

    wget --no-check-certificate https://gitlab.com/piwi/bash-utils/archive/master.tar.gz
    tar -xvf master.tar.gz
    cd bash-utils*
    ./make.sh install /usr/local/bin

You can use the `make.sh` script to clean-up an installed library or update it ; to get a full usage, run `./make.sh`.


Starter template
----------------

To use the library, the best practice is to use it as your script's *interpreter* defining it as your 
[*shebang*](https://en.wikipedia.org/wiki/Shebang_%28Unix%29): 

    #!/usr/bin/env bash-utils
    
    # write your script here
    # ...
    
If you prefer use a classic *shebang*, you just have to load the library by *sourcing* it:

    #!/usr/bin/env bash
    source bash-utils
    
    # write your script here
    # ...

The library embeds a *model* module you can use as a more complex starter template:

    bash-utils model bash-utils ~/bin/name-of-your-script


Usage
-----

For a documentation of the library, please see the [documentation manpage](man/MANPAGE.7.md).

For a complete review of the library's usage, please see the [usage manpage](man/MANPAGE.1.md).
