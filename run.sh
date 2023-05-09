#!/bin/bash

#CFLAGS = -g -O2 -Wall -I$(LUA_INC) -DUSE_PTHREAD_LOCK -DLUA_CJSON_SAFE

: <<'GIT'
# 还原etc下配置
git checkout etc/
if [ $? -ne 0 ]; then
  echo "git checkout [etc] failed. Aborting."
  exit 1
fi

# 还原service下配置
git checkout service/
if [ $? -ne 0 ]; then
  echo "git checkout [service] failed. Aborting."
  exit 1
fi

# 更新到最新代码
git pull
if [ $? -ne 0 ]; then
  echo "git pull failed. Aborting."
  exit 1
fi
GIT

# 参数=w 则启动web服务器
case "${1,,}" in
  w)
    ./skynet/skynet etc/web_config -D
    ./check_log_file_size.sh
    ;;
  *)
    ./skynet/skynet etc/config
    ;;
esac