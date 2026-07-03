# OpenWrt 24.10 NSS for ASUS OnHub (SRT-AC1900)

Hardware-offload (NSS) build of OpenWrt 24.10 for the ASUS OnHub SRT-AC1900,
targeting the `ipq806x/chromium` subtarget.

**Status: untested bring-up.** The pieces line up in the source (NSS DTS
patches already touch the OnHub's device tree, NSS packages build fine
against the chromium subtarget), but as of this build nobody had previously
assembled a config or flashed this exact combination. Flash at your own risk,
keep recovery access handy, and open an issue if it does/doesn't boot for you.

## Credit

- [OpenWrt](https://openwrt.org) — the base project
- [tingalvin/r7800](https://github.com/tingalvin/r7800) — NSS fork this is
  built from (branch `r7800-24.10.7`), itself continuing work from asvio's repo
- Kong, ACwifidude, vochong — original OnHub NSS device-tree/driver work that
  this fork's NSS patches trace back to

## What's in this repo

- `onhub-nss.diff` — seed `.config` fragment. Selects the `asus_onhub`
  device on the `chromium` subtarget and enables the NSS kernel modules
  (`qca-nss-drv`, `qca-nss-ecm`, `qca-nss-gmac`, etc.)
- `build-onhub-nss.sh` — clones tingalvin's fork, installs feeds, seeds the
  config above, and walks through `make defconfig` / build

The full OpenWrt buildroot itself is **not** vendored here — clone it fresh
from the upstream fork via the build script.

## Building

Needs a real Linux environment (WSL2 on Windows works — see note below on
`/mnt/c` vs `~`), ~25GB free disk, 30-90+ min first build.

```bash
git clone <this-repo>
cd <this-repo>
chmod +x build-onhub-nss.sh
./build-onhub-nss.sh
cd ~/openwrt-onhub-nss
make menuconfig   # sanity-check target device / packages
make -j$(nproc) V=s
```

Images land in `bin/targets/ipq806x/chromium/`:
- `*-squashfs-factory.bin` — flash this only if you're on stock Google/ChromeOS firmware
- `*-squashfs-sysupgrade.bin` — flash this if you're already running OpenWrt/LEDE

### WSL2 note

Build inside the Linux filesystem (`~/`), never under `/mnt/c/...` — Windows
drives mounted into WSL are case-insensitive and slow, and OpenWrt's
buildroot needs case sensitivity. If your build fails referencing `find` and
`-execdir` being insecure, your Windows PATH (likely something with a space
in it, e.g. `C:\Program Files\...`) is leaking into WSL — see `/etc/wsl.conf`,
set `appendWindowsPath = false` under `[interop]`, then `wsl --shutdown` from
PowerShell and reopen.

## Flashing

Sysupgrade images assume you're already on OpenWrt. If you're on stock
firmware, you'll need dev mode + Depthcharge/USB recovery first — see the
[OpenWrt OnHub wiki page](https://openwrt.org/toh/hwdata/asus/asus_srt-ac1900_a)
for the stock → OpenWrt migration path, this repo only covers the
NSS-specific build/flash step after that.

Back up your config first (`sysupgrade -b`), and don't expect settings to
carry over cleanly across this big a package-set change.

## License

OpenWrt and all upstream sources here are GPL-licensed. This repo's own
files (config diff, build script, this README) are released under the same
terms as the upstream project they build on.
