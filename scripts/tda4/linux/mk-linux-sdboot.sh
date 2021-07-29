#! /bin/sh

# set -x

# 脚本使用指导
usage ()
{
	echo "Usage: $0 <drive> <mode>"
	echo "sudo $0 /dev/sdX   --- all"
	echo "sudo $0 /dev/sdX 0 --- only fdisk"
	echo "sudo $0 /dev/sdX 1 --- only install bootfs"
	echo "sudo $0 /dev/sdX 2 --- only install rootfs" 
	echo "sudo $0 /dev/sdX 3 --- only tar bootfs" 
	echo "sudo $0 /dev/sdX 4 --- only tar rootfs"
	echo "sudo $0 /dev/mmcblkN   --- all"
	echo "sudo $0 /dev/mmcblkN 0 --- only fdisk"
	echo "sudo $0 /dev/mmcblkN 1 --- only install bootfs"
	echo "sudo $0 /dev/mmcblkN 2 --- only install rootfs"
	echo "sudo $0 /dev/mmcblkN 3 --- only tar bootfs"
	echo "sudo $0 /dev/mmcblkN 4 --- only tar rootfs"
}

# 执行shell脚本命令
execute ()
{
    $* >/dev/null
    if [ $? -ne 0 ] ; then
        echo
        echo "ERROR: executing $*"
        echo
        exit 1
    fi
}


# 检查是否继续
#check_if_exit()
#{
#	DEFLT="N";
#	echo "Do you want to continue (y/n)? [${DEFLT}]: $C"
#	RDVAR=$DEFLT
#	read RDVAR
	
#	case $RDVAR in
#		"") RDVAR=$DEFLT;;
#	esac

#	ANSWER=$RDVAR
#	case $ANSWER in
#		Y|y) ;;
#		*)   echo "Script ended, no action performed." exit 0 ;;
#  esac
#}

# 检查是否
# check_if_mounted ()
# {
#	mount | grep "^$DRIVE"
#	[ "$?" = "0" ] && echo "++ ERROR: Umount any partition on $DRIVE ++" && exit 1
# }

# 检查是否是主分区
check_if_main_drive ()
{
	mount | grep " on / type " > /dev/null
	if [ "$?" != "0" ] ; then
		echo "WARNING: not able to determine current filesystem device"
	else
		main_dev=`mount | grep " on / type " | awk '{print $1}'`								# 获取当前主分区
		echo "Main device is: $main_dev"
		echo $main_dev | grep "$DRIVE" > /dev/null
		[ "$?" = "0" ] && echo "ERROR: $device seems to be current main drive" && exit 1
	fi
}

# 检查是否是移动介质分区 （根据大小）
check_if_big_size ()
{
	partname=`basename $DRIVE`
	size=`cat /proc/partitions | grep $partname | head -1 | awk '{print $3}'`					# 获取存储介质的大小
	
	if [ $size -gt 128000000 ] ; then															
		cat << EOM
************************* WARNING ***********************************
*                                                                   *
*      Selected Device is greater then 128GB                        *
*      Continuing past this point will erase data from device       *
*      Double check that this is the correct SD Card                *
*                                                                   *
*********************************************************************
EOM

		local flag=0
		while [ $flag -ne 1 ]
		do
			read -p 'Would you like to continue [y/n] : ' SIZECHECK

			case $SIZECHECK in
				"y")  flag=1;;
				*)  exit;;
			esac
		done
	fi
}

# 确认是否是root权限执行
check_root_user ()
{
	user=`id -u`
	if [ "$user" != "0" ] ; then								# root权限时， id -u 返回0
		echo "ERROR::Must be root/sudo" 
		exit 1
	fi 
}

# umount所有指定存储介质的分区
unmount_all_partitions ()
{
	for i in `ls -1 $DRIVE*`; do
		echo "unmounting device '$i'"
		umount $i 2>/dev/null
	done

	mount | grep $device
}

:<<!
fdisk_sdboot()
{
	cat << END | fdisk $device
n
p
1

+128M
n
p
2


t
1
c
a
1
w
END
}
!

