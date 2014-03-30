Googy-Max2-Kernel
=================

i9300 kernel for sammy 4.3 based on update12

Build
-----
make ARCH=arm 0googymax2_defconfig

make ARCH=arm CROSS_COMPILE=/Volumes/Cyanogenmod/android/system/prebuilts/gcc/darwin-x86/arm/arm-eabi-4.7/bin/arm-eabi-

Extract ramdisk from existing GoogyMax2 kernel zip file
-------------------------------------------------------

/Volumes/Cyanogenmod/android/system/out/host/darwin-x86/bin/unpackbootimg -i ~/Downloads/Googy-Max2-Kernel_2.1.4_CWM/boot.img -o /Volumes/Cyanogenmod/gmramfs2
cd /Volumes/Cyanogenmod/gmramfs2
cd ramdisk
gunzip -c ../boot.img-ramdisk.gz | cpio -i

Use buildscript
./build_kernel.sh 2_2_1_fimc_javi