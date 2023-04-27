# GameServer

1.下载 virtualbox https://www.virtualbox.org/wiki/Download_Old_Builds_6_1 并安装
    Windows hosts
    xtension Pack
2.下载 Ubuntu https://cn.ubuntu.com/download/desktop 并安装
3.Ubuntu 安装成功后，在virtualbox 虚拟机 -> 设置 -> 网络
    a.网卡1中 高级->端口转发->添加
        名称   协议    主机IP   主机端口  子系统ip          子系统端口
        xxx    tcp              8180     10.2.2.15         22

        进入虚拟机中查看静态IP地址 (ifconfig -a)

        window 通过ssh连接 比如 ssh sy@192.168.16.1 -p 8180
    b.网卡2中连接方式选择桥接模式
4.其他配置参考doc/下面的txt (cjson已经集成在工程里了，不需要在操作了)
