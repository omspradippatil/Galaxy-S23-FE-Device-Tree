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

5. Add the following to your manifest file:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <project name="device_samsung_r11s" path="device/samsung/r11s" remote="github" revision="android-13" />
  <project name="device_samsung_exynos2200-common" path="device/samsung/exynos2200-common" remote="github" revision="android-13" />
  <project name="kernel_samsung_exynos2200" path="kernel/samsung/exynos2200" remote="github" revision="android-13" />
  <project name="hardware_samsung" path="hardware/samsung" remote="github" revision="android-13" />
  <project name="vendor_samsung_r11s" path="vendor/samsung/r11s" remote="github" revision="android-13" />
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
