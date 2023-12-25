#!/bin/bash

KDIR="$(pwd)"
TC="$HOME/workspace/compilers"
CLDIR="$TC/clang-10.0.6"
PATH="$CLDIR/bin:$TC/aosp-gcc64/bin:$TC/aosp-gcc32/bin:$PATH"
# LD_LIBRARY_PATH="$CLDIR/lib"
CONFIG_FILE="vayu_defconfig"
OBJECT="$KDIR/out/arch/arm64/boot"

export KBUILD_BUILD_USER="Jammy"
export KBUILD_BUILD_HOST="WSL2"

rm -rf out
clear

make_defconfig() {
	make -j$(nproc --all) \
	O=out \
	ARCH=arm64 \
	CC=clang \
	CLANG_TRIPLE=aarch64-linux-gnu- \
	CROSS_COMPILE=aarch64-linux-android- \
	CROSS_COMPILE_ARM32=arm-linux-androideabi- \
	$CONFIG_FILE
}

compile() {
	make -j$(nproc --all) \
	O=out \
	ARCH=arm64 \
	CC=clang \
	CLANG_TRIPLE=aarch64-linux-gnu- \
	CROSS_COMPILE=aarch64-linux-android- \
	CROSS_COMPILE_ARM32=arm-linux-androideabi-
}

package_zip() {
	cd $HOME/workspace
	IMAGE="$OBJECT/Image"
	if [[ ! -d "$HOME/workspace/AnyKernel3" ]]; then
		git clone https://github.com/osm0sis/AnyKernel3.git $HOME/workspace/AnyKernel3
		cd AnyKernel3
		sed -i 's/device.name1=maguro/device.name1=vayu/g' anykernel.sh
		sed -i 's/device.name2=toro/device.name2=bhima/g' anykernel.sh
		sed -i 's!block=/dev/block/platform/omap/omap_hsmmc.0/by-name/boot;!block=auto;!g' anykernel.sh
		sed -i 's/is_slot_device=0;/is_slot_device=auto;/g' anykernel.sh
	fi
	cd $HOME/workspace/AnyKernel3
	if [[ -f "$IMAGE" ]]; then
		cd $HOME/workspace/AnyKernel3
		cp $IMAGE ./
		NAME="miui_patched-$(TZ=Asia/Taipei date "+%y%m%d-%H%M")"
		zip -r9 $NAME.zip * -x .git *zip README.md *placeholder
		cp $NAME.zip /mnt/d/platform-tools/Releases
		echo "Finished!!"
	fi
}

make_defconfig
compile
package_zip
