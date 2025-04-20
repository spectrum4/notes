#!/usr/bin/env bash

# This script prepares an SD card with Raspberry Pi OS with a modified kernel
# that logs all MMIO accesses in dmesg logs. The modified kernel commits can be
# seen here:
#
#   https://github.com/petemoore/linux/commits/rpi-5.15.y-debug-pcie-usb/
#
# It is designed to be run on macOS, because that is what I use.

set -eu
set -o pipefail
export SHELLOPTS

cd "$(dirname "${0}")"
SCRIPT_DIR="$(pwd)"

# Set desired volume name
VOLUME_NAME="casesensitive"
REPO_PATH="/Volumes/${VOLUME_NAME}/linux"

# Set raspberry pi linux repo branch name
BRANCH_NAME="rpi-6.12.y"

# Step 1: Find the APFS container for the main macOS volume
main_disk=$(diskutil info "Macintosh HD" | awk -F: '/APFS Container/ {gsub(/^[ \t]+/, "", $2); print $2}')

if [ -z "$main_disk" ]; then
  echo "❌ Could not find APFS container for 'Macintosh HD'."
  echo "Make sure the volume exists and is mounted."
  exit 1
fi

echo "✅ Found APFS container: $main_disk"

# Step 2: Check if volume already exists
if diskutil list "$main_disk" | grep -q "${VOLUME_NAME}"; then
  echo "⚠️  Volume '${VOLUME_NAME}' already exists in $main_disk."
else

  # Step 3: Create the case-sensitive volume
  echo "🚀 Creating case-sensitive APFS volume '${VOLUME_NAME}'..."
  diskutil apfs addVolume "$main_disk" APFSX "${VOLUME_NAME}"

  if [ $? -eq 0 ]; then
    echo "✅ Volume '${VOLUME_NAME}' created successfully at /Volumes/${VOLUME_NAME}"
  else
    echo "❌ Failed to create volume."
    exit 1
  fi
fi

if [ -d "${REPO_PATH}" ]; then

  cd "${REPO_PATH}"

  echo "⚠️  Directory '${REPO_PATH}' already exists."
  echo "🚀 Fetching latest commits..."
  git fetch origin

  echo "🔄 Aborting any in-progress Git operations (if any)..."
  git am --abort 2>/dev/null || true
  git rebase --abort 2>/dev/null || true
  git cherry-pick --abort 2>/dev/null || true
  git merge --abort 2>/dev/null || true

  echo "🔁 Resetting working directory..."
  git reset --hard

  echo "🧹 Cleaning untracked and ignored files..."
  git clean -fdx

  echo "✅ Repository reset to a clean state."
else
  echo "🚀 Cloning github.com/raspberrypi/linux into ${REPO_PATH}..."
  git clone git@github.com:raspberrypi/linux.git "${REPO_PATH}"
  cd "${REPO_PATH}"
fi

echo "🚀 Checking out branch ${BRANCH_NAME}..."
git switch "${BRANCH_NAME}" || git switch -c "${BRANCH_NAME}" --track "origin/${BRANCH_NAME}"

echo "🔁 Resetting working directory..."
git reset --hard "origin/${BRANCH_NAME}"

# Apply patch 3
git am "${SCRIPT_DIR}"/patches/patch-3.patch

docker run -v "${REPO_PATH}:/linux" -w /linux --rm -ti ubuntu /bin/bash -c '
set -xveu
set -o pipefail
apt-get update
apt-get upgrade -y
apt install -y git bc bison flex libssl-dev make libc6-dev libncurses5-dev crossbuild-essential-arm64
export KERNEL=kernel8
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2711_defconfig

sed -i "s/^\\(CONFIG_LOCALVERSION=.*\\)\"/\\1-pmoore\"/" .config
sed -i "/^# ARMv8\\.1 architectural features/,/^# end of Kernel Features/ s/=\\y/=n/" .config

scripts/config --enable CONFIG_WERROR

