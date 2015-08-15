#!/usr/bin/env bats
#
# <http://gitlab.com/piwi/bash-utils>
# Copyright (c) 2015 Pierre Cassat & contributors
# License Apache 2.0 - This program comes with ABSOLUTELY NO WARRANTY.
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code or see <http://www.apache.org/licenses/LICENSE-2.0>.
#
# Common library for BATS tests
#

TEST_DEBUG=true
ROOT_DIR="$(pwd)"
TEST_DIR="${ROOT_DIR}/test/"
BASH_UTILS="${ROOT_DIR}/bin/bash-utils"
BASH_UTILS_MODEL="${ROOT_DIR}/libexec/bash-utils-model.bash"

load_bash_utils()
{
    source "$BASH_UTILS" || { echo "> bash-utils not found!" >&2; exit 1; };
}

