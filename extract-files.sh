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
    esac
}

# Add vendor.img extraction support for AWJ7
if [ "$SRC" = "vendor" ]; then
    if [ ! -f vendor.img ]; then
        echo "vendor.img not found. Please place S711BXXS1AWJ7 vendor.img in current directory."
        exit 1
    fi
    
    echo "Extracting from S711BXXS1AWJ7 vendor.img..."
    # Extract vendor.img
    mkdir -p vendor_mount
    sudo mount -o loop,ro vendor.img vendor_mount
    
    # Initialize the helper for vendor extraction
    setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"
    
    # Extract the files from mounted vendor
    extract "${MY_DIR}/proprietary-files.txt" "vendor_mount" "${KANG}" --section "${SECTION}"
    
    # Cleanup
    sudo umount vendor_mount
    rmdir vendor_mount
    
    "${MY_DIR}/setup-makefiles.sh"
    exit 0
fi

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
