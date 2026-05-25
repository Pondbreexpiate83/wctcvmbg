#!/bin/bash
# =============================================================================
# OnePlus 12 Kernel Build Script
# Platform: Qualcomm SM8650 (Snapdragon 8 Gen 3) - codename "pineapple"
# Source: https://github.com/OnePlusOSS/kernel_manifest (branch: oneplus/sm8650)
# Manifest: oneplus_12_v.xml (Android 15)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="${1:-$HOME/kernel_op12}"
MANIFEST="${2:-oneplus_12_v.xml}"

echo "============================================"
echo " OnePlus 12 Kernel Build"
echo " Build directory: $BUILD_DIR"
echo " Manifest: $MANIFEST"
echo "============================================"

# --- Step 1: Install dependencies ---
echo "[1/4] Installing build dependencies..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
    build-essential bc bison flex libssl-dev libelf-dev \
    git curl python3 python3-pip zip unzip rsync cpio lz4 \
    repo gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu

# --- Step 2: Initialize repo ---
echo "[2/4] Initializing kernel source repo..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

if [ ! -d ".repo" ]; then
    repo init -u https://github.com/OnePlusOSS/kernel_manifest \
        -b oneplus/sm8650 -m "$MANIFEST" --depth=1
fi

# --- Step 3: Sync sources ---
echo "[3/4] Syncing kernel sources..."
repo sync -j$(nproc) --force-sync

# Create required directories
mkdir -p "$BUILD_DIR/out/target/product/pineapple"
mkdir -p "$BUILD_DIR/vendor/oplus/kernel/prebuilt"

# Create vendorsetup.sh stub if missing
if [ ! -f "$BUILD_DIR/vendor/oplus/kernel/prebuilt/vendorsetup.sh" ]; then
    echo "#!/bin/bash" > "$BUILD_DIR/vendor/oplus/kernel/prebuilt/vendorsetup.sh"
    chmod +x "$BUILD_DIR/vendor/oplus/kernel/prebuilt/vendorsetup.sh"
fi

# --- Step 4: Build kernel ---
echo "[4/4] Building kernel..."
cd "$BUILD_DIR/kernel_platform"

./tools/bazel build \
    --pgo=none \
    --//msm-kernel:skip_abl=true \
    --//msm-kernel:skip_abi=true \
    --config=stamp \
    --user_kmi_symbol_lists=//msm-kernel:android/abi_gki_aarch64_qcom \
    --ignore_missing_projects \
    //msm-kernel:pineapple_gki_dist \
    //msm-kernel:pineapple_gki_dtc_dist

# --- Collect output ---
echo ""
echo "============================================"
echo " Build completed successfully!"
echo "============================================"
echo ""
echo "Output images location:"
echo "  (Bazel output in kernel_platform/out/bazel/...)"
echo ""
echo "Key artifacts:"
echo "  - Image (kernel): pineapple_gki_kbuild_mixed_tree/Image"
echo "  - boot.img: pineapple_gki_avb_sign_boot_image/boot.img"
echo "  - vendor_boot.img: pineapple_gki_images_boot_images/vendor_boot.img"
echo "  - dtb.img: pineapple_gki_images_boot_images/dtb.img"
echo "  - dtbo.img: pineapple_gki_images_dtbo/dtbo.img"
echo "  - vendor_dlkm.img: pineapple_gki_images_vendor_dlkm_image/vendor_dlkm.img"
echo "  - super.img: pineapple_gki_super_image/super.img"
echo ""
echo "To flash: use fastboot to flash individual partitions"
echo "  fastboot flash boot boot.img"
echo "  fastboot flash vendor_boot vendor_boot.img"
echo "  fastboot flash dtbo dtbo.img"
echo "  fastboot flash vendor_dlkm vendor_dlkm.img"
