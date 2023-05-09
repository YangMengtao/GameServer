#!/bin/bash

# 指定待检查的文件路径
file_path="logs/skynet.log"

# 指定检查的时间间隔，这里设置为1分钟
interval=60

while true; do
    # 使用du命令获取文件大小，-b选项表示以字节为单位，-c选项表示显示总大小
    file_size=$(du -bc "${file_path}" | grep total | awk '{print $1}')
    
    # 判断文件大小是否超过10M
    if [ "${file_size}" -gt $((10 * 1024 * 1024)) ]; then
        # 如果文件超过10M，复制一份新的文件并以时间命名
        timestamp=$(date +%Y%m%d%H%M%S)
        cp "${file_path}" "${file_path}_${timestamp}"
        
        # 清空原文件内容
        echo "" > "${file_path}"
    fi
    
    # 等待一定时间后再次检查文件大小
    sleep "${interval}"
done