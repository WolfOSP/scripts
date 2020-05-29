git config --global user.name "WolfOSP"
git config --global user.email "WolfOSP@outlook.com"
cd $HOME
unset BOT_API_KEY
unset CHAT_ID
export KERNELDIR=$HOME/kernel_asus_sdm660-HMP
export KERNELNAME=WOLF-HMP-TEST
sed -i '$d' $HOME/.bashrc
install-package ccache bc libncurses5-dev git-core gnupg flex bison gperf build-essential zip curl libc6-dev ncurses-dev && echo 'export PATH="/usr/lib/ccache:$PATH"' | tee -a ~/.bashrc &&source ~/.bashrc && echo $PATH
git clone --depth 1 https://github.com/kdrag0n/proton-clang.git clang
export PATH="$HOME/clang/bin:$PATH"
rm -rf $HOME/{.phpbrew,.rbenv}
cd kernel_asus_sdm660-HMP
git clone https://github.com/WolfOSP/AnyKernel3.git
curl https://raw.githubusercontent.com/WolfOSP/scripts/proton/functions -o functions
curl https://raw.githubusercontent.com/WolfOSP/scripts/proton/wolf.sh -o wolf.sh
#bash wolf.sh
