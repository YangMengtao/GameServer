#!/bin/bash

pid=$(cat skynet.pid)

kill -9 pid

pid=$(ps aux | grep check_log_file_size.sh)

kill -9 pid

# 备份被删除原有的log文件
file_path="logs/skynet.log"
timestamp=$(date +%Y%m%d%H%M%S)
cp "${file_path}" "${file_path}_${timestamp}"
rm -rf ${file_path}