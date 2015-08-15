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
    load_bash_utils
}

teardown()
{
    : # nothing
}

@test "internal BASH_UTILS & BASH_UTILS_VERSION variables" {
    [ -n "$BASH_UTILS" ]
    [ -n "$BASH_UTILS_VERSION" ]
}

@test "resolve_link" {
    # no arg error
    run resolve_link
    $OST_DEBUG && {
        echo "running: resolve_link"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
    # classic
    binpath="$(pwd)/test/bash-utils"
    run resolve_link "$binpath"
    $OST_DEBUG && {
        echo "running: resolve_link $binpath"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "$output" = "../bin/bash-utils.bash" ]
}

@test "real_path_dirname" {
    # no arg error
    run real_path_dirname
    $OST_DEBUG && {
        echo "running: real_path_dirname"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
    # classic
    binpath="$(pwd)/test/bash-utils"
    run abs_dirname "$binpath"
    $OST_DEBUG && {
        echo "running: real_path_dirname $binpath"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "$output" = "$(pwd)/bin" ]
}

@test "strip_trailing_slash" {
    # no arg error
    run strip_trailing_slash
    $OST_DEBUG && {
        echo "running: strip_trailing_slash"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
    # classic
    binpath="$(pwd)/"
    run strip_trailing_slash "$binpath"
    $OST_DEBUG && {
        echo "running: strip_trailing_slash $binpath"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "$output" = "$(pwd)" ]
}

@test "get_line_number_matching" {
    # no arg error
    run get_line_number_matching
    $OST_DEBUG && {
        echo "running: get_line_number_matching"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
    # path error
    run get_line_number_matching "$(pwd)/abcdefg" "$mask"
    $OST_DEBUG && {
        echo "running: get_line_number_matching $(pwd)/abcdefg $mask"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
    # classic / line exists
    binpath="$(pwd)/bin/bash-utils.bash"
    mask='/usr/bin/env'
    run get_line_number_matching "$binpath" "$mask"
    $OST_DEBUG && {
        echo "running: get_line_number_matching $binpath $mask"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "$output" = "1" ]
    # classic / line not exists
    mask='/usr/bin/enva'
    run get_line_number_matching "$binpath" "$mask"
    $OST_DEBUG && {
        echo "running: get_line_number_matching $binpath $mask"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "string_to_upper" {
    # no arg error
    run str_to_upper
    $OST_DEBUG && {
        echo "running: string_to_upper"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
    # classic
    run string_to_upper "abcdefgHIJkLM"
    $OST_DEBUG && {
        echo "running: string_to_upper abcdefgHIJkLM"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "$output" = 'ABCDEFGHIJKLM' ]
}

@test "string_to_lower" {
    # no arg error
    run str_to_lower
    $OST_DEBUG && {
        echo "running: string_to_lower"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
    # classic
    run str_to_lower "abcdefgHIJkLM"
    $OST_DEBUG && {
        echo "running: string_to_lower abcdefgHIJkLM"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    [ "$output" = 'abcdefghijklm' ]
}

@test "function_exists" {
    # classic / func exist
    run function_exists function_exists
    $OST_DEBUG && {
        echo "running: function_exists function_exists"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -eq 0 ]
    # classic / func not exist
    run function_exists abcdefghijklmnopqrstuvw
    $OST_DEBUG && {
        echo "running: function_exists abcdefghijklmnopqrstuvw"
        echo "output: $output"
        echo "status: $status"
    } >&1
    [ "$status" -ne 0 ]
}
