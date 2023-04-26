CREATE DATABASE GameDB;
--DROP DATABASE GameDB;

--DROP TABLE `user`;
--DESCRIBE `user`; 
--SHOW COLUMNS FROM `user`;

CREATE TABLE `user` (
  `uid` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(128) NOT NULL,
  `password` varchar(128) NOT NULL,
  `permission` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

--INSERT INTO `user` (`username`, `password`) VALUES ('a1234', "123456");
--SELECT uid, username, password, permission FROM user;
-- DELETE FROM user WHERE gold = 0;

CREATE TABLE 'player' (
  'id' INT(11) NOT NULL AUTO_INCREMENT,
  'uid' INT(11) NOT NULL,
  'nickname' VARCHAR(128) NOT NULL,
  'money' INT(11) NOT NULL DEFAULT 0,
  PRIMARY KEY ('id'),
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;