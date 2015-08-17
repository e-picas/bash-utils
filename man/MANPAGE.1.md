Man:        Bash-Utils Manual
Man-name:   bash-utils
Author:     Pierre Cassat
Section:    1
Date: 2015-08-14
Version: 0.0.1@dev


## NAME

Bash-Utils - A short *bash* library for better scripting.

## SYNOPSIS

Usage of the library in a script:

    source bash-utils || { echo "> bash-utils not found!" >&2; exit 1; };

Usage of the library as a command:

**bash-utils** [**-fhqvVx**]
    [**--debug**|**--dry-run**|**--force**|**--help**|**--quiet**|**--verbose**|**--version**]
    [**-e**|**--exec**[=*arg*]] <arguments> --

## DESCRIPTION

The *Bash-Utils* shell script is a short library of utilities to use to quickly build robust *Bash* scripts.
It proposes a set of useful functions and pre-defined environment variables to let you build a script with
options and arguments, generate some informational output about the script's usage, handle errors and more
features (see bash-utils(7) for a full documentation). It is organized in a *core* and some *modules*.

## OPTIONS

### Scripts using the library

The following options are supported by default for any script using the library:

*-dry-run*
:   Process a dry-run. 

*-f*, *--force*
:   Force some commands to not prompt confirmation. 

*-h*, *--help*
:   See the help information about the script.

*-q*, *--quiet*
:   Decrease script's verbosity. 

*-v*, *--verbose*
:   Increase script's verbosity. 

*-V*, *--version*
:   See script's version and copyright information ; use option `quiet` to get version number only.

*-x*, *--debug*
:   See debug info.


### Using the library as a command

The following additional options are available when you call the library itself:

*-e*, *--exec* [**=<arg>**]
:   Execute the argument in the library's environment ; without argument, any piped
content will be evaluated:

        bash-utils --exec='e_color "<bold>test</bold>"'
        echo 'e_color "<bold>test</bold>"' | bash-utils --exec

The following additional arguments are available when you call the library itself:

*model* [**<file_path>**]
:   See the 'bash-utils-model.bash' model content or copy it in 'file_path'.


## EXAMPLES

Have a look at the `bash-utils-model` script for a full base template of a script
using the library. A starter template is available in bash-utils(7).

To copy the model as a base for your own scripts, you may use the `model` argument:

    bash-utils model /path/to/script


## LICENSE

Copyright (c) 2015, Pierre Cassat & contributors

Licensed under the Apache Software Foundation license, Version 2.0;
you may not use this file except in compliance with the License.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

For the full copyright and license information, please view the LICENSE
file that was distributed with this source code or see 
<http://www.apache.org/licenses/LICENSE-2.0>.

For documentation, sources & updates, see <http://gitlab.com/piwi/bash-utils.git>. 

## BUGS

To transmit bugs, see <http://gitlab.com/piwi/bash-utils/issues>.

## AUTHOR

**Bash-Utils** is created and maintained by Pierre Cassat (piwi - <http://e-piwi.fr/>)
& contributors.

## SEE ALSO

bash(1), bash-utils(7)
