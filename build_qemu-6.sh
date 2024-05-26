#!/usr/bin/env bash

# check mingw env
if [[ $MSYSTEM != "MINGW32" ]]; then 
  echo "Error: MSYSTEM == ${MSYSTEM}";
  echo "Use MINGW32 shell instead!";
  exit 1; 
fi

# install correct libslirp version
/usr/bin/env MSYSTEM=MSYS /usr/bin/bash -lc "pacman -U --noconfirm ./packages/mingw32/extra/*libslirp-4.6.1*.zst"

# set qemu targets. start with no parameters for default targets
if [[ $# -eq 0 ]] ; then
  LIST_TARGETS="x86_64-softmmu,i386-softmmu"
else
  LIST_TARGETS="x86_64-softmmu,i386-softmmu,ppc-softmmu,ppc64-softmmu,arm-softmmu,aarch64-softmmu,riscv32-softmmu,riscv64-softmmu,or1k-softmmu"
fi

# clean up qemu-3dfx
cd qemu-3dfx && git clean -dfx
if [[ -d "./build" ]]; then
  rm -rf ./build
fi

if [[ -d "./qemu-6-patched" ]]; then
  cd qemu-6-patched
  git clean -dfx
  git reset --hard
  git fetch && git pull
else
  git clone https://github.com/cyanea-bt/qemu-6-patched
  cd qemu-6-patched
fi
# qemu-3dfx not working for win32 builds, at least for now
# rsync -r ../qemu-0/hw/3dfx ../qemu-1/hw/mesa ./hw/
# patch -p0 -i ../02-qemu620-mesa-glide.patch
# bash ../scripts/sign_commit ..
mkdir ../build && cd ../build
if [[ -d "/opt/qemu-6-win32" ]]; then
  rm -rf /opt/qemu-6-win32
fi
../qemu-6-patched/configure --prefix=/opt/qemu-6-win32 --target-list="${LIST_TARGETS}" --enable-lto \
                          --disable-whpx --enable-sdl --enable-sdl-image --disable-gtk --disable-gettext \
                          --enable-libusb --enable-usb-redir --enable-libnfs --enable-vdi \
                          --enable-vvfat --enable-virglrenderer --enable-qed \
                          --enable-gnutls --enable-slirp --enable-tools --enable-libssh --enable-dsound \
                          --enable-qcow1 --enable-zstd --enable-lzo --disable-vnc --disable-vnc-jpeg \
                          --enable-bzip2 --enable-cloop --enable-curl --disable-curses \
                          --enable-bochs --enable-dmg \
                          --enable-guest-agent --enable-guest-agent-msi --enable-iconv \
                          --enable-live-block-migration --enable-opengl --enable-pa --enable-jack \
                          --enable-replication --enable-smartcard --enable-snappy \
                          --enable-spice --enable-spice-protocol \
                          --disable-vnc-sasl --enable-docs --enable-capstone && make -j8 && make install
