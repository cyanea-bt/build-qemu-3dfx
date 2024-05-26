#!/usr/bin/env bash

# check mingw env
if [[ $MSYSTEM != "MINGW32" ]]; then 
  echo "Error: MSYSTEM == ${MSYSTEM}";
  echo "Use MINGW64 shell instead!";
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
if [[ -d "/opt/host_openglide-win32" ]]; then
  rm -rf /opt/host_openglide-win32
fi
mkdir /opt/host_openglide-win32
cp /tmp/openglide/bin/libglide2x.dll /opt/host_openglide-win32/glide2x.dll
cp /tmp/openglide/bin/libglide3x.dll /opt/host_openglide-win32/glide3x.dll
