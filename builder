prepare

sudo dnf install git createrepo rpm-build make wget rpmdevtools dialog rpm-sign gnupg dpkg-dev debootstrap python2-sh perl-Digest-MD5 perl-Digest-SHA
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


--

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


