#!/usr/bin/env bash

# check mingw env
if [ "$MSYSTEM" != "MINGW64" ]; then 
  echo "Error: MSYSTEM == $MSYSTEM";
  echo "Use MINGW64 shell instead!";
  exit 1; 
fi

# clean up qemu-3dfx
cd qemu-3dfx && git clean -dfx
if [ -d "./build" ]; then
  rm -rf ./build
fi

if [ -d "./qemu-6-patched" ]; then
  cd qemu-6-patched
  git clean -dfx
  git reset --hard
  git fetch && git pull
else
  git clone https://github.com/cyanea-bt/qemu-6-patched
  cd qemu-6-patched
fi
bash ../scripts/sign_commit ..
mkdir ../build && cd ../build
if [ -d "/opt/qemu-6" ]; then
  rm -rf /opt/qemu-6
fi

# CFLAGS to compile on gcc 14, not optimal
EXTRA_C="-Wno-error=maybe-uninitialized -Wno-error=dangling-pointer= -Wno-error=enum-int-mismatch"

../qemu-6-patched/configure --extra-cflags="${EXTRA_C}" --prefix=/opt/qemu-6 --target-list=x86_64-softmmu,i386-softmmu \
                          --enable-whpx --enable-sdl --enable-sdl-image --disable-gtk --disable-gettext \
                          --enable-libusb --enable-usb-redir --enable-libnfs --enable-vdi \
                          --enable-vvfat --enable-virglrenderer --enable-qed \
                          --enable-gnutls --enable-slirp --enable-tools --enable-libssh --enable-dsound \
                          --enable-qcow1 --enable-zstd --enable-lzo --enable-vnc --enable-vnc-jpeg \
                          --enable-vnc-sasl --enable-docs --enable-capstone && make -j8 && make install
