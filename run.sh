#!/bin/bash

# 检查是否安装了git
if ! dpkg-query -W -f='${Status}' git 2>/dev/null | grep -q "ok installed"; then
    echo "instatll git ..."
    sudo apt-get install git
fi
git --version

# 检查是否安装了autoconf
if ! dpkg-query -W -f='${Status}' autoconf 2>/dev/null | grep -q "ok installed"; then
    echo "instatll autoconf ..."
    sudo apt-get install autoconf
fi
autoconf --version

# 检查是否安装了gcc
if ! dpkg-query -W -f='${Status}' gcc 2>/dev/null | grep -q "ok installed"; then
    echo "instatll gcc ..."
    sudo apt-get install gcc
fi
gcc --version

# 下载skynet源码
echo "clone skynet ..."
git clone http:://gitee.com/mirrors/skynet/git

cd skynet

# 编译skynet
make linux

# 运行案例
./skynet example/config