#!/bin/bash

# 备份目录
backup_dir="/home/user/backup"
# 数据库名
db_name="login_system"
# 数据库用户名和密码
db_user="root"
db_password="123456"
# 保留最近一个月内的备份文件
max_days=30

# 创建备份目录
mkdir -p $backup_dir

# 生成备份文件名（以时间戳为文件名）
backup_file="$backup_dir/$db_name-$(date +%Y%m%d%H%M%S).sql.gz"

# 备份数据库
mysqldump -u$db_user -p$db_password $db_name | gzip > $backup_file

# 删除一个月之前的备份文件
find $backup_dir -type f -name "*.sql.gz" -mtime +$max_days -delete