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

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)

# Inherit from device makefile
$(call inherit-product, device/samsung/r11s/device.mk)

# Device identifier. This must come after all inclusions
PRODUCT_NAME := aosp_r11s
PRODUCT_DEVICE := r11s
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-S711B
PRODUCT_MANUFACTURER := samsung

PRODUCT_GMS_CLIENTID_BASE := android-samsung

# Use the latest approved GMS identifiers
PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=r11sxxx \
    PRIVATE_BUILD_DESC="r11sxxx-user 13 TP1A.220624.014 S711BXXU1AWJ1 release-keys"

BUILD_FINGERPRINT := "samsung/r11sxxx/r11s:13/TP1A.220624.014/S711BXXU1AWJ1:user/release-keys"
