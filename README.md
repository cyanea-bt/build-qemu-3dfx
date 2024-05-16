# build scripts for Win10/Win11 hosts using MSYS2
## disclaimer
This is **NOT** a guide on how to use Qemu or how to use the generated files to setup VMs.  
Keep in mind that MSYS2 packages are rolling release, so this is likely going to break in the future and will require fixes.
Also note - I got no clue if all of the files end up working correctly since I got no time to test them all out.
## sources
[qemu source](https://www.qemu.org/)  
[qemu-3dfx by kjliew](https://github.com/kjliew/qemu-3dfx)  
[qemu-xtra by kjliew](https://github.com/kjliew/qemu-xtra)  
[build-djgpp by andrewwutw](https://github.com/andrewwutw/build-djgpp)  
[open-watcom-1.9](https://github.com/open-watcom/open-watcom-1.9)  
[MSYS2-packages](https://github.com/msys2/MSYS2-packages)
## setup
* install msys2
* start msys2 **msys** shell
```bash
pacman -Syyu
pacman -S git
git clone --recursive https://github.com/cyanea-bt/build-qemu-3dfx ~/build-qemu-3dfx
cd ~/build-qemu-3dfx
sed '' packages/pacman_*.txt | pacman -S -
```
**when asked, choose ALL (default/Enter), confirm everything with YES and install/reinstall all**
```bash
pacman -Syyu
pacman -U --needed packages/mingw32/*.zst
```
* close msys2 msys shell
* **setup DONE**
## builds
* start msys2 **mingw32** shell
```bash
cd ~/build-qemu-3dfx
bash ./build_guest-wrappers.sh
```
* close msys2 **mingw32** shell
* start msys2 **mingw64** shell
```bash
cd ~/build-qemu-3dfx
bash ./build_qemu-8.sh
bash ./build_host-openglide.sh
```
* **builds DONE**
* find all generated files in `/opt`