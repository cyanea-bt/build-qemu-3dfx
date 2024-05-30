#!/usr/bin/env bash

loop_count=0
find_output=
find_num=0
search_dir=
num_binaries=0
script_name=$(basename "${BASH_SOURCE[0]}")
script_path=$(dirname "$(realpath -s "${BASH_SOURCE[0]}")")
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
	echo "Usage: ${script_name} \"search_dir\""
    echo "e.g.   ${script_name} \"/opt/qemu\""
}

# find/copy dlls required by binaries in directory
# ref: https://github.com/msys2/MINGW-packages/issues/5204#issuecomment-1013818547
find_dlls(){
	local file_pattern=""
	if [[ $loop_count -eq 1 ]] ; then
		file_pattern="./*.exe"
	else
		file_pattern="./*.exe ./*.dll"
	fi

	ldd ${file_pattern} | grep -iv 'system32' | grep -vi 'windows' | grep -v ':$' | \
	# tee /dev/tty | \
	cut -f2 -d '>' | cut -f1 -d '(' | sed -e 's/\\/\//g' | while read a; do ! [[ -e "./$(basename "${a}")" ]] && \
	# echo "${a}" \
	cp -v "${a}" ./; done
}

if [[ -z $1 ]]; then
	echo "Please provide a search directory!"
	print_usage
	exit 1
fi

search_dir=${1}
if [[ ! -d "${search_dir}" ]]; then
    echo "\"${search_dir}\" is not a directory!"
    print_usage
    exit 1
fi

cd "${search_dir}"
# ref: https://stackoverflow.com/a/33891876
num_binaries=$(ls 2>/dev/null -Uba1 -- ./*.exe ./*.dll | wc -l)
if [[ $num_binaries -eq 0 ]] ; then
	echo "\"${search_dir}\" contains no windows binaries!"
    print_usage
    exit 1
fi

log_date "search directory: \"${search_dir}\""

# loop find_dlls until it returns an empty list (= no missing dlls found)
while true
do
	loop_count=$((loop_count+1))
	log_date "searching for dlls, pass #${loop_count}"
	find_output=$(find_dlls)

	if [[ -z $find_output ]]; then
		log_date "search returned 0 missing dlls"
		break
	fi

	# should be done after pass #2, so exit if loop_count keeps rising
	if [[ $loop_count -gt 10 ]]; then
		log_date "ERROR: took more than 10 passes, shutting down!"
		exit 1
	fi

	echo "${find_output}"
	find_num=$(echo "${find_output}" | wc -l)
	log_date "copied ${find_num} dlls to \"${search_dir}\""
done

log_date "dlls DONE"
