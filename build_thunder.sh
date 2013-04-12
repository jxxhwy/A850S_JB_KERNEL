#!/bin/bash
if [ -e zImage ]; then
	rm zImage
fi

if [ -e boot.img ]; then
	rm boot.img
fi

if [ -e compile.log ]; then
	rm compile.log
fi


if [ -e 850s-thunder.gz ]; then
	rm 850s-thunder.gz
fi

# Set Default Path
TOP_DIR=$PWD
KERNEL_PATH="/home/jxxhwy/Android/850/850sjbkernel"

# Set toolchain and root filesystem path
#TOOLCHAIN="/home/jxxhwy/Android/android_prebuilt/linux-x86/toolchain/arm-eabi-4.4.3/bin/arm-eabi-"
#TOOLCHAIN="/home/jxxhwy/Android/android-toolchain-eabi-4.7.3/bin/arm-eabi-"
TOOLCHAIN="/home/jxxhwy/Android/toolchain-4.6.3/bin/arm-linux-androideabi-"
ROOTFS_PATH="/home/jxxhwy/Android/850/850sboot.img-ramdisk"


export KBUILD_BUILD_VERSION="ThunderKernel-V1.1-a850s-jb"
export KERNELDIR=$KERNEL_PATH
KERNEL_BASE_ADDR=0x80200000
KERNEL_RAMDISK_ADDR=0x82200000

IMAGE_TOOL_NAME=$KERNEL_PATH/mkbootimg 
KERNEL_PAGE_SIZE=2048
KERNEL_CMDLINE='console=NULL,115200,n8 androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x3F ehci-hcd.park=3 loglevel=0 vmalloc=0x12c00000'
#export USE_SEC_FIPS_MODE=true

echo "Cleaning latest build"
make ARCH=arm CROSS_COMPILE=$TOOLCHAIN -j`grep 'processor' /proc/cpuinfo | wc -l` mrproper

# Making our .config
make thunder_defconfig

make -j`grep 'processor' /proc/cpuinfo | wc -l` ARCH=arm CROSS_COMPILE=$TOOLCHAIN >> compile.log 2>&1 || exit -1
echo "Kernel build success!!!"
# Copying kernel modules
find -name '*.ko' -exec cp -av {} $KERNEL_PATH/releasetools/zip/system/lib/modules/ \;

make -j`grep 'processor' /proc/cpuinfo | wc -l` ARCH=arm CROSS_COMPILE=$TOOLCHAIN || exit -1

# Copy Kernel Image
rm -f $KERNEL_PATH/releasetools/zip/$KBUILD_BUILD_VERSION.zip
cp -f $KERNEL_PATH/arch/arm/boot/zImage .

# Create ramdisk.cpio archive
./mkbootfs $ROOTFS_PATH | gzip > 850s-thunder.gz

# Make boot.img
$IMAGE_TOOL_NAME --kernel zImage --ramdisk 850s-thunder.gz --base $KERNEL_BASE_ADDR --pagesize $KERNEL_PAGE_SIZE  --ramdiskaddr $KERNEL_RAMDISK_ADDR --output $KERNEL_PATH/boot.img --cmdline "$KERNEL_CMDLINE"
# Copy boot.img
cp boot.img $KERNEL_PATH/releasetools/zip

rm $KERNEL_PATH/releasetools/zip/*.zip

# Creating flashable zip
cd $KERNEL_PATH
cd releasetools/zip
zip -0 -r $KBUILD_BUILD_VERSION.zip *

# Cleanup
rm $KERNEL_PATH/releasetools/zip/boot.img
rm $KERNEL_PATH/zImage
