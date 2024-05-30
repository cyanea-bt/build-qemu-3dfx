#!/usr/bin/env bash

BUILD_ENV=MINGW64
EXTRA_OPTS="--enable-whpx"
opt_host_os="win64"
opt_all_targets=0
opt_dlls=0
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
    echo "Usage: ${script_name} [-o (win32|win64)] [-a] [-d]"
    echo "-o    set host OS (default=win64)"
    echo "-a    build all supported targets"
    echo "-d    copy/archive required dlls"
}

OPTIND=1                # Reset in case getopts has been used previously in the shell.
while getopts "ho:ad" opt; do
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
            EXTRA_OPTS=""
        elif [[ $OPTARG == "win64" ]]; then
            opt_host_os="win64"
            BUILD_ENV=MINGW64
            EXTRA_OPTS="--enable-whpx"
        else
            echo "Invalid argument for host OS!"
            print_usage
            exit 1
        fi
        ;;
    a)  log_date "opt - all targets"
        opt_all_targets=1
        ;;
    d)  log_date "opt - export dlls"
        opt_dlls=1
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

# install correct libslirp version
if [[ $opt_host_os == "win32" ]]; then 
    /usr/bin/env MSYSTEM=MSYS /usr/bin/bash -lc "pacman -U --noconfirm ./packages/mingw32/extra/*libslirp-4.7.0*.zst"    
fi

# set qemu target archs
if [[ $opt_all_targets -eq 0 ]] ; then
    LIST_TARGETS="x86_64-softmmu,i386-softmmu"
else
    LIST_TARGETS="x86_64-softmmu,i386-softmmu,ppc-softmmu,ppc64-softmmu,arm-softmmu,aarch64-softmmu,riscv32-softmmu,riscv64-softmmu,or1k-softmmu"
fi

# clean up qemu-3dfx
cd qemu-3dfx && git clean -dfx
if [[ -d "./build" ]]; then
    rm -rf ./build
fi

if [[ -d "./qemu-7-patched" ]]; then
    cd qemu-7-patched
    git clean -dfx
    git reset --hard
    git fetch && git pull
else
    git clone https://github.com/cyanea-bt/qemu-7-patched
    cd qemu-7-patched
fi
rsync -r ../qemu-0/hw/3dfx ../qemu-1/hw/mesa ./hw/
patch -p0 -i ../01-qemu72x-mesa-glide.patch
bash ../scripts/sign_commit ..
mkdir ../build && cd ../build

INSTALL_DIR="/opt/qemu-7-${opt_host_os}"
if [[ -d "${INSTALL_DIR}" ]]; then
    rm -rf "${INSTALL_DIR}"
fi
../qemu-7-patched/configure --prefix="${INSTALL_DIR}" --target-list="${LIST_TARGETS}" ${EXTRA_OPTS} \
                            --enable-sdl --enable-sdl-image --disable-gtk --disable-gettext \
                            --enable-libusb --enable-usb-redir --enable-libnfs --enable-vdi \
                            --enable-vvfat --enable-virglrenderer --enable-qed \
                            --enable-gnutls --enable-slirp --enable-tools --enable-libssh --enable-dsound \
                            --enable-qcow1 --enable-zstd --enable-lzo --disable-vnc --disable-vnc-jpeg \
                            --enable-bzip2 --enable-cloop --enable-curl --disable-curses \
                            --disable-dbus-display --enable-bochs --enable-dmg --disable-gtk-clipboard \
                            --enable-guest-agent --enable-guest-agent-msi --enable-iconv \
                            --enable-live-block-migration --enable-opengl --enable-pa --enable-jack \
                            --enable-png --enable-replication --enable-smartcard --enable-snappy \
                            --enable-spice --enable-spice-protocol --enable-strip --enable-lto \
                            --disable-vnc-sasl --enable-docs --enable-capstone && \
                            log_date "configure SUCCESS" && make -j8 && make install

# check build exit code
retVal=${?}
if [[ $retVal -ne 0 ]]; then
    log_date "build ERROR! Exit: ${retVal}"
    exit ${retVal}
else
    log_date "build SUCCESS!"
fi

if [[ $opt_dlls -eq 1 ]] ; then
    cd "${script_path}" && \
    bash ./export_dlls.sh "${INSTALL_DIR}" && \
    log_date "dll export SUCCESS" || exit 1
fi
