


create table student(
Sno int(10) NOT NULL COMMENT '学号',
Sname varchar(16) NOT NULL COMMENT '姓名',
Ssex char(2) NOT NULL COMMENT '性别',
Sage tinyint(2)  NOT NULL default '0' COMMENT '学生年龄',
Sdept varchar(16)  default NULL  COMMENT '学生所在系别',
PRIMARY KEY  (Sno)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;


#!/bin/bash
#create by oldboy 20110319
#qq:31333741
MysqlLogin="mysql -uroot -poldboy" #→定义登陆mysql的命令，方便下文使用
#MysqlLogin="mysql -uroot -poldboy -S /data/3306/mysql.sock" #此行适合单机多实例数据库的方式
i=1
while true #→true表示永远为真
do
 ${MysqlLogin} -e "insert into test.student values ("$i",'oldboy"$i"','m','21','computer"$i"');"
 #${MysqlLogin} -e "insert into oldboy.student values ("$i",'oldboy"$i"','m','21','computer"$i"');"
 #如果是多张表可以同时插入多张表,我这里给出的例子，是插入不同的记录，
 ((i++))
 sleep 2;
done