# 安装boot分区
install_bootfs()
{
	echo "DEPLOY DIR0 = $DEPLOY_DIR"
	echo "BOOTFS_DIR0 = $BOOTFS_DIR"

	if [ -d $BOOTFS_DIR ] ; then
		echo "Installing bootfs..."
		
		cp -rfL $DEPLOY_DIR/tiboot3.bin $BOOTFS_DIR
		cp -rfL $DEPLOY_DIR/tispl.bin $BOOTFS_DIR
		cp -rfL $DEPLOY_DIR/u-boot.img $BOOTFS_DIR
		cp -rfL $DEPLOY_DIR/sysfw.itb $BOOTFS_DIR
		sync
		echo "Installing bootfs ... Done"
    else
        echo "ERROR: $BOOTFS_DIR not found !!!"
    fi
}

# 安装root分区
install_rootfs()
{
	echo "DEPLOY DIR = $DEPLOY_DIR"
	echo "ROOTFS_DIR = $ROOTFS_DIR"

    if [ -d $ROOTFS_DIR ] ; then
        echo "Installing rootfs..."

        if [ -f $DEPLOY_DIR/$ROOTFS_TAR ]
        then
			tar -xf $DEPLOY_DIR/$ROOTFS_TAR -C $ROOTFS_DIR
            sync
            echo "Installing rootfs ... Done"
        else
            echo "ERROR: $rootfs_file not found !!!"
        fi
    else
        echo "ERROR: $rootfs_folder not found !!!"
    fi
}

# 将当前boot分区打包成tar包
tar_bootfs()
{
	if [ -d $BOOTFS_DIR ] ; then
		echo "Creating $BOOTFS_TAR from $BOOTFS_DIR ..."
		if [ ! -f $BOOTFS_TAR ] ; then
            cd $BOOTFS_DIR
			tar czfP $TOP_DIR/$BOOTFS_TAR *
            # tar czfP ./$BOOTFS_TAR $BOOTFS_DIR
			# tar czfP ./$BOOTFS_TAR -C /media/wenyu/boot *
            cd -
            sync
            echo "Creating $BOOTFS_TAR from $BOOTFS_DIR ... Done"
        else
            echo "ERROR: $BOOTFS_TAR exists NOT overwriting it, delete this file manually to create a new one !!!"
        fi
    else
        echo "ERROR: $BOOTFS_DIR not found !!!"
    fi
}

# 将当前rootfs分区打包成tar包
tar_rootfs()
{
	if [ -d $ROOTFS_DIR ] ; then
		echo "Creating $ROOTFS_TAR from $ROOTFS_DIR ..."
		if [ ! -f $ROOTFS_TAR ] ; then
			cd $ROOTFS_DIR
			tar cpzf $TOP_DIR/$ROOTFS_TAR *
			# sudo tar cpzf $ROOTFS_TAR $ROOTFS_DIR
			cd -
			sync
			echo "Creating $ROOTFS_TAR from $ROOTFS_DIR ... Done"
		else
			echo "ERROR: $ROOTFS_TAR exists NOT overwriting it, delete this file manually to create a new one !!!"
		fi
	else
		echo "ERROR: $ROOTFS_DIR not found !!!"
	fi
}


function build_parse()
{
	echo "build parse::++++++++++"
	
	echo "arg num = $#"
	echo "args = $@"

	# 参数解析
	if [ $# -gt 3 ]; then
		usage $0
		exit 1
	fi

	if [ $# -eq 0 ]; then
		usage $0
		exit 1
	fi

	# 获取SD卡的节点名，并作相应的检查
	DRIVE=$1
	echo "DRIVE Name = $DRIVE"
	if [ ! -b $DRIVE ] ; then									# 文件是否存在，并是否是block设备节点
		echo "ERROR: $DRIVE is not a block device"
		exit 1
	fi

	if [ $# -eq 2 ]; then
		MODE=$2
		echo "Mode = $MODE"
	fi

	# 确定分区的名字
	PARTITION1=${DRIVE}1
	if [ ! -b ${PARTITION1} ]; then
		PARTITION1=${DRIVE}p1									# /dev/sdd1 or /dev/mmcblk0p1
	fi

	PARTITION2=${DRIVE}2
	if [ ! -b ${PARTITION2} ]; then
		PARTITION2=${DRIVE}p2									# /dev/sdd2 or /dev/mmcblk0p2
	fi

	echo "PARTITION1 = $PARTITION1"
	echo "PARTITION2 = $PARTITION2"

	if [ $# -eq 1 ]; then
		create_partition
		install_bootfs
		install_rootfs
	else
		case $MODE in
			0)
				create_partition
				;;
			1)
				install_bootfs
				;;
			2)
				install_rootfs
				;;
			3)
				tar_bootfs
				;;
			4)
				tar_rootfs
				;;
			*)
				usage $0
				exit 1
				;;
		esac
	fi

	
	echo "build parse::----------"
}

