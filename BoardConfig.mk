#
# Copyright (C) 2023 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

DEVICE_PATH := device/samsung/r11s

# Inherit from Samsung Exynos2200 common
include device/samsung/exynos2200-common/BoardConfigCommon.mk

# Assert
TARGET_OTA_ASSERT_DEVICE := r11s

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := cortex-a76

# 32-bit
TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-2a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a55

# Kernel
TARGET_KERNEL_CONFIG := r11s_defconfig
TARGET_KERNEL_SOURCE := kernel/samsung/exynos2200

# Display
TARGET_SCREEN_DENSITY := 450

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := exynos2200
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true

# Partitions
BOARD_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_DTBOIMG_PARTITION_SIZE := 8388608
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 104857600
BOARD_FLASH_BLOCK_SIZE := 4096
BOARD_CACHEIMAGE_PARTITION_SIZE := 629145600
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 5536481280
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_PARTITION_SIZE := 118184755200
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_VENDORIMAGE_PARTITION_SIZE := 1778384896
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_PRODUCTIMAGE_PARTITION_SIZE := 1258291200
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4

# Dynamic partitions
BOARD_SUPER_PARTITION_SIZE := 9437184000
BOARD_SUPER_PARTITION_GROUPS := samsung_dynamic_partitions
BOARD_SAMSUNG_DYNAMIC_PARTITIONS_SIZE := 9432989696
BOARD_SAMSUNG_DYNAMIC_PARTITIONS_PARTITION_LIST := system vendor product

# File systems
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# Properties
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.exynos2200
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_INCLUDE_RECOVERY_DTBO := true
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_USES_RECOVERY_AS_BOOT := false
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"

# Root
BOARD_ROOT_EXTRA_FOLDERS := efs carrier odm

# Bluetooth
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(DEVICE_PATH)/bluetooth
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_BCM := true
BOARD_BLUETOOTH_BDROID_HCILP_INCLUDED := false

# APEX
DEXPREOPT_GENERATE_APEX_IMAGE := true

# AVB
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3

# Camera
BOARD_CAMERA_SNUMINTS := 3
BOARD_BACK_CAMERA_ROTATION := 90
BOARD_FRONT_CAMERA_ROTATION := 270
TARGET_USES_MEDIA_EXTENSIONS := true
USE_DEVICE_SPECIFIC_CAMERA := true

# Graphics
TARGET_USES_HWC2 := true
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3

# HIDL
DEVICE_MANIFEST_FILE := $(DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE := $(DEVICE_PATH)/compatibility_matrix.xml

# Security patch level
VENDOR_SECURITY_PATCH := 2023-10-01

# SEPolicy
BOARD_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy

# WiFi
BOARD_WLAN_DEVICE                := bcmdhd
BOARD_WPA_SUPPLICANT_DRIVER      := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_bcmdhd
BOARD_HOSTAPD_DRIVER             := NL80211
BOARD_HOSTAPD_PRIVATE_LIB        := lib_driver_cmd_bcmdhd
WPA_SUPPLICANT_VERSION           := VER_0_8_X
WIFI_DRIVER_FW_PATH_PARAM        := "/sys/module/bcmdhd/parameters/firmware_path"
WIFI_DRIVER_FW_PATH_STA          := "/vendor/firmware/fw_bcmdhd.bin"
WIFI_DRIVER_FW_PATH_AP           := "/vendor/firmware/fw_bcmdhd_apsta.bin"

# Inherit the proprietary files
include vendor/samsung/r11s/BoardConfigVendor.mk
