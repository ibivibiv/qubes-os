================================================
          prepare build machine
================================================

qvm-clone fedora-30 qubes-builder
qvm-run -a qubes-builder gnome-terminal
sudo dnf install git createrepo rpm-build make wget rpmdevtools dialog \
  rpm-sign gnupg dpkg-dev debootstrap python2-sh perl-Digest-MD5 perl-Digest-SHA

qvm-create --class AppVM --label blue --property virt_mode=pvh builder
qvm-volume extend builder:private 30g

qvm-run -a builder gnome-terminal
wget https://keys.qubes-os.org/keys/qubes-master-signing-key.asc
gpg --import qubes-master-signing-key.asc 
gpg --edit-key 36879494
fpr
trust
5
y
q
wget https://keys.qubes-os.org/keys/qubes-developers-keys.asc
gpg --import qubes-developers-keys.asc
git clone git://github.com/QubesOS/qubes-builder.git
cd qubes-builder
git tag -v `git describe`
mkdir -p keyrings/git
cp ~/.gnupg/pubring.gpg ~/.gnupg/trustdb.gpg keyrings/git

===========================================================
                    xenial template
===========================================================
./setup
Yes
Yes
4.0
Stable
Yes
Select builder-fedora and builder-debian
Yes
Select only xenial
make install-deps
make get-sources
make qubes-vm

============================================================
                    archlinux template
============================================================

Archlinux template seems to be fully working and building completely but 
requires minor changes: 

run ./setup 
release 4.0 stable 
select archlinux 

edit the file 
qubes-src/builder-archlinux/scripts/04_install_qubes.sh 

find the line: 
echo "  --> Registering Qubes custom repository..." 
cut out what is in 4 lines after this one echo and paste this instead: 
su -c 'echo "[qubes] " >> $INSTALLDIR/etc/pacman.conf' 
su -c 'echo " #QubesTMP" >> $INSTALLDIR/etc/pacman.conf' 
su -c 'echo "SigLevel = Optional TrustAll " >> $INSTALLDIR/etc/pacman.conf' 
su -c 'echo " #QubesTMP" >> $INSTALLDIR/etc/pacman.conf' 
su -c 'echo "Server = file:///tmp/qubes-packages-mirror-repo/pkgs " >> 
$INSTALLDIR/etc/pacman.conf' 
su -c 'echo " #QubesTMP" >> $INSTALLDIR/etc/pacman.conf' 

The build script has some problem with #comments. 
Not sure why this fix works but different fixes were not, was about to 
give up but then it worked. 

Another couple of edits (taken from 2 day old fix on github) 
/qubes-src/gui-agent-linux/archlinux/PKGBUILD 
In line 11 

makedepends=(pkg-config make gcc patch git automake autoconf libtool 
pulseaudio xorg-server-devel xorg-util-macros xf86dgaproto libxcomposite 
qubes-vm-gui-common qubes-libvchan-xen qubes-db-vm libxt pixman) 

pixman is added just to be sure but im unsure how it helps, as said on 
github too. 

within the same file edit line 62: 
'xorg-server>=1.19.0' 'xorg-server<1.21.0' 

changed from "1.20.0" to "1.21.0" 

and that would be it. Builds. 

The qubes repository with archlinux binaries has its pgp signature expired 
for over 2 months so Qubes- stuff does not upgrade from within template. 

===============================================================
                        centos template
===============================================================

qubes-builder with master (4.1) branch sources successfully builds 
templates for centos 7 standard / minimal and qubuntu xenial, they work 
with Qubes r4.0 as of today,yay 

just run ./setup 
select 4.1 stable 
and pick template.. 

Xenial requires simple editing 
qubes-src/core-agent-linux/debian/rules and comment out 
##--fail-missing so it just builds with "dh_install" alone. 
After the template boot, its best to manually add qubes repo and update 
the core agent. Doing this will install qubes repo to 
/etc/apt/sources.list.d/qubes-r4.list. Can safely use debian stretch 
version of qubes repo, doing so will make the qubes menu usable again, so 
the dom0 can see what is installed, basically all **should** work fine. 
This way build Qubuntu however does NOT in-place-update to 17.10 or maybe 
i missed something. 

