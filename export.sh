#!/usr/bin/env bash

#
# compile all binaries and pack them with 7z
#

BUILD_ENV=MINGW64
opt_host_os="win64"
opt_all_targets=0
opt_short_dates=0
opt_dlls=0

print_usage(){
	echo "Usage: $0 [-o (win32|win64)] [-a] [-s] [-d]"
    echo "-o    set host OS (default=win64)"
    echo "-a    build all supported targets"
    echo "-s    use short dates for archives"
    echo "-d    copy/archive required dlls"
}

OPTIND=1				# Reset in case getopts has been used previously in the shell
while getopts "ho:asd" opt; do
    case "$opt" in
    h)	print_usage
        exit 0
        ;;
    \?)	print_usage
		exit 1
		;;
    o)	if [[ $OPTARG == "win32" ]]; then
  			opt_host_os="win32"
  			BUILD_ENV=MINGW32
  		elif [[ $OPTARG == "win64" ]]; then
  			opt_host_os="win64"
  			BUILD_ENV=MINGW64
  		else
  			echo "Invalid argument for host OS!"
  			print_usage
  			exit 1
		fi
		echo "os - ${opt_host_os}"
		;;
    a)  echo "all targets"
		opt_all_targets=1
        ;;
    s)  echo "short dates"
		opt_short_dates=1
		;;
    d)  echo "export dlls"
		opt_dlls=1
        ;;
    esac
done
shift $((OPTIND-1))		# remove parsed options and args from $@ list

# setup for archive filenames
if [[ $opt_short_dates -eq 0 ]] ; then
	DATE=$(date "+%Y-%m-%d-%H.%M.%S")
else
	DATE=$(date "+%Y-%m-%d")
fi

# setup build options
BUILD_OPTS="-o ${opt_host_os}"
if [[ $opt_all_targets -eq 1 ]] ; then
	BUILD_OPTS=${BUILD_OPTS}" -a"
fi
if [[ $opt_dlls -eq 1 ]] ; then
	BUILD_OPTS=${BUILD_OPTS}" -d"
fi

# clean-up
rm -rf /opt/djgpp
rm -rf /opt/watcom

# run all build scripts
/usr/bin/env MSYSTEM=MINGW32 /usr/bin/bash -lc "bash ./build_guest-wrappers.sh" && \
/usr/bin/env MSYSTEM=${BUILD_ENV} /usr/bin/bash -l << END1
bash ./build_host-openglide.sh -o "${opt_host_os}" && \
bash ./build_qemu-6.sh ${BUILD_OPTS} && \
bash ./build_qemu-7.sh ${BUILD_OPTS} && \
bash ./build_qemu-8.sh ${BUILD_OPTS}
END1

# check build exit code
retVal=${?}
if [[ $retVal -ne 0 ]]; then
	echo "build ERROR! Exit: ${retVal}"
	exit ${retVal}
else
	echo "build SUCCESS!"
fi

# run 7z in mingw64 since msys version is slow
/usr/bin/env MSYSTEM=MINGW64 /usr/bin/bash -l << END2
cd /opt

# guest-wrappers
if [[ -d "./guest_3dfx" ]] && [[ -d "./guest_mesa" ]] && [[ -d "./guest_openglide" ]]; then
  7z a -t7z -y -mx=9 -mhe=on -mmt=on -ms=on -mtc=on -mtm=on -mta=on "./guest-wrappers_${DATE}.7z" "guest_3dfx" "guest_mesa" "guest_openglide"
fi

# host-openglide
if [[ -d "./host_openglide-${opt_host_os}" ]]; then
  7z a -t7z -y -mx=9 -mhe=on -mmt=on -ms=on -mtc=on -mtm=on -mta=on "./host-openglide-${opt_host_os}_${DATE}.7z" "host_openglide-${opt_host_os}"
fi

# qemu-6
if [[ -d "./qemu-6-${opt_host_os}" ]]; then
  7z a -t7z -y -mx=9 -mhe=on -mmt=on -ms=on -mtc=on -mtm=on -mta=on "./qemu-6-${opt_host_os}_${DATE}.7z" "qemu-6-${opt_host_os}"
fi

# qemu-7
if [[ -d "./qemu-7-${opt_host_os}" ]]; then
  7z a -t7z -y -mx=9 -mhe=on -mmt=on -ms=on -mtc=on -mtm=on -mta=on "./qemu-7-${opt_host_os}_${DATE}.7z" "qemu-7-${opt_host_os}"
fi

# qemu-8
if [[ -d "./qemu-8-${opt_host_os}" ]]; then
  7z a -t7z -y -mx=9 -mhe=on -mmt=on -ms=on -mtc=on -mtm=on -mta=on "./qemu-8-${opt_host_os}_${DATE}.7z" "qemu-8-${opt_host_os}"
fi

if [[ $opt_dlls -eq 1 ]] ; then
	echo "archive dlls not implemented yet"
fi
END2
