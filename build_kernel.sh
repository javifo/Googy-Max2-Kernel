#!/bin/sh
export KERNELDIR=`greadlink -f .`
export RAMFS_SOURCE=`greadlink -f $KERNELDIR/../gmramfs2/ramdisk`
export PARENT_DIR=`greadlink -f ..`
export USE_SEC_FIPS_MODE=true
export CROSS_COMPILE=/Volumes/Cyanogenmod/android/system/prebuilts/gcc/darwin-x86/arm/arm-eabi-4.7/bin/arm-eabi-
unset USE_CCACHE

# if [ "${1}" != "" ];then
#  export KERNELDIR=`readlink -f ${1}`
# fi

RAMFS_TMP="/Volumes/Cyanogenmod/tmp/gmramfs"

if [ "${2}" = "x" ];then
 make mrproper || exit 1
 make -j4 0googymax2_defconfig || exit 1
fi

# if [ ! -f $KERNELDIR/.config ];
# then
  make ARCH=arm 0googymax2_defconfig || exit 1
# fi

. $KERNELDIR/.config

export ARCH=arm

cd $KERNELDIR/
make -j4 || exit 1

echo "Creating ramdisk"
#remove previous ramfs files
rm -rf $RAMFS_TMP
rm -rf $RAMFS_TMP.cpio
rm -rf $RAMFS_TMP.cpio.gz
#copy ramfs files to tmp directory
cp -aR $RAMFS_SOURCE $RAMFS_TMP
#clear git repositories in ramfs
find $RAMFS_TMP -name .git -exec rm -rf {} \;
#remove orig backup files
find $RAMFS_TMP -name *.orig -exec rm -rf {} \;
#remove empty directory placeholders
find $RAMFS_TMP -name EMPTY_DIRECTORY -exec rm -rf {} \;
rm -rf $RAMFS_TMP/tmp/*
#remove mercurial repository
rm -rf $RAMFS_TMP/.hg
#copy modules into ramfs
mkdir -p $INITRAMFS/lib/modules
# mv -f drivers/home/googy/video/samsung/mali_r3p0_lsi/mali.ko drivers/home/googy/video/samsung/mali_r3p0_lsi/mali_r3p0_lsi.ko
# mv -f drivers/net/wireless/bcmdhd.cm/dhd.ko drivers/net/wireless/bcmdhd.cm/dhd_cm.ko
find . -name '*.ko' -exec cp -av {} $RAMFS_TMP/lib/modules/ \;
${CROSS_COMPILE}strip --strip-unneeded $RAMFS_TMP/lib/modules/*

echo "Making fakeroot"
cd $RAMFS_TMP
find . | fakeroot cpio -H newc -o > $RAMFS_TMP.cpio 2>/dev/null
ls -lh $RAMFS_TMP.cpio
gzip -9 $RAMFS_TMP.cpio
cd -

echo "Make zImage"
make -j4 zImage || exit 1

echo "Creating bootimg"
/Volumes/Cyanogenmod/android/system/out/host/darwin-x86/bin/mkbootimg --kernel $KERNELDIR/arch/arm/boot/zImage --ramdisk /Volumes/Cyanogenmod/tmp/gmramfs.cpio.gz --board smdk4x12 --base 0x10000000 --pagesize 2048 --ramdisk_offset 0x11000000 -o $KERNELDIR/boot.img.pre

echo "Executing mkshbootimg.py"
$KERNELDIR/mkshbootimg.py $KERNELDIR/boot.img $KERNELDIR/boot.img.pre $KERNELDIR/payload.tar
# rm -f $KERNELDIR/boot.img.pre

echo "Creating CWM zip"
#cd /home/googy/Anas/Googy-Max-Kernel
#mv -f -v /home/googy/Anas/Googy-Max-Kernel/Kernel/boot.img .
cp -f -v ~/Downloads/Googy-Max-Kernel_0.zip Googy-Max-Kernel_${1}_CWM.zip
zip -v Googy-Max-Kernel_${1}_CWM.zip boot.img

adb push Googy-Max-Kernel_${1}_CWM.zip /storage/sdcard0/Download/Googy-Max-Kernel_${1}_CWM.zip 
#|| adb push Googy-Max-Kernel_${1}_CWM.zip /storage/sdcard1/Googy-Max-Kernel_${1}_CWM.zip
