/usr/share/xbps.d/00-repository-main-conf
repository=https://a-hel-fi.m.voidlinux.org/current/
/usr/share/xbps.d/00-a-repository-qubes-conf
repository=http://void.coldbyte.net/qubes/

xbps-query -Rs fon
xbps-install -Su
xbps-reconfigure
upgrade to latest

1. sudo xbps-install -S ca-certificates
2. sudo xbps-install -f glib
3. sudo xbps-install -Su qubes-vm-meta
4. sudo xbps-install --repository=http://void.coldbyte.net/qubes linux5.1-headers linux5.1
   sudo xbps-reconfigure -f linux5.1
   sudo xbps-install -U qubes-linux-utils
   sudo xbps-remove linux4.16
   sudo xbps-remove linux4.16-headers
5. sudo xbps-pkgdb -m hold linux linux-headers
6. sudo xbps-pkgdb -m repolock linux4.18 linux-headers4.18
7. sudo xbps-install -Su (full system upgrade)
8. sudo vim /etc/locale.conf 
   sudo xbps-reconfigure -f glibc-locales


linux 5.1.12_1 
bash 5.0.9(1)

