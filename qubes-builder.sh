#!/usr/bin/env bash

qvm-create --class AppVM --template fedora-30 --label blue --property virt_mode=pvh builder
qvm-volume extend builder:private 30g
qvm-run --auto --user user --pass-io builder 'sudo dnf -y install git \
	createrepo rpm-build make wget rpmdevtools dialog \
	rpm-sign gnupg dpkg-dev debootstrap python2-sh perl-Digest-MD5 \
       	perl-Digest-SHA'
qvm-run --auto --user user --pass-io builder 'curl https://keys.qubes-os.org/keys/qubes-master-signing-key.asc | gpg --import'

