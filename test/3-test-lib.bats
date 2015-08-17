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

# arrays
TESTARRAY=( 'one' 'two' 'four' )

@test "[lib arrays-1] in_array" {
    # with full array and valid item
    run in_array two "${TESTARRAY[@]}"
    $TEST_DEBUG && {
        echo "running: in_array two '${TESTARRAY[@]}'"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    # with referenced array and valid item
    run in_array two TESTARRAY[@]
    $TEST_DEBUG && {
        echo "running: in_array two TESTARRAY[@]"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    # with full array and invalid item
    run in_array three "${TESTARRAY[@]}"
    $TEST_DEBUG && {
        echo "running: in_array three '${TESTARRAY[@]}'"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 1 ]
    # with referenced array and invalid item
    run in_array three TESTARRAY[@]
    $TEST_DEBUG && {
        echo "running: in_array three TESTARRAY[@]"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 1 ]
}

@test "[lib arrays-2] array_search" {
    # with full array and valid item
    run array_search two "${TESTARRAY[@]}"
    [ "$status" -eq 0 ]
    [ "$output" -eq 1 ]
    # with referenced array and valid item
    run array_search two TESTARRAY[@]
    [ "$status" -eq 0 ]
    [ "$output" -eq 1 ]
    # with full array and invalid item
    run array_search three "${TESTARRAY[@]}"
    [ "$status" -eq 1 ]
    [ -z "$output" ]
    # with referenced array and invalid item
    run array_search three TESTARRAY[@]
    [ "$status" -eq 1 ]
    [ -z "$output" ]
}

# file-system

@test "[lib file-system-1] resolve_link" {
    # no arg error
    run resolve_link
    $TEST_DEBUG && {
        echo "running: resolve_link"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
    # classic
    binpath="$(pwd)/test/bash-utils"
    run resolve_link "$binpath"
    $TEST_DEBUG && {
        echo "running: resolve_link $binpath"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "$output" = "../bin/bash-utils" ]
}

@test "[lib file-system-2] real_path_dirname" {
    # no arg error
    run real_path_dirname
    $TEST_DEBUG && {
        echo "running: real_path_dirname"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
    # classic
    binpath="$(pwd)/test/bash-utils"
    run abs_dirname "$binpath"
    $TEST_DEBUG && {
        echo "running: real_path_dirname $binpath"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "$output" = "$(pwd)/libexec" ]
}

@test "[lib file-system-3] strip_trailing_slash" {
    # no arg error
    run strip_trailing_slash
    $TEST_DEBUG && {
        echo "running: strip_trailing_slash"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
    # classic
    binpath="$(pwd)/"
    run strip_trailing_slash "$binpath"
    $TEST_DEBUG && {
        echo "running: strip_trailing_slash $binpath"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "$output" = "$(pwd)" ]
}

@test "[lib file-system-4] get_line_number_matching" {
    # no arg error
    run get_line_number_matching
    $TEST_DEBUG && {
        echo "running: get_line_number_matching"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
    # path error
    run get_line_number_matching "$(pwd)/abcdefg" "$mask"
    $TEST_DEBUG && {
        echo "running: get_line_number_matching $(pwd)/abcdefg $mask"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
    # classic / line exists
    binpath="$TESTBASHUTILS_BIN"
    mask='/usr/bin/env'
    run get_line_number_matching "$binpath" "$mask"
    $TEST_DEBUG && {
        echo "running: get_line_number_matching $binpath $mask"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "$output" = "1" ]
    # classic / line not exists
    mask='/usr/bin/enva'
    run get_line_number_matching "$binpath" "$mask"
    $TEST_DEBUG && {
        echo "running: get_line_number_matching $binpath $mask"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "[lib file-system-5] log" {
    # var exists
    $TEST_DEBUG && {
        echo "running: logfile is $CMD_LOGFILE"
    } >&1
    [ -n "$CMD_LOGFILE" ]
    # no arg error
    run log
    $TEST_DEBUG && {
        echo "running: log"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    # args
    run log 'log string'
    $TEST_DEBUG && {
        echo "running: log 'log string'"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    tail -n1 "$CMD_LOGFILE" | grep 'log string$'
}

# strings

@test "[lib strings-1] string_to_upper" {
    # no arg error
    run string_to_upper
    $TEST_DEBUG && {
        echo "running: string_to_upper"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
    # classic
    run string_to_upper "abcdefgHIJkLM"
    $TEST_DEBUG && {
        echo "running: string_to_upper abcdefgHIJkLM"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "$output" = 'ABCDEFGHIJKLM' ]
}

@test "[lib strings-2] string_to_lower" {
    # no arg error
    run string_to_lower
    $TEST_DEBUG && {
        echo "running: string_to_lower"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
    # classic
    run string_to_lower "abcdefgHIJkLM"
    $TEST_DEBUG && {
        echo "running: string_to_lower abcdefgHIJkLM"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "$output" = 'abcdefghijklm' ]
}