scripts/config --enable CONFIG_TRACING
scripts/config --enable CONFIG_TRACE_MMIO_ACCESS
scripts/config --enable CONFIG_KALLSYMS
scripts/config --enable CONFIG_KALLSYMS_ALL
scripts/config --enable CONFIG_STACKTRACE
scripts/config --enable CONFIG_ARM64_PTDUMP_DEBUGFS
scripts/config --enable CONFIG_IOREMAP_DEBUGFS
scripts/config --enable CONFIG_IO_STRICT_DEVMEM
scripts/config --enable CONFIG_BOOT_CONFIG=y

make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olddefconfig

make -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image.gz modules dtbs V=1
aarch64-linux-gnu-objdump -d vmlinux > kernel.s

# kernel8.img can be copied from arch/arm64/boot/Image.gz
# Use with https://downloads.raspberrypi.com/raspios_arm64/images/raspios_arm64-2023-02-22/
'

# -------------------------------
# Post-build: Patch Raspberry Pi image
# -------------------------------

# Define image source and file names
RPI_BASE_URL="https://downloads.raspberrypi.com/raspios_arm64/images/raspios_arm64-2024-11-19"
RPI_TAR="2024-11-19-raspios-bookworm-arm64.img.xz"
RPI_CHECKSUM="${RPI_TAR}.sha256"
RPI_SIG="${RPI_TAR}.sig"

PATCH_WORKDIR="${SCRIPT_DIR}/patched_image"
rm -rf "$PATCH_WORKDIR"
mkdir -p "$PATCH_WORKDIR"
cd "$PATCH_WORKDIR"

echo "📥 Downloading Raspberry Pi OS image and verification files..."
curl -fsSL -O "${RPI_BASE_URL}/${RPI_TAR}"
curl -fsSL -O "${RPI_BASE_URL}/${RPI_CHECKSUM}"
curl -fsSL -O "${RPI_BASE_URL}/${RPI_SIG}"

echo "🔑 Downloading and importing Raspberry Pi GPG key..."
# This key seems not to be the one used that signed the image
# curl -fsSL https://archive.raspberrypi.org/debian/raspberrypi.gpg.key -o rpi.gpg
# Assume this one is ok instead...
curl -fsSL 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x54c3dd610d9d1b4af82a37758738cd6b956f460c' -o rpi.gpg
gpg --import rpi.gpg || true

echo "🔐 Verifying GPG signature of the checksum file..."
gpg --verify "$RPI_SIG" "$RPI_TAR"

echo "🔍 Verifying SHA256 checksum of the image..."
sha256sum -c "$RPI_CHECKSUM"

echo "📦 Extracting the .img file from the .xz archive..."
xz -dk "$RPI_TAR"  # Produces .img file in place

IMG_FILE="${RPI_TAR%.xz}"

echo "🗂 Mounting partitions from the image to replace kernel8.img..."

# Create mount points
BOOT_MOUNT="${PATCH_WORKDIR}/boot"
mkdir -p "$BOOT_MOUNT"

echo "🔍 Mounting image using hdiutil..."
hdiutil attach "$IMG_FILE" -mountpoint "$BOOT_MOUNT"

echo "📝 Replacing kernel8.img with built Image.gz..."
cp "${REPO_PATH}/arch/arm64/boot/Image.gz" "${BOOT_MOUNT}/kernel8.img"

# 🌲 Copy DTBs
echo "🌲 Copying DTBs to boot partition..."
cp -r "${REPO_PATH}/arch/arm64/boot/dts/broadcom/"*.dtb "${BOOT_MOUNT}/" || echo "No broadcom DTBs found."
cp -r "${REPO_PATH}/arch/arm64/boot/dts/overlays/"*.dtb* "${BOOT_MOUNT}/" || echo "No overlays directory found."

# 🐳 Docker-based kernel module installation into rootfs
echo "📦 Installing kernel modules to image rootfs using Docker..."

DOCKER_IMAGE="debian:bullseye"
IMG_ABS_PATH="$(cd "$(dirname "$IMG_FILE")"; pwd)/$(basename "$IMG_FILE")"

