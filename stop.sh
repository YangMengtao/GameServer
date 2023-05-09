#!/bin/bash

pid=$(cat skynet.pid)
echo $pid
kill -9 $pid

pid=$(ps -ef | grep check_log_file_size.sh | awk '{print $2}')
echo $pid
kill -9 $pid

# 备份被删除原有的log文件
file_path="logs/skynet.log"
file_ext = ".log"
timestamp=$(date +%Y%m%d%H%M%S)
cp "${file_path}" "${timestamp}.log"
rm -rf ${file_path}