centos builds after manually making additional packages with: 
$ make qubes-vm python-xcffib python-pillow && make template 
if doesnt work by now then simply: 
$ make get-sources && make qubes-vm python-xcffib python-pillow && make 
template 

===============================================
                    guixsd 
===============================================

Set up Standalone HVM with kernel ""
Allocate memory
Check allocated IP address : qvm-ls -n

Boot:
qvm-start HVM --cdrom=iso:/home/user/iso/guixsd.iso

At root prompt:
ifconfig -a
ifconfig eth0 10.137.0.16 
ifconfig eth0 up
route add default gw 10.137.0.6
echo nameserver 9.9.9.9 >> /etc/resolv.conf

Disks:
cfdisk /dev/xvda
Configure disks as required: simplest case would be dos, with one partition in /dev/xvda1
No swap

mkfs.ext4 -L root /dev/xvda1

mount LABEL=root /mnt
herd start cow-store /mnt
mkdir /mnt/etc
cp /etc/configuration/desktop.scm /mnt/etc/config.scm

Edit /mnt/etc/config.scm to match requirements:
In particular, check LABEL

guix system init /mnt/etc/config.scm /mnt

Watch the system download package and install in /mnt
Reboot

========================================================
                   crux template
========================================================

Author: https://github.com/hexparrot/qubes-crux

USING CRUX AS A QUBES VIRTUAL MACHINE
------------------------------------------

The current steps will help you install CRUX as a TemplateVM in Qubes.
The following features are currently implemented:

* dom0 I/O and cross-vm copy-paste
* qvm-* commands
* mounts private drive (xvdb)
* working audio
* ships with Firefox
* HVM, PVH, PV

Currently not working:

* firewall rules from dom0
* /rw/config (e.g., rc.local)
* qubes iptables service

* automatically handle xvd* size changes
* swap partition (xvdc)


INSTALLATION STEPS
------------------------------------------

General idea:

1) Download the CRUX ISO, and boot a new Qube from the ISO.
2) Get the internet working on the new qube, then download these helper scripts.
3) Run the helpers scripts to install CRUX to your permanent system (xvda3),
build a minimal kernel, and build all Qubes components.
4) Reboot and test operation.
5) Clone Standalone to TemplateVM, create AppVM.

Ensure this Qube has enough memory to compile a kernel, e.g., 2048MB.
You can reduce the usage of the AppVM later.

Specifics:

Start a StandaloneVM (HVM) 'crux', booting with the CRUX ISO.
Type 'CRUX' to enter the installation environment.

# export IP=10.137.0.x   [get x from Qube Settings:IP]
# export GW=10.137.0.y   [get y from Qube Settings:Gateway]
# export DEV=eth0

# ifconfig $DEV up
# ip route add $GW dev $DEV
# ip route add default via $GW
# ip addr add $IP/32 dev $DEV
# ip link set $DEV up

# echo 'nameserver 10.139.1.1' >> /etc/resolv.conf

# wget --no-check-certificate https://github.com/hexparrot/qubes-crux/tarball/master
# tar -xf master
# cd hexparrot*/helpers
# ./00_full_install
# reboot

And you're done! It's a working qube, perfect for DispVMs or main use
by installing additional software using CRUX' ports system. See prt-get.

To turn this StandaloneVM to a Template VM, in dom0:

$ qvm-clone --class TemplateVM crux crux_template

For using PV/PVH mode, in dom0:

$ cd /var/lib/qubes/vm-kernels
$ qvm-run -p crux 'cat /usr/ports/qubes-crux/helpers/kernel.tar.gz' | tar xzf -

ADDITIONAL NOTES
------------------------------------------

Be sure to read and review the scripts you are executing!

00_full_install is a convenience script that runs every other script
in the helpers/ directory: everything from automating the partitioning of xvda
to copying over system packages, to git-cloning & compiling qubes components.

CRUX requires a custom-built kernel by design at installation-time. 
A minimal kernel config has been provided here under my authorship.
It includes everything necessary for audio and video playback in Firefox,
but there are likely a large number of otherwise useful modules that haven't
made the cut.

You can easily customize the kernel after the installation is complete,
or you can do so before the first reboot. Instead of 00_full_install:

