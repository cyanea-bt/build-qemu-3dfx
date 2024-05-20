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

if [ -d "./qemu-8-patched" ]; then
  cd qemu-8-patched
  git clean -dfx
  git reset --hard
  git fetch && git pull
else
  git clone https://github.com/cyanea-bt/qemu-8-patched
  cd qemu-8-patched
fi
rsync -r ../qemu-0/hw/3dfx ../qemu-1/hw/mesa ./hw/
patch -p0 -i ../00-qemu82x-mesa-glide.patch
bash ../scripts/sign_commit ..
mkdir ../build && cd ../build
if [ -d "/opt/qemu-8" ]; then
  rm -rf /opt/qemu-8
fi
../qemu-8-patched/configure --prefix=/opt/qemu-8 --target-list="${LIST_TARGETS}" --enable-strip --enable-lto \
                          --enable-whpx --enable-sdl --enable-sdl-image --disable-gtk --disable-gettext \
                          --enable-libusb --enable-usb-redir --enable-libnfs --enable-vdi --enable-vmdk \
                          --enable-vhdx --enable-vvfat --enable-vpc --enable-virglrenderer --enable-qed \
                          --enable-gnutls --enable-slirp --enable-tools --enable-libssh --enable-dsound \
                          --enable-qcow1 --enable-zstd --enable-lzo --disable-vnc --disable-vnc-jpeg \
                          --enable-bzip2 --enable-cloop --enable-colo-proxy --enable-curl --disable-curses \
                          --disable-dbus-display --enable-bochs --enable-dmg --disable-gtk-clipboard \
                          --enable-guest-agent --enable-guest-agent-msi --enable-hv-balloon --enable-iconv \
                          --enable-live-block-migration --enable-opengl --enable-pa --enable-jack \
                          --enable-pixman --enable-png --enable-replication --enable-smartcard --enable-snappy \
                          --enable-spice --enable-spice-protocol \
                          --disable-vnc-sasl --enable-docs --enable-capstone && make -j8 && make install
