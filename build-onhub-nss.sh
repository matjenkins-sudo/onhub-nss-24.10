#!/usr/bin/env bash
# Build a 24.10 NSS image for the ASUS OnHub (SRT-AC1900), based on
# tingalvin's r7800 NSS fork with the chromium/asus_onhub subtarget.
#
# RUN THIS ON YOUR OWN LINUX BOX/VM, NOT IN A RESTRICTED SANDBOX.
# It needs unrestricted internet (kernel.org, gnu mirrors, sourceforge, etc.)
# and 30-90+ min of build time plus ~20GB free disk on first build.

set -euo pipefail

REPO_URL="https://github.com/tingalvin/r7800.git"
BRANCH="r7800-24.10.7"          # check `git ls-remote --heads $REPO_URL` for newer
WORKDIR="${1:-$HOME/openwrt-onhub-nss}"
SEED_CONFIG="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/onhub-nss.diff"

echo "==> Prerequisites (Debian/Ubuntu) - run once if you haven't already:"
cat <<'EOF'
    sudo apt update
    sudo apt install -y binutils bzip2 diff flex gawk gcc getopt grep \
        install-info libc-dev libz-dev libssl-dev make perl python3 \
        rsync subversion unzip which build-essential ncurses-dev
EOF
read -rp "Press Enter once these are installed (or already present) to continue... "

if [ -d "$WORKDIR" ]; then
    echo "==> $WORKDIR already exists, skipping clone. Delete it first for a clean pull."
else
    echo "==> Cloning tingalvin's NSS fork (branch: $BRANCH)"
    git clone --branch "$BRANCH" "$REPO_URL" "$WORKDIR"
fi

cd "$WORKDIR"

echo "==> Updating and installing feeds (NSS packages are vendored in-tree, no NSS feed needed)"
./scripts/feeds update -a
./scripts/feeds install -a

echo "==> Unzipping VHTNSS.zip (optional: enables VHT on 2.4GHz + shows NSS load in status)"
unzip -o VHTNSS.zip -d . || echo "   (skipped - zip not found or already applied)"

echo "==> Seeding config for ASUS OnHub"
cp "$SEED_CONFIG" .config
make defconfig

echo ""
echo "==> Config seeded. Recommended: review before building."
echo "    make menuconfig      # sanity-check target device / packages"
echo ""
echo "==> Then build (this is the long part - 30-90+ min first time):"
echo "    make -j\$(nproc) V=s"
echo ""
echo "==> Output image will land in:"
echo "    bin/targets/ipq806x/chromium/*asus_onhub*sysupgrade.bin"
echo "    bin/targets/ipq806x/chromium/*asus_onhub*factory.bin"
