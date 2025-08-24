# Device Tree for Samsung Galaxy S23 FE (r11s)

This is an AOSP device tree for the Samsung Galaxy S23 FE (SM-S711B) that can be used to build Android ROMs.

## Device specifications

| Feature                 | Specification                                                                                     |
| :---------------------- | :------------------------------------------------------------------------------------------------ |
| Chipset                 | Samsung Exynos 2200 (4 nm)                                                                        |
| CPU                     | Octa-core (1x2.8 GHz Cortex-X2 & 3x2.50 GHz Cortex-A710 & 4x1.8 GHz Cortex-A510)                 |
| GPU                     | Xclipse 920                                                                                       |
| Memory                  | 8GB RAM (LPDDR5)                                                                                  |
| Shipped Android Version | Android 13                                                                                        |
| Storage                 | 128/256 GB (UFS 3.1)                                                                              |
| SIM                     | Dual SIM (Nano-SIM, dual stand-by)                                                                |
| Battery                 | 4500 mAh, non-removable, 25W wired fast charging, 15W wireless charging, 4.5W reverse charging    |
| Dimensions              | 158 x 76.5 x 8.2 mm                                                                               |
| Display                 | 6.4 inches, 1080 x 2340 pixels, Dynamic AMOLED 2X, 120Hz, HDR10+, 1000 nits (HBM), 16M colors     |
| Rear Camera 1           | 50 MP, f/1.8, 24mm (wide), 1/1.56", 1.0µm, Dual Pixel PDAF, OIS                                  |
| Rear Camera 2           | 8 MP, f/2.4, 70mm (telephoto), 1/4.5", 1.0µm, PDAF, OIS, 3x optical zoom                         |
| Rear Camera 3           | 12 MP, f/2.2, 13mm (ultrawide), 1/3.0", 1.12µm                                                    |
| Front Camera            | 10 MP, f/2.4, 26mm (wide), 1/3.24", 1.22µm, Dual Pixel PDAF                                      |
| Fingerprint             | Under-display, optical                                                                            |
| Sensors                 | Accelerometer, Gyro, Proximity, Compass, Barometer                                                 |
| Water/Dust Resistance   | IP68 dust/water resistant (up to 1.5m for 30 mins)                                                |

## Device Picture
![Samsung Galaxy S23 FE](https://fdn2.gsmarena.com/vv/pics/samsung/samsung-galaxy-s23-fe-1.jpg)

## Required Repositories
```
device_samsung_r11s (Device Specific)
device_samsung_exynos2200-common (Platform Common)
kernel_samsung_exynos2200 (Kernel)
vendor_samsung_r11s (Vendor Blobs)
hardware_samsung (Hardware HALs)
```

## Vendor Blobs Extraction

### From vendor.img (Recommended for Android 13 - AWJ7 Firmware)
1. Download the latest firmware S711BXXS1AWJ7 for SM-S711B from SamFirm or similar tools
2. Extract vendor.img from the firmware package
3. Place vendor.img in the device tree root directory
4. Run the extraction script:
```bash
./extract-files.sh vendor
```

### From ADB (Device must be rooted)
```bash
./extract-files.sh adb
```

### From system dump
```bash
./extract-files.sh /path/to/system/dump
```

### Troubleshooting Vendor Extraction

If you get "file not found" errors during extraction:

1. Verify vendor.img is properly mounted:
```bash
sudo mount -t auto -o loop,ro vendor.img vendor_mount
ls -la vendor_mount/
```

2. Check the actual file structure:
```bash
find vendor_mount -name "*.so" | head -10
find vendor_mount -name "*.xml" | head -10
```

3. Use minimal extraction for testing:
```bash
# Edit proprietary-files.txt to include only a few files that definitely exist
./extract-files.sh vendor
```

## Building Instructions

### Setting up the build environment

1. Install the required packages (Ubuntu):
```bash
sudo apt update && sudo apt install git-core gnupg flex bison build-essential zip curl zlib1g-dev libc6-dev-i386 libncurses5 x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig python3
```

2. Set up the repo command:
```bash
mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
export PATH=~/bin:$PATH
```

3. Initialize your local repository:
```bash
mkdir aosp
cd aosp
repo init -u https://android.googlesource.com/platform/manifest -b android-13.0.0_r75
```

4. Create a local manifest:
```bash
mkdir -p .repo/local_manifests
nano .repo/local_manifests/r11s.xml
```

5. Add the following to your manifest file (updated for AWJ7):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <project name="your-github-username/device_samsung_r11s" path="device/samsung/r11s" remote="github" revision="android-13" />
  <project name="LineageOS/android_device_samsung_exynos2200-common" path="device/samsung/exynos2200-common" remote="github" revision="lineage-20" />
  <project name="LineageOS/android_kernel_samsung_exynos2200" path="kernel/samsung/exynos2200" remote="github" revision="lineage-20" />
  <project name="LineageOS/android_hardware_samsung" path="hardware/samsung" remote="github" revision="lineage-20" />
  <project name="your-github-username/vendor_samsung_r11s" path="vendor/samsung/r11s" remote="github" revision="android-13-awj7" />
</manifest>
```

6. Sync the repositories:
```bash
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
```

### Building the ROM

1. Set up the environment:
```bash
source build/envsetup.sh
```

2. Choose your device:
```bash
lunch aosp_r11s-userdebug
```

3. Start the build:
```bash
m droid -j$(nproc --all)
```

4. The built ROM will be located at:
```
out/target/product/r11s/
```

## Flashing Instructions

1. Boot into recovery (Power + Volume Up + Bixby button)
2. Flash the ROM zip file
3. Reboot system

## Notes
- This device tree is based on firmware version S711BXXS1AWJ7 (January 2024 security patch)
- Supports Android 13 AOSP builds
- Compatible with Samsung Galaxy S23 FE (SM-S711B) Global variant

## Copyright

```
/*
 * Copyright (C) 2023 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
```
```
/*
 * Copyright (C) 2023 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
```
