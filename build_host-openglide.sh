#!/usr/bin/env bash

BUILD_ENV=MINGW64
opt_host_os="win64"
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
    echo "Usage: ${script_name} [-o (win32|win64)]"
    echo "-o    set host OS (default=win64)"
}

OPTIND=1                # Reset in case getopts has been used previously in the shell.
while getopts "ho:" opt; do
    case "$opt" in
    h)  print_usage
        exit 0
        ;;
    \?) print_usage
        exit 1
        ;;
    o)  if [[ $OPTARG == "win32" ]]; then
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
        ;;
    esac
done
shift $((OPTIND-1))     # remove parsed options and args from $@ list

# check mingw env
if [[ $MSYSTEM != $BUILD_ENV ]]; then 
    echo "Error: MSYSTEM == ${MSYSTEM}";
    echo "Use ${BUILD_ENV} shell instead!";
    exit 1; 
fi

log_date "os - ${opt_host_os}"
log_date "build started"

# clean up qemu-xtra 
cd qemu-xtra && git clean -dfx
if [[ -d "./build" ]]; then
    rm -rf ./build
fi

cd openglide
bash ./bootstrap
mkdir ../build && cd ../build
if [[ -d "/tmp/openglide" ]]; then
    rm -rf /tmp/openglide
fi
mkdir /tmp/openglide
../openglide/configure --prefix=/tmp/openglide --disable-sdl && make && make install || exit 1
if [[ -d "/opt/host_openglide-${opt_host_os}" ]]; then
    rm -rf /opt/host_openglide-${opt_host_os}
fi
mkdir /opt/host_openglide-${opt_host_os}
cp /tmp/openglide/bin/libglide2x.dll /opt/host_openglide-${opt_host_os}/glide2x.dll
cp /tmp/openglide/bin/libglide3x.dll /opt/host_openglide-${opt_host_os}/glide3x.dll
log_date "host/openglide DONE"
