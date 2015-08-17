Bash-Utils - Utilities for Bash scripting
=========================================

The `Bash-Utils` project is a short and simple utilities library for 
[Bash](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29) scripts.
You can use it as a basis to quickly build robust shell scripts for UNIX systems 
with options, arguments, error handling and common usage and help strings.
The library is licensed under an [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0).
The library is fully "unit-tested" using [BATS](http://github.com/sstephenson/bats) to keep it as robust as possible.

Features
--------

The library defines an enhanced *Bash* environment ready to write scripts with options, errors etc. It also embeds
and proposes a set of *modules* you can use as-is ; see the [`libexec/bash-utils-modules/`](libexec/bash-utils-modules/)
directory.

Key features:

-   handling of some common options with associated behaviors: *verbose*, *quiet*, *force*, *help*, *version* ...
-   handling of errors with information about what throws it or where it was thrown
-   some debugging information (enabled by default) with a *stack trace* in case of process or sub-processes errors
-   generation of an automatic *synopsis* of the script based on declared available options (short and longs, with or 
    without arguments)
-   generation of help and version strings based on declared variables
-   a set of commonly used functions about *strings*, *arrays* and *file system*

Installation
------------

To make the library accessible for all users, the best practice is to install it in a global path like `/usr/local/bin/`:

    ./make.sh install /usr/local/bin

This way, any user can use in its scripts:

    source bash-utils

Starter template
----------------

To use the library, the best practice is to use it as your script's *interpreter* defining it as your 
[*shebang*](https://en.wikipedia.org/wiki/Shebang_%28Unix%29): 

    #!/usr/bin/env bash-utils
    
    # write your script here
    # ...
    
If you prefer use a classic *shebang*, you just have to load the library by *sourcing* it:

    #!/usr/bin/env bash
    source /usr/local/bin/bash-utils
    
    # write your script here
    # ...

The library embeds a model you can use as a more complex starter template:

    bash-utils model ~/bin/name-of-your-script

Usage
-----

For a documentation of the library, please see the [documentation manpage](man/MANPAGE.7.md).

For a complete review of the library's usage, please see the [usage manpage](man/MANPAGE.1.md).
