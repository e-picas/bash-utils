#!/usr/bin/env bats

TEST_DEBUG=true
ROOT_DIR="$(pwd)"
TEST_DIR="${ROOT_DIR}/test/"
BASH_UTILS="${ROOT_DIR}/bin/bash-utils.bash"
BASH_UTILS_MODEL="${ROOT_DIR}/bin/bash-utils-model.bash"

setup()
{
    source "$BASH_UTILS" || { echo "> bash-utils not found!" >&2; exit 1; };
}

teardown()
{
    : # nothing
}

#@test "test error status of BATS" {
#    [ true = false ]
#}

@test "internal BASH_UTILS & BASH_UTILS_VERSION variables" {
    [ -n "$BASH_UTILS" ]
    [ -n "$BASH_UTILS_VERSION" ]
}

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
