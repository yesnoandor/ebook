# 获取参数列表
# echo "arg num = $#"
# echo "args = $@"

if [[ $# -eq 1 ]]; then
    sudo mount -t ext4 -o rw $1 ~/server/ext-disk/
else
    sudo mount -t ext4 -o rw /dev/sdb1 ~/server/ext-disk/
fi;

sleep 2
