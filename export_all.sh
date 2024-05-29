#!/usr/bin/env bash

opt_short_dates=0
script_name=$(basename "${BASH_SOURCE}")
# logfile="${PWD}/log.txt"
logfile="/opt/log.txt"

# log to stdout and logfile
# $1 = string to write
log_date(){
    local date_ts="[$(date "+%Y.%m.%d-%H:%M:%S")]"
    local msg="$date_ts ${script_name}: ${1}"
    echo "${msg}" | tee -a "${logfile}"
}

print_usage(){
	echo "Usage: ${script_name} [-s]"
    echo "-s    use short dates for archives"
}

OPTIND=1				# Reset in case getopts has been used previously in the shell
while getopts "hs" opt; do
    case "$opt" in
    h)	print_usage
        exit 0
        ;;
    \?)	print_usage
		exit 1
		;;
    s)  log_date "opt - short dates"
		opt_short_dates=1
		;;
    esac
done
shift $((OPTIND-1))		# remove parsed options and args from $@ list

log_date "export all started"

if [[ $opt_short_dates -eq 0 ]] ; then
	bash ./export.sh -ad && \
	bash ./export.sh -ado win32
else
	bash ./export.sh -asd && \
	bash ./export.sh -asdo win32
fi

# check exit code
retVal=${?}
if [[ $retVal -ne 0 ]]; then
	log_date "export all ERROR! Exit: ${retVal}"
	exit ${retVal}
else
	log_date "export all SUCCESS!"
fi