...
# cd hexparrot*/helpers
# ./10_prepare_disk
# ./20_install_packages
# ./30_qubes_config
# ./manual_kernel_build
# exit  #[exit the chroot]
# ./50_qubes_build
# reboot

If for any reason you want direct access to the chroot, CRUX' ISO provides
a shortcut that'll handle mounting of the host /dev for you:

# setup-chroot

KNOWN ISSUES
------------------------------------------

Difficulties with dracut interfering with having full support for xvdc
(swap) and xvda resizing.

PACKAGING SYSTEM
------------------------------------------

CRUX uses the ports system, which is a source-based package manager.
You can see all the qubes-related ports in this repo and all the commands
used to easily reproduce packages for installation. See the CRUX handbook
for more details.

This package will soon be versioned for Qubes 4 and modified to work with
the upcoming Qubes4.1 (which will require new ports altogether).

If anybody has any expertise in the qubes-builder system, your help would
be absolutely invaluable.

To help or if you have any other questions, don't hesitate to email me:
wdchromium at gmail dot com

===========================================================
                    nixos
===========================================================
Set up Standalone HVM with kernel ""
Allocate memory
Check allocated IP address : qvm-ls -n

Boot:
qvm-start HVM --cdrom=iso:/home/user/iso/nixos.iso

At root prompt:
systemctl stop netwpork-manager
ifconfig -a
ifconfig eth0 10.137.0.16 
ifconfig eth0 up
route add default gw 10.137.0.6
echo nameserver 9.9.9.9 >> /etc/resolv.conf

Disks:
cfdisk /dev/xvda
Configure disks as required: simplest case would be dos, with one partition in /dev/xvda1
Swap at /dev/xvda2

mkfs.ext4 -L root /dev/xvda1
mkswap -L swap /dev/xvda2

mount /dev/disk/by-label/root /mnt
swapon /dev/disk/by-label/swap

nixos-generate-config --root /mnt
vi /mnt/etc/nixos/configuration.nix

nixos-install

Watch the system download package and install in /mnt
Set root password
adduser user
passwd user
Reboot

On restart Choose new configuration.

======================================================
                    android template
======================================================

1. Install packages in whonix-14-ws template:

sudo apt-get install openjdk-8-jdk git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip gettext python-pip libyaml-dev dosfstools syslinux syslinux-utils xorriso mtools makebootfat lunzip

2. Create builder AppVM based on whonix-14-ws in which you'll build android-x86:
You'll need 120GB for android-x86 sources and temp build files and 30GB for swap.
Extend private storage size to 160GB via GUI or in dom0:
qvm-volume extend android-builder:private 160g

Add 30GB swap in builder VM:

sudo dd if=/dev/zero of=/rw/swapfile bs=1024 count=31457280
sudo chown root:root /rw/swapfile
sudo chmod 0600 /rw/swapfile
sudo mkswap /rw/swapfile
sudo swapon /rw/swapfile

In builder VM run:

sudo ln -s /sbin/mkdosfs /usr/local/bin/mkdosfs
sudo pip install prettytable Mako pyaml dateutils --upgrade
export _JAVA_OPTIONS="-Xmx8G"
echo 'export _JAVA_OPTIONS="-Xmx8G"' >> ~/.profile
echo "sudo swapon /rw/swapfile" >> /rw/config/rc.local

Download android-x86 sources:

mkdir android-x86
cd android-x86
curl https://storage.googleapis.com/git-repo-downloads/repo > repo
chmod a+x repo
sudo install repo /usr/local/bin
rm repo
git config --global user.name "Your Name"
git config --global user.email "y...@example.com"
repo init -u git://git.osdn.net/gitroot/android-x86/manifest -b android-x86-7.1-r2

To add GAPPS to your build you need to add the build system, and the wanted sources to your manifest.
Edit .repo/manifests/default.xml and add the following towards the end:

<remote name="opengapps" fetch="https://github.com/opengapps/"  />
<project path="vendor/opengapps/build" name="aosp_build" revision="master" remote="opengapps" />
<project path="vendor/opengapps/sources/all" name="all" clone-depth="1" revision="master" remote="opengapps" />
<project path="vendor/opengapps/sources/x86" name="x86" clone-depth="1" revision="master" remote="opengapps" />
<project path="vendor/opengapps/sources/x86_64" name="x86_64" clone-depth="1" revision="master" remote="opengapps" />

