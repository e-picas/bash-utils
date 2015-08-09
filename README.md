Utilities for Bash scripting
============================

The `bash-utils.bash` file is a short and simple utilities library for 
[Bash](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29) scripts.
You can use it as a base to quickly build robust shell scripts for UNIX systems 
with options, arguments, error handling and common usage and help strings.
The library is licensed under an [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0).

Installation
------------

To make the library accessible for all users, the best practice is to install it in a global path like `/usr/bin/`:

    ./make.sh install /usr/bin

This way, any user can use in its scripts:

    source /usr/bin/bash-utils.bash

Starter template
----------------

To use the library, just *source* it at the top of your script:

    #!/usr/bin/env bash
    source ~/bin/bash-utils.bash
    
    # write your script here
    
The library embeds a model you can use "as-is":

    bash-utils.bash model ~/bin/name-of-your-script

Usage
-----

For a documentation of the library, please see the [documentation manpage](man/MANPAGE.7.md).

For a complete review of the library's usage, please see the [usage manpage](man/MANPAGE.1.md).
