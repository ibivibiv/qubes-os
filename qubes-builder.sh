#!/usr/bin/env bash

# Run from Dom0, script stage: pre_alpha 

VM_NAME=builder

qvm-create --class AppVM --template fedora-30 --label blue --property virt_mode=pvh $VM_NAME
qvm-volume extend $VM_NAME:private 30g
qvm-run --auto --user user --pass-io $VM_NAME 'sudo dnf -y install git \
	createrepo rpm-build make wget rpmdevtools dialog \
	rpm-sign gnupg dpkg-dev debootstrap python2-sh perl-Digest-MD5 \
       	perl-Digest-SHA'
qvm-run --auto --user user --pass-io $VM_NAME 'curl https://keys.qubes-os.org/keys/qubes-master-signing-key.asc | gpg --import'
qvm-run --auto --user user --pass-io $VM_NAME 'curl https://keys.qubes-os.org/keys/qubes-developers-keys.asc | gpg --import'
qvm-run --auto --user user --pass-io $VM_NAME 'export GIT_PREFIX="https://github.com/QubesOS/qubes-builder.git" && export DIR=qubes-builder && git clone $GIT_PREFIX && cd $DIR && touch override.{conf,data}'
qvm-run --auto --user user --pass-io $VM_NAME 'export DIR=qubes-builder && cd $DIR/scripts && mv verify-git-tag verify-git-tag.bak'
qvm-run --auto --user user --pass-io $VM_NAME 'export DIR=qubes-builder && cd $DIR/scripts && sed -i 's/verify=true/verify=false/g' get-sources'
