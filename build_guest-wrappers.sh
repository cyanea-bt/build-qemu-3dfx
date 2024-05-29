#!/usr/bin/env bash

BUILD_ENV=MINGW32
opt_host_os="win32"
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

# check mingw env
if [[ $MSYSTEM != $BUILD_ENV ]]; then 
    echo "Error: MSYSTEM == ${MSYSTEM}";
    echo "Use ${BUILD_ENV} shell instead!";
    exit 1; 
fi

log_date "os - ${opt_host_os}"
log_date "build started"

# extract toolchains if they don't exist
if [[ ! -d "/opt/djgpp" ]]; then
    7z x -o"/opt/" "download/djgpp-mingw32.7z"
fi
if [[ ! -d "/opt/watcom" ]]; then
    7z x -o"/opt/" "download/watcom.7z"
fi

# clean up qemu-3dfx
cd qemu-3dfx && git clean -dfx

export DJDIR=/opt/djgpp/i586-pc-msdosdjgpp
export PATH=${PATH}:/opt/djgpp/i586-pc-msdosdjgpp/bin/:/opt/djgpp/bin/
export WATCOM=/opt/watcom
export PATH=${PATH}:/opt/watcom/binnt/:/opt/watcom/binw/

cd wrappers/3dfx
mkdir build && cd build
bash ../../../scripts/conf_wrapper
make && make clean || exit 1
if [[ -d "/opt/guest_3dfx" ]]; then
    rm -rf /opt/guest_3dfx
fi
mkdir /opt/guest_3dfx && cp *.{vxd,sys,dll,dxe,ovl,exe} /opt/guest_3dfx/
log_date "guest/3dfx DONE"

cd ../../mesa
mkdir build && cd build
bash ../../../scripts/conf_wrapper
make && make clean || exit 1
if [[ -d "/opt/guest_mesa" ]]; then
    rm -rf /opt/guest_mesa
fi
mkdir /opt/guest_mesa && cp *.{dll,exe} /opt/guest_mesa/
log_date "guest/mesa DONE"

# clean up qemu-xtra 
cd ../../../../qemu-xtra && git clean -dfx

cd openglide
bash ./bootstrap
mkdir ../build && cd ../build
../openglide/configure --disable-sdl && make && \
cd ../g2xwrap && make || exit 1
if [[ -d "/opt/guest_openglide" ]]; then
    rm -rf /opt/guest_openglide
fi
mkdir /opt/guest_openglide && cp *.dll /opt/guest_openglide/
log_date "guest/openglide DONE"