docker run --rm --privileged -v "${IMG_ABS_PATH}:/image.img" -v "${REPO_PATH}:/src" "$DOCKER_IMAGE" bash -c '
  set -e
  apt-get update && apt-get install -y kmod mount parted util-linux e2fsprogs build-essential
  LOOPDEV=$(losetup -f --show /image.img)
  echo "🔁 Using loop device: $LOOPDEV"

  # Use parted to find rootfs offset
  ROOT_OFFSET=$(parted /image.img -ms unit s print | grep ext4 | cut -d: -f2 | sed "s/s//")
  ROOT_OFFSET_BYTES=$((ROOT_OFFSET * 512))
  echo "📏 Root filesystem starts at byte offset: $ROOT_OFFSET_BYTES"

  mkdir /mnt/rootfs
  mount -o offset=$ROOT_OFFSET_BYTES $LOOPDEV /mnt/rootfs

  echo "📦 Installing modules to /mnt/rootfs..."
  cd /src
  make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=/mnt/rootfs modules_install

  echo "🔌 Unmounting rootfs..."
  umount /mnt/rootfs
  losetup -d $LOOPDEV
'

# 🛠 Inject Raspberry Pi OS preconfiguration files
echo "🔐 Creating userconf.txt for user pmoore..."
echo 'pmoore:$6$Zc4ZFXhq10jt16iZ$qWwyk0XKveceRB1iTYpD5mEyiloDVULkvtx7vxbouHQzh5hWNAD2MtL.xWfErytyr6CgOOBuTunYhRtLhZtnA.' > "${BOOT_MOUNT}/userconf.txt"

echo "🗺 Creating firstrun.sh for locale/timezone/keyboard..."
cp "${SCRIPT_DIR}/firstrun.sh" "${BOOT_MOUNT}/firstrun.sh"

# 📝 Edit cmdline.txt
CMDLINE_FILE="${BOOT_MOUNT}/cmdline.txt"
if grep -Fq "systemd.run=" "$CMDLINE_FILE"; then
    echo "ℹ️  systemd.run already set in cmdline.txt"
else
    echo "🛠 Adding initrd=initramfs.cpio and systemd options to cmdline.txt"
    # cmdline.txt is a single line — append the parameter to the end
    echo "$(cat "$CMDLINE_FILE") trace_event=rwmmio:* trace_buf_size=64M systemd.run=/boot/firstrun.sh systemd.run_success_action=reboot systemd.unit=kernel-command-line.target" > "$CMDLINE_FILE"
fi

echo "✅ Replacement done. Detaching image..."
hdiutil detach "$BOOT_MOUNT"

echo "🎉 Raspberry Pi image patched successfully!"

# -------------------------------
# Optional: Flash to SD card
# -------------------------------

echo "💽 Listing available disks (external usually at the bottom):"
diskutil list

echo ""
echo "⚠️  Look for your SD card above - likely the lowest in the list,"
echo "    and typically mounted as /dev/disk3, /dev/disk4, etc."
echo ""

read -p "Enter the disk identifier of your SD card (e.g. disk3): " SD_DISK

if [[ ! "$SD_DISK" =~ ^disk[0-9]+$ ]]; then
  echo "❌ Invalid disk identifier."
  exit 1
fi

echo "💡 You chose: /dev/$SD_DISK"
read -p "Are you sure you want to write to /dev/$SD_DISK? This will erase all data on it. (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
  echo "❌ Aborting."
  exit 1
fi

# Unmount the disk
echo "🔌 Unmounting /dev/$SD_DISK..."
diskutil unmountDisk /dev/$SD_DISK

# Write the image to SD card
echo "✍️  Writing image to /dev/r$SD_DISK using dd (this may take a while)..."
sudo dd if="$IMG_FILE" of="/dev/r$SD_DISK" bs=4m conv=sync status=progress

# Eject the SD card
echo "💨 Ejecting SD card..."
diskutil eject /dev/$SD_DISK

echo "✅ SD card flashed and ejected successfully!"
