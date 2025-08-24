#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=r11s
VENDOR=samsung

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        vendor/lib*/libsensorlistener.so)
            "${PATCHELF}" --add-needed "libshim_sensorndkbridge.so" "${2}"
            ;;
        vendor/lib*/hw/audio.primary.*.so)
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v32.so" "${2}"
            ;;
        vendor/lib*/hw/gatekeeper.*.so)
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v32.so" "${2}"
            ;;
        vendor/lib*/libwrappergps.so)
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v32.so" "${2}"
            ;;
        vendor/lib*/vendor.samsung.hardware.*.so)
            "${PATCHELF}" --replace-needed "libhidlbase.so" "libhidlbase-v32.so" "${2}"
            ;;
        vendor/lib*/libril.so)
            echo "Processing RIL library: ${1}"
            ;;
        vendor/lib*/libmalicore.so)
            echo "Processing Mali GPU library: ${1}"
            ;;
        vendor/lib*/libExynosVideoApi.so)
            echo "Processing Exynos Video API library: ${1}"
            ;;
    esac
}

# Function to validate vendor.img
validate_vendor_img() {
    local vendor_img="$1"
    
    if [ ! -f "$vendor_img" ]; then
        echo "Error: $vendor_img not found"
        return 1
    fi
    
    local file_size=$(stat -c%s "$vendor_img" 2>/dev/null || echo "0")
    if [ "$file_size" -lt 1048576 ]; then  # Less than 1MB
        echo "Error: $vendor_img appears to be too small ($file_size bytes)"
        return 1
    fi
    
    # Check if it's a valid image file
    local file_type=$(file "$vendor_img" 2>/dev/null || echo "unknown")
    if [[ ! "$file_type" =~ (filesystem|Android|ext[234]|sparse) ]]; then
        echo "Warning: $vendor_img may not be a valid vendor image"
        echo "File type: $file_type"
    fi
    
    return 0
}

# Function to mount vendor image with multiple methods
mount_vendor_img() {
    local vendor_img="$1"
    local mount_point="$2"
    
    echo "Attempting to mount $vendor_img..."
    
    # Create mount point
    sudo umount "$mount_point" 2>/dev/null || true
    rm -rf "$mount_point"
    mkdir -p "$mount_point"
    
    # Try different mount methods
    local mount_methods=(
        "mount -t ext4 -o loop,ro"
        "mount -t auto -o loop,ro"
        "mount -o loop,ro"
        "mount -t squashfs -o loop,ro"
        "mount -t erofs -o loop,ro"
    )
    
    for method in "${mount_methods[@]}"; do
        echo "Trying: sudo $method $vendor_img $mount_point"
        if sudo $method "$vendor_img" "$mount_point" 2>/dev/null; then
            echo "Successfully mounted using: $method"
            return 0
        fi
    done
    
    # If regular mount fails, try with simg2img (for sparse images)
    if command -v simg2img >/dev/null 2>&1; then
        echo "Trying to convert sparse image with simg2img..."
        local raw_img="${vendor_img}.raw"
        if simg2img "$vendor_img" "$raw_img" 2>/dev/null; then
            echo "Converted sparse image, attempting mount..."
            for method in "${mount_methods[@]}"; do
                if sudo $method "$raw_img" "$mount_point" 2>/dev/null; then
                    echo "Successfully mounted converted image using: $method"
                    return 0
                fi
            done
            rm -f "$raw_img"
        fi
    fi
    
    echo "Failed to mount $vendor_img with all available methods"
    return 1
}

# Function to verify mount and show contents
verify_mount() {
    local mount_point="$1"
    
    if ! mount | grep "$mount_point" >/dev/null; then
        echo "Error: $mount_point is not mounted"
        return 1
    fi
    
    echo "Mount successful! Vendor partition contents:"
    ls -la "$mount_point/" | head -20
    
    # Show some key directories
    for dir in lib lib64 bin etc firmware; do
        if [ -d "$mount_point/$dir" ]; then
            local count=$(find "$mount_point/$dir" -type f 2>/dev/null | wc -l)
            echo "  $dir/: $count files"
        fi
    done
    
    return 0
}

# Function to extract with progress and error handling
extract_with_progress() {
    local files_list="$1"
    local source_dir="$2"
    
    echo "Starting extraction from $source_dir..."
    echo "Files list: $files_list"
    
    # Count total files for progress
    local total_files=$(grep -v '^#' "$files_list" | grep -v '^$' | wc -l)
    echo "Total files to extract: $total_files"
    
    # Create extraction log
    local log_file="${MY_DIR}/extraction.log"
    echo "Extraction started at $(date)" > "$log_file"
    
    # Run extraction with error tolerance
    extract "$files_list" "$source_dir" "${KANG}" --section "${SECTION}" 2>&1 | tee -a "$log_file" || {
        echo "Extraction completed with some errors (this is normal for optional files)"
        echo "Check $log_file for details"
    }
    
    # Show extraction summary
    local extracted_files=$(find "${ANDROID_ROOT}/vendor/${VENDOR}/${DEVICE}" -type f 2>/dev/null | wc -l)
    echo "Extraction summary:"
    echo "  Files extracted: $extracted_files"
    echo "  Log file: $log_file"
    
    return 0
}

