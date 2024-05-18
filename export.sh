#!/usr/bin/env bash

#
# create a backup of all compiled binaries
#

DATE=$(date "+%Y-%m-%d-%H.%M.%S")
cd /opt

# guest-wrappers
if [ -d "./guest_openglide" ]; then
  7z a -t7z -y -mx=9 -mhe=on -mmt=on -ms=on -mtc=on -mtm=on -mta=on "./guest-wrappers_${DATE}.7z" "guest_3dfx" "guest_mesa" "guest_openglide"
fi

# host-openglide
if [ -d "./host_openglide" ]; then
  7z a -t7z -y -mx=9 -mhe=on -mmt=on -ms=on -mtc=on -mtm=on -mta=on "./host-openglide_${DATE}.7z" "host_openglide"
fi

# qemu-6
if [ -d "./qemu-6" ]; then
  7z a -t7z -y -mx=9 -mhe=on -mmt=on -ms=on -mtc=on -mtm=on -mta=on "./qemu-6_${DATE}.7z" "qemu-6"
fi

# qemu-7
if [ -d "./qemu-7" ]; then
  7z a -t7z -y -mx=9 -mhe=on -mmt=on -ms=on -mtc=on -mtm=on -mta=on "./qemu-7_${DATE}.7z" "qemu-7"
fi

# qemu-8
if [ -d "./qemu-8" ]; then
  7z a -t7z -y -mx=9 -mhe=on -mmt=on -ms=on -mtc=on -mtm=on -mta=on "./qemu-8_${DATE}.7z" "qemu-8"
fi