Download sources:
repo sync --no-tags --no-clone-bundle --force-sync -j$( nproc --all )

If you choose to add GAPPS, then edit file device/generic/common/device.mk and add at the beginning:

#OpenGAPPS

GAPPS_VARIANT := pico

GAPPS_PRODUCT_PACKAGES += Chrome \
    KeyboardGoogle \
    LatinImeGoogle \
    GoogleTTS \
    YouTube \
    PixelIcons \
    PixelLauncher \
    Wallpapers \
    PixelLauncherIcons \
    WebViewGoogle \
    GoogleServicesFramework \
    GoogleLoginService \

GAPPS_FORCE_BROWSER_OVERRIDES := true
GAPPS_FORCE_PACKAGE_OVERRIDES := true

GAPPS_EXCLUDED_PACKAGES := FaceLock \
    AndroidPlatformServices \
    PrebuiltGmsCoreInstantApps \

And at the end add:

#OpenGAPPS
$(call inherit-product, vendor/opengapps/build/opengapps-packages.mk)

Edit android-x86 sources for XEN compatibility:
sed -i -e 's|/sys/block/\[shv\]d\[a-z\]|/sys/block/\[shv\]d\[a-z\] /sys/block/xvd\[a-z\]|g' bootable/newinstaller/install/scripts/1-install
sed -i -e 's|/sys/block/\[shv\]d\$h/\$1|/sys/block/\[shv\]d\$h/\$1 /sys/block/xvd\$h/\$1|g' bootable/newinstaller/install/scripts/1-install
sed -i -e 's|hmnsv|hmnsvx|g' bootable/newinstaller/initrd/init

Edit android-x86 sources for Debian build environment:
sed -i -e 's|genisoimage|xorriso -as mkisofs|g' bootable/newinstaller/Android.mk

Configure build target:
. build/envsetup.sh
lunch android_x86_64-eng

Configure kernel:
make -C kernel O=$OUT/obj/kernel ARCH=x86 menuconfig
You need to edit these parameters:
XEN=yes
XEN_BLKDEV_BACKEND=yes
XEN_BLKDEV_FRONTEND=yes
XEN_NETDEV_BACKEND=no
XEN_NETDEV_FRONTEND=no
SECURITY_SELINUX_BOOTPARAM=yes
SECURITY_SELINUX_BOOTPARAM_VALUE=1
SECURITY_SELINUX_DISABLE=yes
DEFAULT_SECURITY_SELINUX=yes

The kernel config will be in out/target/product/x86_64/obj/kernel/.config

Also, you can edit the config to set the device type from tablet to phone.
Edit device/generic/common/device.mk and change PRODUCT_CHARACTERISTICS from tablet to default:
PRODUCT_CHARACTERISTICS := default

Start the build:
m -j$( nproc --all ) iso_img

After you got the iso, create the android network VM. If you choose the android VM's netvm as sys-whonix directly, the network won't work. You need to have intermediate netvm between android VM and sys-whonix. Create new AppVM sys-android based on fedora template with netvm sys-whonix and set "provides network".

Create android VM in dom0:
qvm-create --class StandaloneVM --label green --property virt_mode=hvm android
qvm-prefs android kernel ''
qvm-prefs android 'sys-android'
qvm-prefs android memory '2048'
qvm-prefs android maxmem '2048'
qvm-volume extend android:root 20g

Start the android VM with iso:
qvm-start android --cdrom=android-builder:/home/user/android-x86/out/target/product/x86_64/android_x86_64.iso

Install android-x86 on xvda and reboot.

Start android VM without iso:
qvm-start android
When it'll start, kill the VM and wait for it to halt.
Configure android VM to use the mouse in dom0:
sudo mkdir -p /etc/qubes/templates/libvirt/xen/by-name/
sudo cp /etc/libvirt/libxl/android.xml /etc/qubes/templates/libvirt/xen/by-name/android.xml
sudo sed -i -e 's/tablet/mouse/g' /etc/qubes/templates/libvirt/xen/by-name/android.xml

Start android VM without iso and it should work fine:
qvm-start android
