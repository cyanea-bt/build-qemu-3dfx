#!/usr/bin/env bash

BUILD_ENV=MINGW64
opt_host_os="win64"

print_usage(){
    echo "Usage: $0 [-o (win32|win64)]"
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
        echo "os - ${opt_host_os}"
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
../openglide/configure --prefix=/tmp/openglide --disable-sdl && make && make install
if [[ -d "/opt/host_openglide-${opt_host_os}" ]]; then
    rm -rf /opt/host_openglide-${opt_host_os}
fi
mkdir /opt/host_openglide-${opt_host_os}
cp /tmp/openglide/bin/libglide2x.dll /opt/host_openglide-${opt_host_os}/glide2x.dll
cp /tmp/openglide/bin/libglide3x.dll /opt/host_openglide-${opt_host_os}/glide3x.dll
