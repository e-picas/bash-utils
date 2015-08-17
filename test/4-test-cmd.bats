#!/usr/bin/env bats
#
# <http://gitlab.com/piwi/bash-utils>
# Copyright (c) 2015 Pierre Cassat & contributors
# License Apache 2.0 - This program comes with ABSOLUTELY NO WARRANTY.
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code or see <http://www.apache.org/licenses/LICENSE-2.0>.
#
#
#@test "" {
#    run ...
#    $TEST_DEBUG && {
#        echo "running: ..."
#        echo "output: $output"
#        echo "status: $status"
#    } >&1
#    [ "$status" -eq 0 ]
#    [ -n "$output" ]
#}
#

load test-commons

setup()
{
    : # nothing
}

teardown()
{
    [ -f "$TESTBASHUTILS_TEST_TMPSCRIPT" ] && rm -f "$TESTBASHUTILS_TEST_TMPSCRIPT" || true;
}

@test "[cmd 1] no argument|usage: usage string" {
    # no arg
    run "$TESTBASHUTILS_BIN"
    $TEST_DEBUG && {
        echo "running: $TESTBASHUTILS_BIN"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 1 ]
    noargoutput="$output"
    echo "$output" | grep '^usage:'
    # usage
    run "$TESTBASHUTILS_BIN" usage
    $TEST_DEBUG && {
        echo "running: $TESTBASHUTILS_BIN usage"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    echo "$output" | grep '^usage:'
    [ "$output" = "$noargoutput" ]
}

@test "[cmd 2] --help|-h|help: help string (multi-lines)" {
    # --help
    run "$TESTBASHUTILS_BIN" --help
    $TEST_DEBUG && {
        echo "running: $TESTBASHUTILS_BIN --help"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -gt 1 ]
    helpopt="$output"
    # -h
    run "$TESTBASHUTILS_BIN" -h
    $TEST_DEBUG && {
        echo "running: $TESTBASHUTILS_BIN -h"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -gt 1 ]
    hopt="$output"
    [ "$helpopt" = "$hopt" ]
    # help
    run "$TESTBASHUTILS_BIN" help
    $TEST_DEBUG && {
        echo "running: $TESTBASHUTILS_BIN help"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -gt 1 ]
    [ "$output" = "$helpopt" ]
    [ "$output" = "$hopt" ]
}

@test "[cmd 3] --version|-V|about: version string (multi-lines)" {
    # --version
    run "$TESTBASHUTILS_BIN" --version
    $TEST_DEBUG && {
        echo "running: $TESTBASHUTILS_BIN --version"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -gt 1 ]
    versionopt="$output"
    # -V
    run "$TESTBASHUTILS_BIN" -V
    $TEST_DEBUG && {
        echo "running: $TESTBASHUTILS_BIN -V"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -gt 1 ]
    Vopt="$output"
    [ "$versionopt" = "$Vopt" ]
    # about
    run "$TESTBASHUTILS_BIN" about
    $TEST_DEBUG && {
        echo "running: $TESTBASHUTILS_BIN about"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -gt 1 ]
    [ "$output" = "$versionopt" ]
    [ "$output" = "$Vopt" ]
}

@test "[cmd 4] --version --quiet|-Vq|version: version string (single line)" {
    # -Vq
    run "$TESTBASHUTILS_BIN" -Vq
    $TEST_DEBUG && {
        echo "running: $TESTBASHUTILS_BIN -Vq"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    quietopt="$output"
    [ "${#lines[@]}" -eq 1 ]
    # version
    run "$TESTBASHUTILS_BIN" version
    $TEST_DEBUG && {
        echo "running: $TESTBASHUTILS_BIN version"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    [ "$output" = "$quietopt" ]
}

@test "[cmd 5] model" {
    # model
    run "$TESTBASHUTILS_BIN" model
    $TEST_DEBUG && {
        echo "running: $TESTBASHUTILS_BIN model"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "$output" = "$(cat "$TESTBASHUTILS_MODEL")" ]
    # model <filename>
    run "$TESTBASHUTILS_BIN" model "$TESTBASHUTILS_TEST_TMPSCRIPT"
    $TEST_DEBUG && {
        echo "running: $TESTBASHUTILS_BIN model $TESTBASHUTILS_TEST_TMPSCRIPT"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ -f "$TESTBASHUTILS_TEST_TMPSCRIPT" ]
    [ "$(cat "$TESTBASHUTILS_TEST_TMPSCRIPT")" = "$(cat "$TESTBASHUTILS_MODEL")" ]
}

@test "[cmd 6] exec" {
    # --exec ...
    run "$TESTBASHUTILS_BIN" --exec='string_to_upper "test"'
    $TEST_DEBUG && {
        echo "running: $TESTBASHUTILS_BIN --exec='string_to_upper \"test\"'"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "$output" = 'TEST' ]
    # -e ...
    run "$TESTBASHUTILS_BIN" -e='string_to_upper "test"'
    $TEST_DEBUG && {
        echo "running: $TESTBASHUTILS_BIN -e='string_to_upper \"test\"'"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "$output" = 'TEST' ]
    # echo "..." | bash-utils --exec
    run echo 'string_to_upper "test"' | "$TESTBASHUTILS_BIN" --exec
    $TEST_DEBUG && {
        echo "running: echo 'string_to_upper \"test\"' | $TESTBASHUTILS_BIN --exec"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "$output" = 'TEST' ]
    # echo "..." | bash-utils -e
    run echo 'string_to_upper "test"' | "$TESTBASHUTILS_BIN" -e
    $TEST_DEBUG && {
        echo "running: echo 'string_to_upper \"test\"' | $TESTBASHUTILS_BIN -e"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "$output" = 'TEST' ]
    # --exec=filename
    run "$TESTBASHUTILS_BIN" --exec="$TESTBASHUTILS_TESTSCRIPT"
    $TEST_DEBUG && {
        echo "running: $TESTBASHUTILS_BIN --exec=$TESTBASHUTILS_TESTSCRIPT"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "$output" = 'TEST' ]
}
