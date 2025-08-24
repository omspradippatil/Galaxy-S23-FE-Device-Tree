#!/bin/bash
#
# Copyright (C) 2017-2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=r11s
VENDOR=samsung

echo "Setting up makefiles for Samsung Galaxy S23 FE (${DEVICE})"

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    echo "Make sure you're running this from AOSP source tree"
    exit 1
fi
source "${HELPER}"

# Initialize the helper for vendor generation
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false

echo "Writing vendor makefiles..."

# Warning about using vendor files
write_headers

# The standard vendor blobs
write_makefiles "${MY_DIR}/proprietary-files.txt" true

# Finish
write_footers

echo "Vendor makefiles created successfully for ${DEVICE}"
