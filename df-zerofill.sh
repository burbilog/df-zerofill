#!/bin/bash

if [[ $EUID -eq 0 ]]; then
   echo "This script should NOT be ran as root!!!" 
   exit 1
fi


# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
output_file=""
verbose=0

show_help() {
	echo "Usage: df-zerofill.sh -d DIRECTORY [-p PERCENTS_TO_FILL] [-v]"
	echo "Default PERCENTS_TO_FILL = 95"
}

percent=95


while getopts "vh?d:p:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    v)  verbose=1
        ;;
    d)  directory=$OPTARG
        ;;
    p)  percent=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

# check for target directory existance
if [ -z "${directory}" ]; then
	echo "Target DIRECTORY was not specified!"
	show_help
	exit 1
else
	# calculate disk space
	freespace=`(df -l -k --output=avail ${directory}|grep -v Avail) 2> /dev/null	`
	if ! [ "${freespace}" -ge 0 ] 2> /dev/null 
	then
		echo "Can't obtain filesystem size from directory '${directory}'"
		show_help
		exit 1
	fi
	zerofile=${directory}/zero-file
fi

if (($percent >= 1 && $percent <= 95)); then
	let to_fill=($percent*$freespace)/100

else
	echo "PERCENTS_TO_FILL argument must be positive integer from 50 to 95: ${percent}'"
	show_help
	exit 1
fi

# https://www.cons.org/cracauer/sigint.html
__cleanup()
{
    SIGNAL=$1

    [[ -f "${zerofile}" ]] && rm "${zerofile}"

    # when this function was called due to receiving a signal
    # disable the previously set trap and kill yourself with
    # the received signal
    if [ -n "$SIGNAL" ]
    then
        trap $SIGNAL
        kill -${SIGNAL} $$
    fi
}

trap '__cleanup 1' HUP
trap '__cleanup 2' INT
trap '__cleanup 3' QUIT
trap '__cleanup 13' PIPE
trap '__cleanup 15' TERM


# fill free space with zeroes up to $percent
if [ "${verbose}" -eq 1 ]; then
	echo target directory = $directory
	echo zerofile = $zerofile
	echo freespace = $freespace
	echo percent = $percent
	echo to_fill = $to_fill
	if ! [ -x "$(command -v pv)" ]; then
		echo "Error: pv is not installed! Install pv utility or don't use verbose flag."
		exit 1
	fi
	dd if=/dev/zero | pv -s ${to_fill}k | dd iflag=fullblock of=${zerofile} bs=1K count=${to_fill}
else
	dd if=/dev/zero of=${zerofile} bs=1K count=${to_fill}
fi

# cleanup
rm -f ${zerofile}

