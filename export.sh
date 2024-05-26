#!/usr/bin/env bash

#
# compile all binaries and pack them with 7z
#

# setup for archive filenames
if [[ $# -eq 0 ]] ; then
  DATE=$(date "+%Y-%m-%d-%H.%M.%S")
else
  DATE=$(date "+%Y-%m-%d")
fi

# clean-up
rm -rf /opt/djgpp
rm -rf /opt/watcom

# run all build scripts
/usr/bin/env MSYSTEM=MINGW32 /usr/bin/bash -lc "bash ./build_guest-wrappers.sh" && \
/usr/bin/env MSYSTEM=MINGW32 /usr/bin/bash -l << "END1"
bash ./build_host-openglide.sh && \
bash ./build_qemu-6.sh f && \
bash ./build_qemu-7.sh f && \
bash ./build_qemu-8.sh f
END1

# check build exit code
retVal=${?}
if [[ $retVal -ne 0 ]]; then
  echo "build ERROR! Exit: ${retVal}"
  exit ${retVal}
else
  echo "build SUCCESS!"
fi

# run 7z in mingw64 since msys version is slow
/usr/bin/env MSYSTEM=MINGW64 /usr/bin/bash -l << END2
cd /opt

# guest-wrappers
if [[ -d "./guest_3dfx" ]] && [[ -d "./guest_mesa" ]] && [[ -d "./guest_openglide" ]]; then
  7z a -t7z -y -mx=9 -mhe=on -mmt=on -ms=on -mtc=on -mtm=on -mta=on "./guest-wrappers_${DATE}.7z" "guest_3dfx" "guest_mesa" "guest_openglide"
fi

# host-openglide
if [[ -d "./host_openglide-win32" ]]; then
  7z a -t7z -y -mx=9 -mhe=on -mmt=on -ms=on -mtc=on -mtm=on -mta=on "./host-openglide-win32_${DATE}.7z" "host_openglide-win32"
fi

# qemu-6
if [[ -d "./qemu-6-win32" ]]; then
  7z a -t7z -y -mx=9 -mhe=on -mmt=on -ms=on -mtc=on -mtm=on -mta=on "./qemu-6-win32_${DATE}.7z" "qemu-6-win32"
fi

# qemu-7
if [[ -d "./qemu-7-win32" ]]; then
  7z a -t7z -y -mx=9 -mhe=on -mmt=on -ms=on -mtc=on -mtm=on -mta=on "./qemu-7-win32_${DATE}.7z" "qemu-7-win32"
fi

# qemu-8
if [[ -d "./qemu-8-win32" ]]; then
  7z a -t7z -y -mx=9 -mhe=on -mmt=on -ms=on -mtc=on -mtm=on -mta=on "./qemu-8-win32_${DATE}.7z" "qemu-8-win32"
fi
END2
