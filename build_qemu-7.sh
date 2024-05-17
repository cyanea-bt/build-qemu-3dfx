#!/usr/bin/env bash

# check mingw env
if [ "$MSYSTEM" != "MINGW64" ]; then 
  echo "Error: MSYSTEM == $MSYSTEM";
  echo "Use MINGW64 shell instead!";
  exit 1; 
fi

# set qemu targets. start with no parameters for default targets
if [[ $# -eq 0 ]] ; then
  LIST_TARGETS="x86_64-softmmu,i386-softmmu"
else
  LIST_TARGETS="x86_64-softmmu,i386-softmmu,ppc-softmmu,ppc64-softmmu,arm-softmmu,aarch64-softmmu,riscv32-softmmu,riscv64-softmmu,or1k-softmmu"
fi

# clean up qemu-3dfx
cd qemu-3dfx && git clean -dfx
if [ -d "./build" ]; then
  rm -rf ./build
fi

if [ -d "./qemu-7-patched" ]; then
  cd qemu-7-patched
  git clean -dfx
  git reset --hard
  git fetch && git pull
else
  git clone https://github.com/cyanea-bt/qemu-7-patched
  cd qemu-7-patched
fi
bash ../scripts/sign_commit ..
mkdir ../build && cd ../build
if [ -d "/opt/qemu-7" ]; then
  rm -rf /opt/qemu-7
fi
../qemu-7-patched/configure --prefix=/opt/qemu-7 --target-list="${LIST_TARGETS}" --enable-strip --enable-lto \
                          --enable-whpx --enable-sdl --enable-sdl-image --disable-gtk --disable-gettext \
                          --enable-libusb --enable-usb-redir --enable-libnfs --enable-vdi \
                          --enable-vvfat --enable-virglrenderer --enable-qed \
                          --enable-gnutls --enable-slirp --enable-tools --enable-libssh --enable-dsound \
                          --enable-qcow1 --enable-zstd --enable-lzo --disable-vnc --disable-vnc-jpeg \
                          --enable-bzip2 --enable-cloop --enable-curl --disable-curses \
                          --disable-dbus-display --enable-bochs --enable-dmg --disable-gtk-clipboard \
                          --enable-guest-agent --enable-guest-agent-msi --enable-iconv \
                          --enable-live-block-migration --enable-opengl --enable-pa --enable-jack \
                          --enable-png --enable-replication --enable-smartcard --enable-snappy \
                          --disable-vnc-sasl --enable-docs --enable-capstone && make -j8 && make install
