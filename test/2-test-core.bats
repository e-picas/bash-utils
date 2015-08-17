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
    : # nothing
}

@test "[core 1] die" {
    # no arg error
    run die
    $TEST_DEBUG && {
        echo "running: die"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
    [ "$status" -eq 1 ]
    [ -n "$output" ]
    # false arg error
    run die 'test string' 0
    $TEST_DEBUG && {
        echo "running: die 'test string' 0"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
    [ "$status" -eq 1 ]
    [ -n "$output" ]
}

@test "[core 2] stack_trace" {
    run stack_trace
    $TEST_DEBUG && {
        echo "running: stack_trace"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    [ "${#lines[@]}" -gt 1 ]
}

@test "[core 3] error" {
    # no arg error
    run error
    $TEST_DEBUG && {
        echo "running: error"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
    [ "$status" -eq 1 ]
    [ -n "$output" ]
    # args
    run error 'error string'
    $TEST_DEBUG && {
        echo "running: error 'error string'"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
    [ "$status" -eq 1 ]
    [ -n "$output" ]
    # args
    run error 'error string' 23
    $TEST_DEBUG && {
        echo "running: error 'error string' 23"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
    [ "$status" -eq 23 ]
    [ -n "$output" ]
}

@test "[core 4] warning" {
    # no arg error
    run warning
    $TEST_DEBUG && {
        echo "running: warning"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    # args
    run warning 'error string'
    $TEST_DEBUG && {
        echo "running: warning 'error string'"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}

@test "[core 5] function_exists" {
    # classic / func exist
    run function_exists function_exists
    $TEST_DEBUG && {
        echo "running: function_exists function_exists"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    # classic / func not exist
    run function_exists abcdefghijklmnopqrstuvw
    $TEST_DEBUG && {
        echo "running: function_exists abcdefghijklmnopqrstuvw"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
}

