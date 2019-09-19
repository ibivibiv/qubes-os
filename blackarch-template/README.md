##### Add this lines to full update system

1. IgnorePkg   = pulseaudio libpulse

##### Then install Blackarch repo

> Run https://blackarch.org/strap.sh as root and follow the instructions.

1. curl -O https://blackarch.org/strap.sh

> The SHA1 sum should match: 9f770789df3b7803105e5fbc19212889674cd503 strap.sh

2. sha1sum strap.sh

>  Set execute bit

3. chmod +x strap.sh

>  Run strap.sh

4. sudo ./strap.sh

