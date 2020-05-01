git config --global user.name "WolfOSP"
git config --global user.email "WolfOSP@outlook.com"
cd $HOME
export KERNELDIR=$HOME/kernel_asus_sdm660-HMP
export KERNELNAME=WOLF-HMP-TEST
sed -i '$d' $HOME/.bashrc
install-package ccache bc libncurses5-dev git-core gnupg flex bison gperf build-essential zip curl libc6-dev ncurses-dev && echo 'export PATH="/usr/lib/ccache:$PATH"' | tee -a ~/.bashrc &&source ~/.bashrc && echo $PATH
git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 toolchain32
git clone https://github.com/crdroidmod/android_prebuilts_clang_host_linux-x86_clang-6317467.git clang
wget https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
tar -xvf gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
rm gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
rm -rf $HOME/{.phpbrew,.rbenv}
cd kernel_asus_sdm660-HMP
git clone https://github.com/WolfOSP/AnyKernel3.git
curl https://raw.githubusercontent.com/WolfOSP/scripts/hmp/changelog-generator.sh -o changelog-generator.sh
curl https://raw.githubusercontent.com/WolfOSP/scripts/hmp/functions -o functions
curl https://raw.githubusercontent.com/WolfOSP/scripts/hmp/wolf.sh -o wolf.sh
#bash wolf.sh
