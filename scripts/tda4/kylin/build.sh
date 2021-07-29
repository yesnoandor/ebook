#! /bin/sh

# set -x

# 获取顶层目录
TOP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/../..
LINUX_DIR=$TOP_DIR/linux/ti-processor-sdk-linux-j7-evm-07_02_00_07
RTOS_DIR=$TOP_DIR/rtos/ti-processor-sdk-rtos-j721e-evm-07_02_00_06
TOOLCHAIN_DIR=$TOP_DIR/toolchain

echo "TOP DIR = $TOP_DIR"
echo "LINUX DIR = $LINUX_DIR"
echo "RTOS DIR = $RTOS_DIR"
echo "TOOLCHAIN DIR = $TOOLCHAIN_DIR"

# 使用指导
usage ()
{
	echo "Usage: build.sh <module>"
	echo "build.sh pdk   "
	echo "build.sh ethfw"
	echo "build.sh vision_apps"
}

usage_pdk()
{
	echo "make -s pdk_libs_allcores BOARD=j721e_evm -jN"
	echo "make -s pdk_libs CORE=mcu2_0 BOARD=j721e_evm -jN"
	echo "make -s enet_nimu_example CORE=mcu2_0 BOARD=j721e_evm -jN"
}

usage_ethfw()
{
	echo "make -s ethfw_all BUILD_SOC_LIST=J721E -jN" 
}

usage_vision_apps()
{
	echo "make sdk -jN"
	echo "make sdk_clean"
	echo "make sdk_scrub"
	echo "make pdk -jN"
	echo "make pdk_clean"
	echo "make pdk_scrub"
	echo "make ethfw -jN"
	echo "make ethfw_clean"
	echo "make ethfw_scrub"
	echo "make imaging -jN"
	echo "make imaging_clean"
	echo "make imaging_scrub"
	echo "make tiovx -jN"
	echo "make tiovx_clean"
	echo "make tiovx_scrub"
	echo "make vision_apps -jN"
	echo "make vision_apps_clean"
	echo "make vision_apps_scrub"
}

function build_parse()
{
	if [ ! $# -eq 1 ]; then
		usage $0
		return
	fi


	case $1 in
		pdk)
			cd $RTOS_DIR/pdk_jacinto_07_01_05_14
			usage_pdk 
			;;
		ethfw)
			cd $RTOS_DIR/ethfw
			usage_ethfw
			;;
		vision_apps)
			cd $RTOS_DIR/vision_apps
			usage_vision_apps
			;;	
		*)
			usage
			;;
	esac
}


export PSDKL_PATH=$LINUX_DIR
export PSDKR_PATH=$RTOS_DIR

# cp ${PSDKR_PATH}/pdk_jacinto_07_01_05_14/packages/ti/boot/sbl/binary/j721e_evm/mmcsd/bin/sbl_mmcsd_img_mcu1_0_release.tiimage /media/wenyu/boot/tiboot3.bin
# cp ${PSDKR_PATH}/pdk_jacinto_07_01_05_14/packages/ti/drv/sciclient/soc/V1/tifs.bin  /media/wenyu/boot/tifs.bin



# 获取参数列表
# echo "arg num = $#"
# echo "args = $@"

# 获取用户变量
# User=`who | awk '{print $1}'`
# echo "User = $User"

# 获取顶层目录
# TOP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

build_parse $@

#exit 0



