#!/bin/bash

user="root"  #用变量来存储用户
DB="class2"   #数据库为class
TB="student3" #需要建立的表是student

mysql -u$user -p123456<<EOF  #前面实现了免密码登录，这里就不需要写密码了
create database $DB; #建立数据库
use $DB;             #进入到数据库
create table $TB (   #建立表格
sid int(11),
sname varchar(20),
sage int(11), 
ssex tinyint(2), 
saddress varchar(20), 
year smallint(20)
)engine =Innodb default charset=utf8;
#前面数据库名和表名都是变量，以后我要建其他表的话，就可以直接用这个模板，然后稍微修改一下我需要的字段就可以。
insert into $DB.$TB(sname,sage,ssex,saddress,year)  values("a",18,0,"湖南",now());
insert into $DB.$TB(sname,sage,ssex,saddress,year)  values("b",27,1,"广东",now());
insert into $DB.$TB(sname,sage,ssex,saddress,year)  values("c",23,0,"湖南",now());
EOF