# Enhanced vendor.img extraction with comprehensive error handling
if [ "$SRC" = "vendor" ]; then
    echo "=== Samsung Galaxy S23 FE Vendor Extraction ==="
    echo "Firmware: S711BXXS1AWJ7"
    echo "Device: r11s (SM-S711B)"
    
    # Validate vendor.img
    if ! validate_vendor_img "vendor.img"; then
        echo ""
        echo "Please ensure you have the correct vendor.img file:"
        echo "1. Download S711BXXS1AWJ7 firmware for SM-S711B"
        echo "2. Extract vendor.img from the firmware package"
        echo "3. Place it in the current directory"
        echo ""
        echo "Alternative extraction methods:"
        echo "  ./extract-files.sh adb          # From connected device (requires root)"
        echo "  ./extract-files.sh /path/dump   # From system dump"
        echo "  ./extract-files.sh lineage      # Use LineageOS fallback"
        exit 1
    fi
    
    # Mount vendor image
    local mount_point="vendor_mount"
    if ! mount_vendor_img "vendor.img" "$mount_point"; then
        echo ""
        echo "Failed to mount vendor.img. This could be due to:"
        echo "1. Corrupted or incomplete download"
        echo "2. Wrong file format (not a vendor partition image)"
        echo "3. Missing system tools (mount, simg2img)"
        echo ""
        echo "Troubleshooting:"
        echo "  sudo apt install android-tools-fsutils  # For simg2img"
        echo "  file vendor.img                        # Check file type"
        echo "  hexdump -C vendor.img | head           # Check file header"
        exit 1
    fi
    
    # Verify mount and show contents
    if ! verify_mount "$mount_point"; then
        sudo umount "$mount_point" 2>/dev/null || true
        rmdir "$mount_point"
        exit 1
    fi
    
    # Initialize vendor setup
    echo ""
    echo "Initializing vendor extraction..."
    setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"
    
    # Extract files with progress tracking
    echo ""
    extract_with_progress "${MY_DIR}/proprietary-files.txt" "$mount_point"
    
    # Cleanup
    echo ""
    echo "Cleaning up..."
    sudo umount "$mount_point"
    rmdir "$mount_point"
    
    # Generate makefiles
    echo "Generating vendor makefiles..."
    "${MY_DIR}/setup-makefiles.sh"
    
    echo ""
    echo "=== Extraction Complete ==="
    echo "Vendor files have been extracted to: vendor/${VENDOR}/${DEVICE}/"
    echo "You can now proceed with building the ROM."
    exit 0
fi

# Enhanced ADB extraction
if [ "$SRC" = "adb" ]; then
    echo "=== ADB Extraction Method ==="
    echo "Requirements:"
    echo "1. Device must be rooted"
    echo "2. USB debugging enabled"
    echo "3. Device connected and authorized"
    
    # Check ADB connection
    if ! adb devices | grep -q "device"; then
        echo "Error: No device found or device not authorized"
        echo "Please check your ADB connection"
        exit 1
    fi
    
    # Check root access
    if ! adb shell "su -c 'id'" 2>/dev/null | grep -q "uid=0"; then
        echo "Error: Root access not available"
        echo "Please ensure your device is rooted and grant root access to ADB"
        exit 1
    fi
    
    echo "Device detected and root access confirmed"
fi

# LineageOS fallback method
if [ "$SRC" = "lineage" ]; then
    echo "=== LineageOS Fallback Method ==="
    echo "This will create a minimal vendor structure for building"
    
    setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"
    
    # Create minimal vendor structure
    local vendor_dir="${ANDROID_ROOT}/vendor/${VENDOR}/${DEVICE}"
    mkdir -p "$vendor_dir"
    
    # Create minimal makefiles
    cat > "${vendor_dir}/${DEVICE}-vendor.mk" << 'EOF'
# Minimal vendor configuration for Samsung Galaxy S23 FE
# Generated by fallback method

PRODUCT_SOONG_NAMESPACES += \
    vendor/samsung/r11s

# Minimal vendor blobs (will use AOSP defaults)
PRODUCT_PACKAGES += \
    libril
EOF
    
    "${MY_DIR}/setup-makefiles.sh"
    
    echo "Minimal vendor structure created successfully"
    echo "Note: This will use AOSP defaults for most hardware functionality"
    exit 0
fi

# Initialize the helper for standard extraction
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
