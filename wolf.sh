#!/usr/bin/env bash

#Kernel build script

source "${KERNELDIR}/functions"

export TZ="Asia/Kolkata";


##################################################
## Begin Initial Checks

check_var CHAT_ID
check_var BOT_API_KEY
check_var KERNELNAME
check_var KERNELDIR

##################################################
## Env Setup variables | CHANGEABLE PARAMETERS             

export SRCDIR="${KERNELDIR}";
export OUTDIR="${KERNELDIR}/out";
export ANYKERNEL="${KERNELDIR}/AnyKernel3/";
export DEVICE="X00T"
export ARCH="arm64";
export SUBARCH="arm64";
export KBUILD_BUILD_USER="Wolf"
export KBUILD_BUILD_HOST="WolfOSP"
export MAKE_TYPE="HMP(non-SAR)"
export DEFCONFIG="X00T_defconfig";
export ZIP_DIR="$ANYKERNEL";
export IMAGE="${OUTDIR}/arch/${ARCH}/boot/Image.gz-dtb";
export CLANG_VERSION=$(clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
export JOBS="$(nproc --all)"
export ZIPNAME="${KERNELNAME}-${DEVICE}-$(date +%Y%m%d-%H%M).zip"
export FINAL_ZIP="${ZIP_DIR}/${ZIPNAME}"
export MAKE="make O=${OUTDIR}";

wolf_version=$(grep "^CONFIG_LOCALVERSION" arch/arm64/configs/X00T_defconfig | cut -d "=" -f2 | tr -d '"')
tag=$(head -n3 Makefile | sed -E 's/.*(^\w+\s[=]\s)//g' | xargs | sed -E 's/(\s)/./g')

##################################################
## Begin Compilation Process

#check_toolchain;

[ ! -d "${ZIP_DIR}" ] && mkdir -pv ${ZIP_DIR}
[ ! -d "${OUTDIR}" ] && mkdir -pv ${OUTDIR}

cd "${SRCDIR}";
rm -fv ${IMAGE};

MAKE_STATEMENT=make

###################################################
## Menuconfig configuration
## If -no-menuconfig flag is present we will skip the kernel configuration step.
## Make operation will use X00T_defconfig directly.

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

send_msg "<code>Build scheduled for $KERNELNAME kernel</code>"

${MAKE} $DEFCONFIG;

START=$(date +"%s");

echo -e "Using ${JOBS} threads to compile"

${MAKE} -j${JOBS} \
  	      ARCH="$ARCH" \
              CC=clang \
              CROSS_COMPILE=aarch64-linux-gnu- \
              CROSS_COMPILE_ARM32=arm-linux-gnueabi- |& tee build-log.txt
exitCode="$?";
END=$(date +"%s")
DIFF=$(($END - $START))
time="$(($DIFF / 60))m $(($DIFF % 60))s"
echo -e "$time"

changelog-generator | tee changelog.txt >/dev/null
buildlog=$(deldog build-log.txt)
changelog=$(deldog changelog.txt)

##################################################
## validate the build

if [[ ! -f "${IMAGE}" ]]; then
    echo -e "Build failed :P";
    send_msg "<code>$KERNELNAME kernel stopped due to an error</code>
<b>Build Log:</b>
<a href='$buildlog'>build log</a>"
    exit 1;
else
    echo -e "Build Succesful!";
fi

##################################################
## zip creation

echo -e "Copying kernel image";
cp -v "${IMAGE}" "${ANYKERNEL}/";
cd -;
cd ${ANYKERNEL};
mv Image.gz-dtb zImage
zip -r9 ${FINAL_ZIP} * -x .git -x README.md;
cd -;

##################################################
## Upload the build

if [ -f "$FINAL_ZIP" ]
then
	caption_="
<b>BUILD-DETAILS</b>

<b>Make Type:</b>
<code>$MAKE_TYPE</code>
<b>Wolf Version:</b>
<code>$wolf_version</code>
<b>Upstream Tag:</b>
<code>$tag</code>
<b>Build Date:</b>
<code>$(date +"%d-%m-%Y")</code>
<b>Build Duration:</b>
<code>$time</code>
<b>Build Changelog:</b>
<a href='$changelog'>changelog</a>
<b>Build Log:</b>
<a href='$buildlog'>build log</a>"

	send_sticker "CAACAgUAAxkBAAJI316ZisRXlJAaEH4UtPsMqFLEFNxCAAIJAQACLG6EE0S3mUAqU7snGAQ"
	send_doc "$FINAL_ZIP" "$caption_"
	send_zip
	rm -rf "$FINAL_ZIP"
else
	send_msg "Zip Creation Failed  "
fi
