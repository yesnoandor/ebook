#! /bin/sh

# set -x

# 获取顶层目录
TOP_DIR=$(dirname "$PWD")
LINUX_DIR=$TOP_DIR/linux
RTOS_DIR=$TOP_DIR/rtos

# echo "TOP DIR = $TOP_DIR"
# echo "LINUX DIR = $LINUX_DIR"
# echo "RTOS DIR = $RTOS_DIR"

# 获取参数列表
#echo "arg num = $#"
#echo "args = $@"

# 设置系统环境变量
# >>> TDA4 GCC Path >>>
export TI_TOOLCHAIN_BASE=/opt/toolchain
export PATH=$TI_TOOLCHAIN_BASE/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin:$TI_TOOLCHAIN_BASE/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf/bin:$PATH

# echo "TI_TOOLCHAIN_BASE DIR = $TI_TOOLCHAIN_BASE"
# <<< TDA4 GCC Path <<<

# 设置Linux&RTOS路径
# >>> TDA4 Linux & Rtos Path >>>
export PSDKL_PATH=$LINUX_DIR/ti-processor-sdk-linux-j7-evm-07_02_00_07
export PSDKR_PATH=$RTOS_DIR/ti-processor-sdk-rtos-j721e-evm-07_02_00_06
# <<< TDA4 Linux & Rtos Path <<<


# 设置工具链路径
export TOOLCHAIN_BASE=$TI_TOOLCHAIN_BASE
export MACHINE=j7-evm

# 设置yocto的环境变量
# >>> . conf/setenv >>> 
# Set OEBASE to where the build and source directories reside
# NOTE: Do NOT place a trailing / on the end of OEBASE.
export OEBASE=$LINUX_DIR
echo "OEBASE DIR = $OEBASE"

# try to find out bitbake directory
BITBAKEDIR=`find ${OEBASE}/sources -name "*bitbake*"`
for f in ${BITBAKEDIR}
do
    if [ -d ${f}/bin ]
    then
        PATH="${f}/bin:$PATH"
    fi
done

# check for any scripts directories in the top-level of the repos and add those
# to the PATH
SCRIPTS=`find ${OEBASE}/sources -maxdepth 2 -name "scripts" -type d`
for s in ${SCRIPTS}
do
    PATH="${s}:$PATH"
done

unset BITBAKEDIR
unset SCRIPTS
export PATH

export BUILDDIR=${LINUX_DIR}/build
export BB_ENV_EXTRAWHITE="MACHINE DISTRO TCMODE TCLIBC http_proxy ftp_proxy https_proxy all_proxy ALL_PROXY no_proxy SSH_AGENT_PID SSH_AUTH_SOCK BB_SRCREV_POLICY SDKMACHINE BB_NUMBER_THREADS PARALLEL_MAKE GIT_PROXY_COMMAND GIT_PROXY_IGNORE SOCKS5_PASSWD SOCKS5_USER OEBASE META_SDK_PATH TOOLCHAIN_TYPE TOOLCHAIN_BRAND TOOLCHAIN_BASE TOOLCHAIN_PATH TOOLCHAIN_PATH_ARMV5 TOOLCHAIN_PATH_ARMV7 TOOLCHAIN_PATH_ARMV8 EXTRA_TISDK_FILES TISDK_VERSION ARAGO_BRAND ARAGO_RT_ENABLE ARAGO_SYSTEST_ENABLE ARAGO_KERNEL_SUFFIX TI_SECURE_DEV_PKG_CAT TI_SECURE_DEV_PKG_AUTO TI_SECURE_DEV_PKG_K3 ARAGO_SYSVINIT SYSFW_FILE"
# <<< . conf/setenv <<<

# 进入编译目录
cd $BUILDDIR

# 提示常用命令
echo "bitbake trusted-firmware-a"
echo "bitbake u-boot-ti-staging"
echo "bitbake mc:k3r5:u-boot-ti-staging"
echo "bitbake mc:k3r5:ti-sci-fw"
echo "bitbake linux-ti-staging"
echo "bitbake tisdk-tiny-image"
echo "bitbake tisdk-default-image"
echo "bitbake arago-core-psdkla-bundle"
echo "bitbake arago-core-psdkla-bundle --runall=fetch"

