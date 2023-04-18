#!/bin/bash

# 检查是否安装了git
#if ! dpkg-query -W -f='${Status}' git 2>/dev/null | grep -q "ok installed"; then
#    echo "instatll git ..."
#    sudo apt-get install git
#fi
#git --version

function pause(){
        echo 'Press any key to continue...'
        read -n 1 -p "$*" str_inp
        if [ -z "$str_inp" ];then
                str_inp=1
        fi
        #echo "+$str_inp+"
        if [ $str_inp != '' ] ; then
                echo -ne '\b \n'
        fi
}

# 安装cjson
sudo apt-get install lua-cjson

# 检查是否安装了mysql
if ! dpkg-query -W -f='${Status}' mysql 2>/dev/null | grep -q "ok installed"; then
    echo "instatll mysql ..."
    sudo apt-get install mysql-server
fi
mysql --version

echo "start mysql"
service mysql start
ps -axj |grep mysql
#service mysql stop
pause

# 检查是否安装了autoconf
if ! dpkg-query -W -f='${Status}' autoconf 2>/dev/null | grep -q "ok installed"; then
    echo "instatll autoconf ..."
    sudo apt-get install autoconf
fi
autoconf --version
pause

# 检查是否安装了gcc
if ! dpkg-query -W -f='${Status}' gcc 2>/dev/null | grep -q "ok installed"; then
    echo "instatll gcc ..."
    sudo apt-get install gcc
fi
gcc --version
pause

SKYNET_FILE=~/skynet
if ! [ -d "$SKYNET_FILE" ]; then
    # 下载skynet源码
    echo "clone skynet ..."
    git clone http://gitee.com/mirrors/skynet.git
    pause
fi
