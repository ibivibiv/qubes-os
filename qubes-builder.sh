#!/usr/bin/env bash

# Run from Dom0, script stage : pre_alpha

# AppVM variable name
bldr=builder

qvm-create --class AppVM --template fedora-30 --label blue --property virt_mode=pvh $bldr
qvm-volume extend $bldr:private 30g
qvm-run --auto --user user --pass-io $bldr 'sudo dnf -y install git \
	createrepo rpm-build make wget rpmdevtools dialog \
	rpm-sign gnupg dpkg-dev debootstrap python2-sh perl-Digest-MD5 \
       	perl-Digest-SHA'
qvm-run --auto --user user --pass-io $bldr 'curl https://keys.qubes-os.org/keys/qubes-master-signing-key.asc | gpg --import'

