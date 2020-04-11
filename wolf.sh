#!/usr/bin/env bash

export TZ="UTC";

# Kernel compiling script

function check_toolchain() {

    export TC="$(find ${TOOLCHAIN}/bin -type f -name *-gcc)";

	if [[ -f "${TC}" ]]; then
		export CROSS_COMPILE="${TOOLCHAIN}/bin/$(echo ${TC} | awk -F '/' '{print $NF'} |\
sed -e 's/gcc//')";
		echo -e "Using toolchain: $(${CROSS_COMPILE}gcc --version | head -1)";
	else
		echo -e "No suitable toolchain found in ${TOOLCHAIN}";
		exit 1;
	fi
}

function transfer() {
	zipname="$(echo $1 | awk -F '/' '{print $NF}')";
	url="$(curl -# -T $1 https://transfer.sh)";
	printf '\n';
	echo -e "Download ${zipname} at ${url}";
}

if [[ -z ${KERNELDIR} ]]; then
    echo -e "Please set KERNELDIR";
    exit 1;
fi

export DEVICE=$1;
if [[ -z ${DEVICE} ]]; then
    export DEVICE="X00T";
fi

mkdir -p ${KERNELDIR}/aroma
mkdir -p ${KERNELDIR}/files

export SRCDIR="${KERNELDIR}";
export OUTDIR="${KERNELDIR}/out";
export ANYKERNEL="${KERNELDIR}/AnyKernel3/";
export AROMA="${KERNELDIR}/aroma/";
export ARCH="arm64";
export SUBARCH="arm64";
export KBUILD_BUILD_USER="QuantumMech2000"
export KBUILD_BUILD_HOST="TeamQuantum"
export TOOLCHAIN="${HOME}/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/";
export DEFCONFIG="X00T_defconfig";
export ZIP_DIR="${HOME}/${KERNELDIR}/files";
export IMAGE="${OUTDIR}/arch/${ARCH}/boot/Image.gz-dtb";
export CROSS_COMPILE_ARM32=${HOME}/toolchain32/bin/arm-linux-androideabi-
export CC=$HOME/clang/bin/clang
export CLANG_VERSION=$($CC --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
export CLANG_TRIPLE=aarch64-linux-gnu-
export CLANG_LD_PATH=$HOME/clang/lib
export LLVM_DIS=$HOME/clang/bin/llvm-dis

export MAKE_TYPE="Treble"

if [[ -z "${JOBS}" ]]; then
    export JOBS="$(nproc --all)";
fi

export MAKE="make O=${OUTDIR}";
check_toolchain;

export TCVERSION1="$(${CROSS_COMPILE}gcc --version | head -1 |\
awk -F '(' '{print $2}' | awk '{print tolower($1)}')"
export TCVERSION2="$(${CROSS_COMPILE}gcc --version | head -1 |\
awk -F ')' '{print $2}' | awk '{print tolower($1)}')"
export ZIPNAME="${KERNELNAME}-${DEVICE}-$(date +%Y%m%d-%H%M).zip"
export FINAL_ZIP="${ZIP_DIR}/${ZIPNAME}"

[ ! -d "${ZIP_DIR}" ] && mkdir -pv ${ZIP_DIR}
[ ! -d "${OUTDIR}" ] && mkdir -pv ${OUTDIR}

cd "${SRCDIR}";
rm -fv ${IMAGE};

MAKE_STATEMENT=make
 
# Menuconfig configuration
# ================
# If -no-menuconfig flag is present we will skip the kernel configuration step.
# Make operation will use X00T_defconfig directly.
if [[ "$*" == *"-no-menuconfig"* ]]
then
  NO_MENUCONFIG=1
  MAKE_STATEMENT="$MAKE_STATEMENT KCONFIG_CONFIG=./arch/arm64/configs/X00T_defconfig"
fi

if [[ "$@" =~ "mrproper" ]]; then
    ${MAKE} mrproper
fi

if [[ "$@" =~ "clean" ]]; then
    ${MAKE} clean
fi

#curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d text="#Awoo 
#Build Scheduled for $KERNELNAME Kernel 
#Will be posted when testing is over.." -d chat_id="-1001287030751"
${MAKE} $DEFCONFIG;
START=$(date +"%s");
echo -e "Using ${JOBS} threads to compile"
${MAKE} -j${JOBS} \
  	 	 	  ARCH=arm64 \
                          CC=${HOME}/clang/bin/clang \
                          CROSS_COMPILE="${CROSS_COMPILE}" \
                          CLANG_TRIPLE="${CROSS_COMPILE}" ;
exitCode="$?";
END=$(date +"%s")
DIFF=$(($END - $START))
echo -e "Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.";


if [[ ! -f "${IMAGE}" ]]; then
    echo -e "Build failed :P";
    #curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d text="$KERNELNAME Kernel stopped due to an error" -d chat_id="585730571"
    success=false;
    exit 1;
else
    echo -e "Build Succesful!";
    success=true;
fi

echo -e "Copying kernel image";
cp -v "${IMAGE}" "${ANYKERNEL}/";
cd -;
cd ${ANYKERNEL};
mv Image.gz-dtb zImage
zip -r9 ${FINAL_ZIP} *;
cd -;

if [ -f "$FINAL_ZIP" ];
then
echo -e "$ZIPNAME zip can be found at $FINAL_ZIP";
if [[ ${success} == true ]]; then
    echo -e "UPLOAD SUCCESSFUL";

message="Wolf Kernel - EAS Version."
time="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."

#curl -F chat_id=$CHAT_ID -F document=@"${ZIP_DIR}/$ZIPNAME" -F caption="
#♔♔♔♔♔♔♔BUILD-DETAILS♔♔♔♔♔♔♔
#  Make-Type  : EAS(non-SAR)
#⌚ Build-Time : $time
#$(git log --pretty=format:'%h : %s' -5)" https://api.telegram.org/bot$BOT_API_KEY/sendDocument


fi
else
echo -e "Zip Creation Failed  ";
fi