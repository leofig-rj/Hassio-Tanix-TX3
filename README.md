# Home Assistant Supervised Installer for Tanix TX3 box running Armbian

In this repository we have three files via Fork of [maxcalavera81/Hassio-Tanix-TX3][maxcalavera81-Hassio-Tanix-TX3] which are: ***extlinux.conf***, ***extlinux.conf-menu*** and ***meson-sm1-sei610-ethfix.dtb***.

These three files are used to configure Linux for the TV Box Tanix TX3.

We have a copy of ***Armbian_20.10_Arm-64_buster_current_5.9.0.img.xz***.

We also have the file ***hassio_tanix_tx3.sh***, which is a script for installing Home Assistant on TV Box Tanix TX3.

This script is largely based on MadDoct <@MadDoct> / Dale Higgs' <@dale3h> work on [MadDoct/hassio-installer][MadDoct-hassio-installer].

This script will install Docker, [Agent for Home Assistant OS][os-agent], and then install
[Home Assistant Supervised][supervised-installer].

## Requirements

- Tanix TX3 TV BOX

## Installation Instructions

1. Flash the latest ARMBIAN stretch image.
2. Run this as root user:

```bash
curl -sL https://raw.githubusercontent.com/leofig-rj/Hassio-Tanix-TX3/master/hassio_tanix_tx3.sh | bash -s
```
3. When ***Select machine type*** appears, select: ***qemuarm-64***

## Known Issues

- **SSH server** add-on (from **Official add-ons**) does not work
  - ***Fix:** use community SSH add-on instead*

- Port conflict when using SSH add-on
  - ***Fix:** change the port in the SSH add-on options*

## License

MIT License

Copyright (c) 2021 Leonardo Figueiro, Bruno Melo <@maxcalavera81>, MadDoct <@MadDoct> and Dale Higgs <@dale3h>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[os-agent]: https://github.com/home-assistant/os-agent
[supervised-installer]: https://github.com/home-assistant/supervised-installer
[maxcalavera81-Hassio-Tanix-TX3]: https://github.com/maxcalavera81/Hassio-Tanix-TX3
[MadDoct-hassio-installer]: https://github.com/MadDoct/hassio-installer
