Stage 1 -  rebuild the Xen hypervisor to allow Darwin kernel to boot and improve RTL 8139 emulation:

1. Set up an appvm for building Qubes R3.  https://www.qubes-os.org/doc/QubesR3Building/ is likely to be of some help.

2. In the configured qubes-builder directory, run 'make get-sources'

3. Copy the attached two .patch files to qubes-src/vmm-xen/patches.misc

4. Add the following two lines to qubes-src/vmm-xen/series.conf"
patches.misc/xen-osx.patch
patches.misc/qemu-rtl8139-backports.patch

5. Run 'make vmm-xen'.  This will take a little while

6. Copy the following two files to dom0 (see https://www.qubes-os.org/doc/CopyToDomZero/):
qubes-src/vmm-xen/pkgs/fc20/x86_64/xen-hvm-4.4.2gui3.0.0-6.fc20.x86_64.rpm
qubes-src/vmm-xen/pkgs/fc20/x86_64/xen-hypervisor-4.4.2-6.fc20.x86_64.rpm

7. In dom0, run 'sudo yum reinstall ./xen-h*rpm' wherever you copied the above RPMs into dom0.

8.  Reboot.  On to stage 2.

Stage 2 - installing OS X into an appvm:

1. Set up a USB drive to install OS X (at least 8GB stick).  There are many ways to go about this.  However, you have to use a Hackintosh-style method, because, if nothing else, a Qubes HVM domain does not do EFI boot (which stock OS X requires).  What worked for me is shown at http://www.tonymacx86.com/yosemite-desktop-guides/143976-unibeast-install-os-x-yosemite-any-supported-intel-based-pc.html  This is easy enough to do on a Mac that you have set up to dual boot Qubes and OS X.

2. There are several kexts that are required for OS X to boot with the virtual devices provided by QEMU.  If you used the UniBeast method above, or any other Chameleon-based approach, you copy the kexts into the /Extra/Extensions folder on the USB drive.  The kexts you need to track down are:
AppleIntelPIIXATA2.kext (very, VERY important)
PCGenRTL8139Ethernet.kext (version 1.4.1 is available somewhere)
FakeSMC.kext
NullCPUPowerManagement.kext

Other kexts I had, but may not be needed, are:
AppleACPIPS2Nub.kext
AppleACPIPlatform.kext
ApplePS2Controller.kext
EvOreboot.kext

3.  Copy the following onto the USB as well, as this gets the mouse working at the end of everything:
http://philjordan.eu/osx-virt/binaries/QemuUSBTablet-1.1.pkg (found via http://philjordan.eu/osx-virt/)

4.  Using Qubes Manager, create an HVM-based appvm (no less than 20 GB disk space).  The examples and attachments assume the appvm is named 'osx'.  They also assume your USB stick comes up as /dev/sdb.  You will need to update them to match anything different about these on your system.

5.  Copy the other two attachments (osx-upstream.cfg and myosx.conf) into /var/lib/qubes/appvms/osx.  Revise them as noted above, if needed.  One of the revisions might include providing less than 4GB of memory.  Update the attached files with the MAC address and IP address assigned to your appvm.

6.  QEMU upstream has to be used for the initial phases of the install, as that is the only way to get the mouse to work.  To do this, in /var/lib/qubes/appvms/osx, repeatedly run 'sudo xl set-mem dom0 1500' and 'sudo xl -vvv create osx-upstream.cfg' until the HVM domain starts up.  You may have to modify the 1500 value and the amount of memory assigned in osx-upstream.cfg toi work with the amount of memory available of your system.  You probably can dial the memory in osx-upstream.cfg down to 2048, I would guess.

7.  When the HVM window pops up, IMMEDIATELY hit F12 (you won't have much time).  Choose the USB drive (in the attached .cfg file, this would be drive 2).  Assuming you are doing the above UniBeast method, you then simply choose to boot from the USB drive.  It may take a few minutes, but you should end up at the OS X installer.  If it fails before it gets there, you should add '-v -f debug=0x14c' to the Darwin boot arguments (for Chameleon, see the file /Extra/org.chameleon.Boot.plist, and put this into the value for "Kernel Flags"; while there, you might also set "Graphics Mode" to "1440x900x24" or such).  The 'debug=0x14c' portion gets the OS X kernel to log output via the serial port, which you can review in /var/log/xen/console/guest-osx-dm.log

8.  Install OS X to the virtual hard drive.  Reboot.

9.  Do the  'sudo xl set-mem dom0 1500' and 'sudo xl -vvv create osx-upstream.cfg' thing to bring up OS X again.  This time, tell Chameleon to boot from the hard drive, instead of the install USB.  You will then run through the final part of the OS X installer.  When it asked you about the network adapter, choose manual config, and input the values for the appvm.  It will not find the network, because there is no network in qemu-upstream, but this gets it ready for running in the stubdom HVM.

10.  Once OS X finished coming up, run QemuUSBTablet-1.1.pkg you copied to the USB drive.  This installs the necessary driver for the mouse in the stubdom.  Shut down OS X - we should never need to go back to qemu-upstream now.

11.  Run 'qvm-run osx --custom-config myosx.conf'  Use Chameleon on the USB stick to boot into the hard drive again.  Everything should now work.  The display is going to be a little sluggish, given that QEMU provides an emulated SVGA adapter, and OSX is tailored to running in a full-blown GPU.  You probably want to investigate how to take the USB stick out of the loop by installing Chameleon to your virtual hard drive.  The above link for setting up the install USB talks about using a program called Multibeast to do this.  There are other methods.

There are some quirks with the mouse support - not everything seems to register single clicks quite right or with a single click.  A workaround for this is to use OS X's built-in VNC support, under System Preferences->Sharing->Screen Sharing.  Note that getting the OS X appvm network to communicate with another appvm running vncviewer has its own set of hoops to jump through (see the section "Enabling networking between two AppVMs" at https://www.qubes-os.org/doc/QubesFirewall/)
