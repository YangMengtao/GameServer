CREATE DATABASE GameDB;
--DROP DATABASE GameDB;

--DROP TABLE `user`;
--DESCRIBE `user`; 
--SHOW COLUMNS FROM `user`;

-- uid 账号唯一id
-- usename 账号名字
-- password 账号密码
-- permission 权限
CREATE TABLE `user` (
  `uid` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(128) NOT NULL,
  `password` varchar(128) NOT NULL,
  `permission` int(11) NOT NULL DEFAULT 0,
  `create_time` int(10) NOT NULL DEFAULT 0,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

--INSERT INTO `user` (`username`, `password`) VALUES ("aaaa", "123456");
--SELECT uid, username, password, permission FROM user;
-- DELETE FROM user WHERE gold = 0;


CREATE TABLE `player` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `uid` INT(11) NOT NULL,
  `nickname` VARCHAR(128) NOT NULL,
  `money` INT(11) NOT NULL DEFAULT 0,
  `curlevel` INT(11) NOT NULL DEFAULT 0,
  `lastOnline` int(10) NOT NULL DEFAULT 0,
  `item` TEXT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE `team_member` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `pid` INT(11),
  `alive` INT(2) NOT NULL DEFAULT 1,
  `weaponid` INT(11) NOT NULL DEFAULT 0,
  `armorid` INT(11) NOT NULL DEFAULT 0,
  `normalskillid` INT(11) NOT NULL DEFAULT 0,
  `ultraskillid` INT(11) NOT NULL DEFAULT 0,
  `hp` INT(11) NOT NULL DEFAULT 0,
  `energy` INT(11) NOT NULL DEFAULT 0,
  `practiceattrs` VARCHAR(256),
  `rewardattrs` VARCHAR(256),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;