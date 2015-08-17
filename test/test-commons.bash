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
TESTBASHUTILS_ROOT_DIR="$(pwd)"
TESTBASHUTILS_TEST_DIR="${TESTBASHUTILS_ROOT_DIR}/test/"
TESTBASHUTILS_TEST_TMPSCRIPT="${TESTBASHUTILS_ROOT_DIR}/test/tmp-test-script.sh"
TESTBASHUTILS_TESTSCRIPT="${TESTBASHUTILS_ROOT_DIR}/test/bash-utils-sample.sh"
TESTBASHUTILS_BIN="${TESTBASHUTILS_ROOT_DIR}/bin/bash-utils"
TESTBASHUTILS_CORE="${TESTBASHUTILS_ROOT_DIR}/libexec/bash-utils-core"
TESTBASHUTILS_MODEL="${TESTBASHUTILS_ROOT_DIR}/libexec/bash-utils-model"

bats_definition=$(declare -f run)
source "$TESTBASHUTILS_CORE" || { echo "> bash-utils-core not found!" >&2; exit 1; };
set +o posix
set +o nounset
trap - 1 2 3 15 ERR
trap - EXIT
eval "$bats_definition"
