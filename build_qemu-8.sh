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

if [ -d "./qemu-8-patched" ]; then
  cd qemu-8-patched
  git clean -dfx
  git reset --hard
  git fetch && git pull
else
  git clone https://github.com/cyanea-bt/qemu-8-patched
  cd qemu-8-patched
fi
bash ../scripts/sign_commit ..
mkdir ../build && cd ../build
if [ -d "/opt/qemu-8" ]; then
  rm -rf /opt/qemu-8
fi
../qemu-8-patched/configure --prefix=/opt/qemu-8 --target-list=x86_64-softmmu,i386-softmmu \
                          --enable-whpx --enable-sdl --enable-sdl-image --disable-gtk --disable-gettext \
                          --enable-libusb --enable-usb-redir --enable-libnfs --enable-vdi --enable-vmdk \
                          --enable-vhdx --enable-vvfat --enable-vpc --enable-virglrenderer --enable-qed \
                          --enable-gnutls --enable-slirp --enable-tools --enable-libssh --enable-dsound \
                          --enable-qcow1 --enable-zstd --enable-lzo --enable-vnc --enable-vnc-jpeg \
                          --enable-vnc-sasl --enable-docs --enable-capstone && make -j8 && make install