function create_partition()
{
	check_root_user
	check_if_main_drive
	check_if_big_size
	# check_if_mounted


	echo "************************************************************"
	echo "*         THIS WILL DELETE ALL THE DATA ON $device         *"
	echo "*                                                          *"
	echo "*         WARNING! Make sure your computer does not go     *"
	echo "*                  in to idle mode while this script is    *"
	echo "*                  running. The script will complete,      *"
	echo "*                  but your SD card may be corrupted.      *"
	echo "*                                                          *"
	echo "*         Press <ENTER> to confirm....                     *"
	echo "************************************************************"
	read junk

	# 禁止udev事件处理
	udevadm control -s

	# umount 
	unmount_all_partitions

	# 擦除分区表
	execute "dd if=/dev/zero of=$DRIVE bs=1024 count=1024"

	sync

	# 格式化分区
	cat << END | fdisk $DRIVE
n
p
1

+128M
n
p
2


t
1
c
a
1
w
END

	sync

	unmount_all_partitions
	sleep 3

	# 确定分区的名字
	PARTITION1=${DRIVE}1
	if [ ! -b ${PARTITION1} ]; then
		PARTITION1=${DRIVE}p1									# /dev/sdd1 or /dev/mmcblk0p1
	fi

	PARTITION2=${DRIVE}2
	if [ ! -b ${PARTITION2} ]; then
		PARTITION2=${DRIVE}p2									# /dev/sdd2 or /dev/mmcblk0p2
	fi

	echo "PARTITION1 = $PARTITION1"
	echo "PARTITION2 = $PARTITION2"

	# 格式化分区
	# now make partitions.
	if [ -b ${PARTITION1} ]; then
		mkfs.vfat -F 32 -n "boot" ${PARTITION1}
	else
		echo "Cant find boot partition in /dev"
	fi

	if [ -b ${PARITION2} ]; then
		mkfs.ext4 -L "rootfs" ${PARTITION2}
	else
		echo "Cant find rootfs partition in /dev"
	fi

	echo "Partitioning and formatting completed!"
	mount | grep $DRIVE

	# 重新打开udev事件处理
	udevadm control -S
	sleep 2

	# 创建挂在节点
	execute "mkdir -p $BOOTFS_DIR"
	execute "mount $PARTITION1 $BOOTFS_DIR"
	execute "mkdir -p $ROOTFS_DIR"
	execute "mount $PARTITION2 $ROOTFS_DIR"
	sleep 3
	
	execute "chown -R $User $ROOTFS_DIR"
	execute "chgrp -R $User $ROOTFS_DIR"
	sleep 2
}


# 获取参数列表
echo "arg num = $#"
echo "args = $@"

# 获取用户变量
User=`who | awk '{print $1}'`
echo "User = $User"

# 获取目录和文件信息
TOP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR=$TOP_DIR/build
DEPLOY_DIR=$BUILD_DIR/arago-tmp-external-arm-glibc/deploy/images/j7-evm
BOOTFS_DIR=/media/$User/boot
ROOTFS_DIR=/media/$User/rootfs
BOOTFS_TAR=boot-j7-evm.tar.gz
ROOTFS_TAR=tisdk-default-image-j7-evm.tar.xz

echo "TOP DIR = $TOP_DIR"
echo "BUILD DIR = $BUILD_DIR"
echo "DEPLOY DIR = $DEPLOY_DIR"
echo "BOOTFS DIR = $BOOTFS_DIR"
echo "ROOTFS DIR = $ROOTFS_DIR"
echo "ROOTFS TAR = $BOOTFS_TAR"
echo "ROOTFS TAR = $ROOTFS_TAR"

build_parse $@

exit 0
