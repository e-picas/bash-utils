#!/usr/bin/env bash
#
# Sample usage of the 'bash-utils' library
#
set -eETu
set -o pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../bin/bash-utils" || { echo "> bash-utils not found!" >&2; exit 1; };
rearrange_options "$@"
eval set -- "$CMD_REQ";
common_options "$@"
$DEBUG && debug;
use print-table
use print-list


######################################################
echo '############ DEMO OF print-table:'
echo

# declare the table array
declare -a TABLE_ITEMS=()

# declare the table padders (characters used to fill balcnk spaces)
# item [0] is padder for separation lines cells
# item [1] is padder for contents lines cells
declare -a TABLE_PADDERS=()
TABLE_PADDERS[0]="$(printf '%0.1s' "#"{1..120})"
TABLE_PADDERS[1]="$(printf '%0.1s' "_"{1..120})"

# declare the table paddings (number of space(s) from line to cell's contents)
# item [0] is padding for separation lines cells
# item [1] is padding for contents lines cells
declare -a TABLE_PADDINGS=()
TABLE_PADDINGS[0]=2
TABLE_PADDINGS[1]=3

# declare the table separators (characters used to separate cells)
# item [0] is the separator for separation lines
# item [1] is the separator for contents lines
declare -a TABLE_SEPARATORS=()
TABLE_SEPARATORS[0]='/'
TABLE_SEPARATORS[1]='-'

# first item are headers
declare -a TABLE_HEADERS=( "name" "value" "comment" )
#TABLE_ITEMS[0]=TABLE_HEADERS[@]

# add one line as array, declared itself as another array
declare -a SUB_0=("my name1" "my value1" "my comment1")
TABLE_ITEMS[${#TABLE_ITEMS[@]}]=SUB_0[@]

# add one line as array, declared itself as another array
declare -a SUB_1=("my name2" "lorem ipsum dolor sit amet")
TABLE_ITEMS[${#TABLE_ITEMS[@]}]=SUB_1[@]

echo '###########################'
echo '> full custom:'
echo
print_table TABLE_ITEMS[@] TABLE_HEADERS[@] TABLE_PADDINGS[@] TABLE_PADDERS[@] TABLE_SEPARATORS[@]

echo
echo '###########################'
echo '> with default separators:'
echo
print_table TABLE_ITEMS[@] TABLE_HEADERS[@] TABLE_PADDINGS[@] TABLE_PADDERS[@]

echo
echo '###########################'
echo '> with default separators & padders:'
echo
print_table TABLE_ITEMS[@] TABLE_HEADERS[@] TABLE_PADDINGS[@]

echo
echo '###########################'
echo '> with default separators & padders & paddings:'
echo
print_table TABLE_ITEMS[@] TABLE_HEADERS[@]

echo
echo '###########################'
echo '> with default separators & padders & paddings & no header:'
echo
print_table TABLE_ITEMS[@]

echo
echo '###########################'
echo '> with no table (empty):'
echo
print_table

echo '############ DEMO OF print-list:'
echo

# declare the list arrays
declare -a LIST_HEADERS=('name' 'value')
declare -a LIST_NAMES=()
declare -a LIST_VALUES=()

# add name/value items
LIST_NAMES[${#LIST_NAMES[@]}]='my name 1'
LIST_VALUES[${#LIST_VALUES[@]}]='my value 1'

LIST_NAMES[${#LIST_NAMES[@]}]='my longer name 2'
LIST_VALUES[${#LIST_VALUES[@]}]='my value 2: lorem ipsum dolor site amet'

# print list

# declare the table padders (characters used to fill balcnk spaces)
# item [0] is padder for separation lines cells
# item [1] is padder for contents lines cells
declare -a LIST_PADDERS=()
LIST_PADDERS[0]="$(printf '%0.1s' "#"{1..120})"
LIST_PADDERS[1]="$(printf '%0.1s' "_"{1..120})"

# declare the table paddings (number of space(s) from line to cell's contents)
# item [0] is padding for separation lines cells
# item [1] is padding for contents lines cells
declare -a LIST_PADDINGS=()
LIST_PADDINGS[0]=2
LIST_PADDINGS[1]=3

# declare the table separators (characters used to separate cells)
# item [0] is the separator for separation lines
# item [1] is the separator for contents lines
declare -a LIST_SEPARATORS=()
LIST_SEPARATORS[0]='/'
LIST_SEPARATORS[1]='-'

echo '###########################'
echo '> full custom:'
echo
print_list LIST_NAMES[@] LIST_VALUES[@] LIST_HEADERS[@] LIST_PADDINGS[@] LIST_PADDERS[@] LIST_SEPARATORS[@]

echo
echo '###########################'
echo '> with default separators:'
echo
print_list LIST_NAMES[@] LIST_VALUES[@] LIST_HEADERS[@] LIST_PADDINGS[@] LIST_PADDERS[@]

echo
echo '###########################'
echo '> with default separators & padders:'
echo
print_list LIST_NAMES[@] LIST_VALUES[@] LIST_HEADERS[@] LIST_PADDINGS[@]

echo
echo '###########################'
echo '> with default separators & padders & paddings:'
echo
print_list LIST_NAMES[@] LIST_VALUES[@] LIST_HEADERS[@]

echo
echo '###########################'
echo '> with default separators & padders & paddings & no header:'
echo
print_list LIST_NAMES[@] LIST_VALUES[@]

echo
echo '###########################'
echo '> with no value items (empty):'
echo
print_list LIST_NAMES[@]

echo '###########################'
echo '> with nothing at all (empty):'
echo
print_list


exit 0
